//
//  HIDAudioStreamingSupport.swift
//  BCLRingSDKDemo
//
//  HID/手动音频共用的格式描述、ADPCM 流式解码与 WAV 文件写入示例。
//

import BCLRingSDK
import Foundation

/// 描述解码后 PCM 数据的格式。
///
/// 所有数值均描述 PCM 输出，而不是压缩前的 ADPCM 输入：`sampleRate` 单位为 Hz，
/// `channelCount` 为声道数，`bitsPerSample` 为每个声道每个采样点的位数。
struct AudioFormatConfiguration: Equatable {
    let sampleRate: Int
    let channelCount: Int
    let bitsPerSample: Int

    /// 当前 HID ADPCM1 单声道解码器对应的输出格式。
    static let pcm8kMono16 = AudioFormatConfiguration(sampleRate: 8_000, channelCount: 1, bitsPerSample: 16)

    /// 为后续双声道解码示例预留的 WAV 输出格式。
    static let pcm8kStereo16 = AudioFormatConfiguration(sampleRate: 8_000, channelCount: 2, bitsPerSample: 16)

    var bytesPerSample: Int { bitsPerSample / 8 }
    var blockAlign: Int { channelCount * bytesPerSample }
    var byteRate: Int { sampleRate * blockAlign }

    /// 当前示例的 WAV 写入器支持正采样率、单/双声道和整字节位深 PCM。
    var isSupported: Bool {
        sampleRate > 0
            && (1 ... 2).contains(channelCount)
            && bitsPerSample > 0
            && bitsPerSample % 8 == 0
    }

    func duration(forPCMByteCount byteCount: Int64) -> TimeInterval {
        guard byteRate > 0 else { return 0 }
        return TimeInterval(byteCount) / TimeInterval(byteRate)
    }
}

enum AudioStreamingError: LocalizedError {
    case unsupportedFormat(AudioFormatConfiguration)
    case decoderInitializationFailed
    case invalidPacketSequence(expected: Int, actual: Int)
    case emptyPacket
    case decodeFailed
    case fileWriteFailed
    case emptyRecording
    case sessionFinished

    var errorDescription: String? {
        switch self {
        case let .unsupportedFormat(format):
            return "不支持的音频格式: \(format.sampleRate)Hz, \(format.channelCount)声道, \(format.bitsPerSample)bit"
        case .decoderInitializationFailed:
            return "ADPCM解码器初始化失败"
        case let .invalidPacketSequence(expected, actual):
            return "音频数据包顺序错误: 期望\(expected)，收到\(actual)"
        case .emptyPacket:
            return "音频数据包为空"
        case .decodeFailed:
            return "ADPCM音频解码失败"
        case .fileWriteFailed:
            return "保存音频文件失败"
        case .emptyRecording:
            return "没有收到有效音频数据"
        case .sessionFinished:
            return "音频转换会话已结束"
        }
    }
}

/// 单个音频来源的一次流式转换会话。
///
/// SDK 的 ADPCM 处理器保存跨数据包状态且由单例管理，因此外部必须在同一个串行队列上
/// 创建、调用和结束本类型，并保证同一时间只有一个会话存在。
final class HIDAudioStreamingSession {
    enum Source: String {
        case manual = "手动"
        case hid = "HID"
    }

    enum PacketResult {
        case appended
        case duplicate
    }

    let source: Source
    let format: AudioFormatConfiguration

    private let writer: StreamingWAVFileWriter
    private var packetNumberBase: Int?
    private var nextPacketNumber = 0
    private var isFinished = false

    private(set) var packetCount = 0
    private(set) var adpcmByteCount = 0
    private(set) var pcmByteCount = 0

    init(source: Source, format: AudioFormatConfiguration, outputURL: URL) throws {
        guard format.isSupported, format == .pcm8kMono16 else {
            throw AudioStreamingError.unsupportedFormat(format)
        }
        guard BCLRingManager.shared.initAdpcmProcessors() else {
            throw AudioStreamingError.decoderInitializationFailed
        }

        // 清除 SDK 解码器可能由上一次异常会话遗留的预测状态。
        BCLRingManager.shared.adpcmTransferFinish()
        self.source = source
        self.format = format
        do {
            writer = try StreamingWAVFileWriter(finalURL: outputURL, format: format)
        } catch {
            BCLRingManager.shared.adpcmTransferFinish()
            throw error
        }
    }

    deinit {
        if !isFinished {
            cancel()
        }
    }

    func append(packetNumber: Int, audioData: [Int]) throws -> PacketResult {
        guard !isFinished else { throw AudioStreamingError.sessionFinished }
        guard !audioData.isEmpty else { throw AudioStreamingError.emptyPacket }

        if packetNumberBase == nil {
            packetNumberBase = packetNumber
        }
        guard let packetNumberBase else { throw AudioStreamingError.emptyPacket }

        // 首包可以从任意序号开始，之后只接受连续递增；较小序号视为重复包。
        let normalizedPacketNumber = packetNumber - packetNumberBase
        if normalizedPacketNumber < nextPacketNumber {
            return .duplicate
        }
        guard normalizedPacketNumber == nextPacketNumber else {
            throw AudioStreamingError.invalidPacketSequence(
                expected: packetNumberBase + nextPacketNumber,
                actual: packetNumber
            )
        }

        // SDK 回调用 Int 承载协议中的 16-bit 字。truncatingIfNeeded 可保留原始补码位型，
        // iOS 为小端平台，按 Int16 内存布局组成 Data 后与设备 ADPCM 字节顺序一致。
        let words = audioData.map { Int16(truncatingIfNeeded: $0) }
        let adpcmData = words.withUnsafeBufferPointer { buffer -> Data in
            guard let baseAddress = buffer.baseAddress else { return Data() }
            return Data(bytes: baseAddress, count: buffer.count * MemoryLayout<Int16>.size)
        }
        guard !adpcmData.isEmpty,
              let pcmData = BCLRingManager.shared.decodeMonoAdpcm(adpcmData: adpcmData),
              !pcmData.isEmpty else {
            throw AudioStreamingError.decodeFailed
        }

        try writer.append(pcmData)
        nextPacketNumber += 1
        packetCount += 1
        adpcmByteCount += adpcmData.count
        pcmByteCount += pcmData.count
        return .appended
    }

    func finish() throws -> URL {
        guard !isFinished else { throw AudioStreamingError.sessionFinished }
        guard packetCount > 0, pcmByteCount > 0 else {
            cancel()
            throw AudioStreamingError.emptyRecording
        }

        do {
            let url = try writer.finish()
            resetDecoder()
            isFinished = true
            return url
        } catch {
            cancel()
            throw error
        }
    }

    func cancel() {
        guard !isFinished else { return }
        writer.cancel()
        resetDecoder()
        isFinished = true
    }

    private func resetDecoder() {
        BCLRingManager.shared.adpcmTransferFinish()
    }
}

/// 将 PCM 数据逐包写入临时文件，并在完成时补全 WAV 头后发布最终文件。
private final class StreamingWAVFileWriter {
    private let fileManager = FileManager.default
    private let finalURL: URL
    private let temporaryURL: URL
    private let format: AudioFormatConfiguration
    private var fileHandle: FileHandle?
    private var pcmDataSize = 0

    init(finalURL: URL, format: AudioFormatConfiguration) throws {
        guard format.isSupported else { throw AudioStreamingError.unsupportedFormat(format) }
        self.finalURL = finalURL
        temporaryURL = finalURL.appendingPathExtension("part")
        self.format = format

        try? fileManager.removeItem(at: temporaryURL)
        guard fileManager.createFile(atPath: temporaryURL.path, contents: nil) else {
            throw AudioStreamingError.fileWriteFailed
        }
        do {
            fileHandle = try FileHandle(forWritingTo: temporaryURL)
            try write(Self.makeHeader(format: format, pcmDataSize: 0))
        } catch {
            cancel()
            throw AudioStreamingError.fileWriteFailed
        }
    }

    func append(_ data: Data) throws {
        try write(data)
        pcmDataSize += data.count
    }

    func finish() throws -> URL {
        guard let fileHandle else { throw AudioStreamingError.fileWriteFailed }
        fileHandle.synchronizeFile()
        fileHandle.closeFile()
        self.fileHandle = nil

        do {
            let updateHandle = try FileHandle(forUpdating: temporaryURL)
            updateHandle.seek(toFileOffset: 0)
            let header = Self.makeHeader(format: format, pcmDataSize: pcmDataSize)
            if #available(iOS 13.4, *) {
                try updateHandle.write(contentsOf: header)
            } else {
                updateHandle.write(header)
            }
            updateHandle.synchronizeFile()
            updateHandle.closeFile()

            // 只有 WAV 头成功回写后才以最终扩展名发布，列表不会看到半成品。
            try? fileManager.removeItem(at: finalURL)
            try fileManager.moveItem(at: temporaryURL, to: finalURL)
            return finalURL
        } catch {
            try? fileManager.removeItem(at: temporaryURL)
            throw AudioStreamingError.fileWriteFailed
        }
    }

    func cancel() {
        fileHandle?.closeFile()
        fileHandle = nil
        try? fileManager.removeItem(at: temporaryURL)
    }

    private func write(_ data: Data) throws {
        guard let fileHandle else { throw AudioStreamingError.fileWriteFailed }
        if #available(iOS 13.4, *) {
            try fileHandle.write(contentsOf: data)
        } else {
            fileHandle.write(data)
        }
    }

    static func makeHeader(format: AudioFormatConfiguration, pcmDataSize: Int) -> Data {
        var data = Data()
        data.appendASCII("RIFF")
        data.appendLittleEndian(UInt32(36 + pcmDataSize))
        data.appendASCII("WAVE")
        data.appendASCII("fmt ")
        data.appendLittleEndian(UInt32(16))
        data.appendLittleEndian(UInt16(1)) // Linear PCM
        data.appendLittleEndian(UInt16(format.channelCount))
        data.appendLittleEndian(UInt32(format.sampleRate))
        data.appendLittleEndian(UInt32(format.byteRate))
        data.appendLittleEndian(UInt16(format.blockAlign))
        data.appendLittleEndian(UInt16(format.bitsPerSample))
        data.appendASCII("data")
        data.appendLittleEndian(UInt32(pcmDataSize))
        return data
    }
}

private extension Data {
    mutating func appendASCII(_ value: String) {
        if let valueData = value.data(using: .ascii) {
            append(valueData)
        }
    }

    mutating func appendLittleEndian<T: FixedWidthInteger>(_ value: T) {
        var littleEndianValue = value.littleEndian
        append(Data(bytes: &littleEndianValue, count: MemoryLayout<T>.size))
    }
}
