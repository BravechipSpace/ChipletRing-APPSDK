//
//  VoiceRecord_VC.swift
//  BCLRingSDKDemo
//
//  ADPCM1 单声道手动录音与 HID 触摸录音获取、保存、播放示例。
//

import AVFoundation
import BCLRingSDK
import SnapKit
import UIKit

private struct AudioFileInfo {
    let fileName: String
    let filePath: String
    let fileSize: Int64
    let duration: TimeInterval
    let createDate: Date
}

final class VoiceRecord_VC: UIViewController {
    private let outputFormat = AudioFormatConfiguration.pcm8kMono16

    /// SDK 解码器具有跨包状态，所有会话操作都必须在此串行队列执行。
    private let audioConversionQueue = DispatchQueue(label: "com.bclring.demo.hid-audio-conversion")
    private var currentSession: HIDAudioStreamingSession?
    private var acceptsAudioEvents = true
    private var isManualRecording = false

    private var audioFileList: [AudioFileInfo] = []
    private var audioPlayer: AVAudioPlayer?
    private var currentPlayingFilePath: String?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?

    private lazy var startRecordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开始录音", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        return button
    }()

    private lazy var stopRecordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("结束录音", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        return button
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "等待手动录音或 HID 触摸音频"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var recordingAnimationView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private lazy var waveformViews: [UIView] = [250, 200, 150].enumerated().map { index, size in
        let view = UIView()
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1 * CGFloat(3 - index))
        view.layer.cornerRadius = CGFloat(size) / 2
        return view
    }

    private lazy var recordingLabel: UILabel = {
        let label = UILabel()
        label.text = "录音中..."
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "AudioFileCell")
        return table
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无录音文件"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioSession()
        loadAudioFileList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerHIDAudioCallback()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // SDK 当前仅提供单一闭包属性，音频页面拥有其可见期间的独占消费权。
        BCLRingManager.shared.hidTouchAudioDataBlock = nil
        cancelActiveSession()
        stopAudioPlayback()
        resetRecordingUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "单声道音频录制与播放"

        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(statusLabel)
        view.addSubview(recordingAnimationView)
        waveformViews.forEach(recordingAnimationView.addSubview)
        view.addSubview(recordingLabel)
        view.addSubview(timeLabel)
        view.addSubview(startRecordButton)
        view.addSubview(stopRecordButton)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
        emptyLabel.snp.makeConstraints { make in make.center.equalTo(tableView) }
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }
        recordingAnimationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statusLabel.snp.bottom).offset(12)
            make.width.height.equalTo(250)
        }
        for (view, size) in zip(waveformViews, [250, 200, 150]) {
            view.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(size)
            }
        }
        recordingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(recordingAnimationView.snp.top).offset(-4)
        }
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(recordingAnimationView.snp.bottom).offset(4)
        }
        startRecordButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-80)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        stopRecordButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(80)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        updateEmptyLabelVisibility()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            BDLogger.error("配置播放音频会话失败: \(error.localizedDescription)")
        }
    }

    /// 页面可见时直接监听 SDK 回调。闭包只负责投递到串行队列，避免阻塞蓝牙回调线程。
    private func registerHIDAudioCallback() {
        acceptsAudioEvents = true
        BCLRingManager.shared.hidTouchAudioDataBlock = { [weak self] length, sequence, audioData, isEnd in
            guard let self else { return }
            BDLogger.info("HID音频包: length=\(length), seq=\(sequence), isEnd=\(isEnd)")
            self.audioConversionQueue.async { [weak self] in
                self?.handleHIDPacket(sequence: sequence, audioData: audioData, isEnd: isEnd)
            }
        }
    }

    private func handleHIDPacket(sequence: Int, audioData: [Int], isEnd: Bool) {
        guard acceptsAudioEvents else { return }

        if currentSession?.source == .manual {
            BDLogger.warning("手动录音进行中，忽略HID音频包: \(sequence)")
            return
        }

        if !audioData.isEmpty {
            if currentSession == nil {
                do {
                    currentSession = try makeSession(source: .hid)
                    DispatchQueue.main.async { [weak self] in self?.showRecordingUI(source: .hid) }
                } catch {
                    failSession(source: .hid, error: error)
                    return
                }
            }
            appendPacket(source: .hid, sequence: sequence, audioData: audioData)
        } else if !isEnd {
            failSession(source: .hid, error: AudioStreamingError.emptyPacket)
            return
        }

        if isEnd {
            finishSession(source: .hid)
        }
    }

    @objc private func startRecording() {
        audioConversionQueue.async { [weak self] in
            guard let self else { return }
            guard self.currentSession == nil else {
                BDLogger.warning("已有\(self.currentSession?.source.rawValue ?? "未知")录音会话，拒绝手动录音")
                DispatchQueue.main.async {
                    self.showAlert(title: "无法开始录音", message: "HID音频正在接收，请稍后重试")
                }
                return
            }
            self.acceptsAudioEvents = true
            do {
                // 在发送开启命令前先占用 SDK 解码器，避免等待首包期间 HID 数据抢占会话。
                self.currentSession = try self.makeSession(source: .manual)
            } catch {
                self.failSession(source: .manual, error: error)
                return
            }
            DispatchQueue.main.async { self.showRecordingUI(source: .manual) }
            self.controlManualRecording(isOpen: true)
        }
    }

    @objc private func stopRecording() {
        guard isManualRecording else { return }
        controlManualRecording(isOpen: false)
    }

    private func controlManualRecording(isOpen: Bool) {
        BCLRingManager.shared.controlADPCMFormatAudio(mode: .adpcm1Mono, isOpen: isOpen) { [weak self] result in
            guard let self else { return }
            self.audioConversionQueue.async {
                switch result {
                case let .success(response):
                    if isOpen {
                        self.appendPacket(
                            source: .manual,
                            sequence: response.seq,
                            audioData: response.audioData
                        )
                    } else {
                        self.finishSession(source: .manual)
                    }
                case let .failure(error):
                    self.failSession(source: .manual, error: error)
                }
            }
        }
    }

    private func makeSession(source: HIDAudioStreamingSession.Source) throws -> HIDAudioStreamingSession {
        try HIDAudioStreamingSession(source: source, format: outputFormat, outputURL: makeRecordingURL())
    }

    private func appendPacket(source: HIDAudioStreamingSession.Source, sequence: Int, audioData: [Int]) {
        guard let session = currentSession, session.source == source else { return }
        do {
            switch try session.append(packetNumber: sequence, audioData: audioData) {
            case .appended:
                BDLogger.info("\(source.rawValue)音频已处理包\(sequence)，PCM累计\(session.pcmByteCount)字节")
            case .duplicate:
                BDLogger.warning("\(source.rawValue)音频忽略重复包: \(sequence)")
            }
        } catch {
            failSession(source: source, error: error)
        }
    }

    private func finishSession(source: HIDAudioStreamingSession.Source) {
        guard let session = currentSession, session.source == source else {
            failSession(source: source, error: AudioStreamingError.emptyRecording)
            return
        }
        do {
            let url = try session.finish()
            BDLogger.info("\(source.rawValue)音频保存成功: \(url.path)，共\(session.packetCount)包")
            currentSession = nil
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.resetRecordingUI()
                self.loadAudioFileList()
                self.showAlert(title: "录音完成", message: "音频文件已保存")
            }
        } catch {
            failSession(source: source, error: error)
        }
    }

    private func failSession(source: HIDAudioStreamingSession.Source, error: Error) {
        if currentSession?.source == source {
            currentSession?.cancel()
            currentSession = nil
        }
        BDLogger.error("\(source.rawValue)音频处理失败: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            self?.resetRecordingUI()
            self?.showAlert(title: "音频处理失败", message: error.localizedDescription)
        }
    }

    private func cancelActiveSession() {
        acceptsAudioEvents = false
        audioConversionQueue.async { [weak self] in
            self?.currentSession?.cancel()
            self?.currentSession = nil
        }
    }

    private func makeRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let device = BCLRingManager.shared.currentConnectedDevice?.macAddress ?? "unknown"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss_SSS"
        return documents.appendingPathComponent("\(device)_\(formatter.string(from: Date())).wav")
    }

    private func loadAudioFileList() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            audioFileList = try FileManager.default.contentsOfDirectory(
                at: documents,
                includingPropertiesForKeys: [.fileSizeKey, .creationDateKey],
                options: [.skipsHiddenFiles]
            ).compactMap { url in
                let ext = url.pathExtension.lowercased()
                guard ext == "wav" || ext == "pcm" else { return nil }
                let values = try? url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
                let fileSize = Int64(values?.fileSize ?? 0)
                let duration: TimeInterval
                if ext == "wav" {
                    duration = (try? AVAudioPlayer(contentsOf: url).duration) ?? 0
                } else {
                    duration = outputFormat.duration(forPCMByteCount: fileSize)
                }
                return AudioFileInfo(
                    fileName: url.lastPathComponent,
                    filePath: url.path,
                    fileSize: fileSize,
                    duration: duration,
                    createDate: values?.creationDate ?? .distantPast
                )
            }.sorted { $0.createDate > $1.createDate }
            tableView.reloadData()
            updateEmptyLabelVisibility()
        } catch {
            BDLogger.error("读取音频文件列表失败: \(error.localizedDescription)")
        }
    }

    private func playAudioFile(_ filePath: String) {
        if currentPlayingFilePath == filePath {
            stopAudioPlayback()
            return
        }
        stopAudioPlayback()

        do {
            let url = URL(fileURLWithPath: filePath)
            if url.pathExtension.lowercased() == "wav" {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            } else {
                let pcmData = try Data(contentsOf: url)
                audioPlayer = try AVAudioPlayer(data: makeWAVData(pcmData: pcmData, format: outputFormat))
            }
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            guard audioPlayer?.play() == true else { throw AudioStreamingError.decodeFailed }
            currentPlayingFilePath = filePath
            tableView.reloadData()
        } catch {
            BDLogger.error("播放音频失败: \(error.localizedDescription)")
            showAlert(title: "播放失败", message: error.localizedDescription)
        }
    }

    /// 历史裸 PCM 文件没有自描述头，使用同一格式配置临时封装后播放。
    private func makeWAVData(pcmData: Data, format: AudioFormatConfiguration) -> Data {
        var data = Data()
        func append<T: FixedWidthInteger>(_ value: T) {
            var littleEndianValue = value.littleEndian
            data.append(Data(bytes: &littleEndianValue, count: MemoryLayout<T>.size))
        }
        data.append("RIFF".data(using: .ascii) ?? Data())
        append(UInt32(36 + pcmData.count))
        data.append("WAVEfmt ".data(using: .ascii) ?? Data())
        append(UInt32(16))
        append(UInt16(1))
        append(UInt16(format.channelCount))
        append(UInt32(format.sampleRate))
        append(UInt32(format.byteRate))
        append(UInt16(format.blockAlign))
        append(UInt16(format.bitsPerSample))
        data.append("data".data(using: .ascii) ?? Data())
        append(UInt32(pcmData.count))
        data.append(pcmData)
        return data
    }

    private func stopAudioPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentPlayingFilePath = nil
        tableView.reloadData()
    }

    private func showRecordingUI(source: HIDAudioStreamingSession.Source) {
        isManualRecording = source == .manual
        recordingStartTime = Date()
        statusLabel.text = source == .hid ? "正在接收 HID 触摸音频" : "正在接收手动录音数据"
        startRecordButton.isEnabled = false
        startRecordButton.alpha = 0.5
        stopRecordButton.isEnabled = source == .manual
        stopRecordButton.alpha = source == .manual ? 1 : 0.5
        recordingLabel.isHidden = false
        timeLabel.isHidden = false
        recordingAnimationView.isHidden = false
        startRecordingAnimation()
        startTimer()
    }

    private func resetRecordingUI() {
        isManualRecording = false
        recordingStartTime = nil
        statusLabel.text = "等待手动录音或 HID 触摸音频"
        startRecordButton.isEnabled = true
        startRecordButton.alpha = 1
        stopRecordButton.isEnabled = false
        stopRecordButton.alpha = 0.5
        recordingLabel.isHidden = true
        timeLabel.isHidden = true
        recordingAnimationView.isHidden = true
        timeLabel.text = "00:00"
        stopRecordingAnimation()
        stopTimer()
    }

    private func startRecordingAnimation() {
        for (index, view) in waveformViews.enumerated() {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1
            animation.toValue = 1.2 + Double(index) * 0.1
            animation.duration = 1.5
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.3
            view.layer.add(animation, forKey: "recordingScale")
        }
    }

    private func stopRecordingAnimation() {
        waveformViews.forEach { $0.layer.removeAllAnimations() }
    }

    private func startTimer() {
        stopTimer()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self, let start = self.recordingStartTime else { return }
            let elapsed = Int(Date().timeIntervalSince(start))
            self.timeLabel.text = String(format: "%02d:%02d", elapsed / 60, elapsed % 60)
        }
    }

    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private func updateEmptyLabelVisibility() {
        emptyLabel.isHidden = !audioFileList.isEmpty
    }

    private func showAlert(title: String, message: String) {
        guard viewIfLoaded?.window != nil else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

extension VoiceRecord_VC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        audioFileList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "AudioFileCell")
        let info = audioFileList[indexPath.row]
        let size = ByteCountFormatter.string(fromByteCount: info.fileSize, countStyle: .file)
        let duration = String(format: "%02d:%02d", Int(info.duration) / 60, Int(info.duration) % 60)
        cell.textLabel?.text = info.fileName
        cell.detailTextLabel?.text = "\(duration) | \(size)"
        let isPlaying = currentPlayingFilePath == info.filePath
        cell.accessoryType = isPlaying ? .disclosureIndicator : .none
        cell.textLabel?.textColor = isPlaying ? .systemBlue : .label
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        playAudioFile(audioFileList[indexPath.row].filePath)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        let info = audioFileList[indexPath.row]
        if currentPlayingFilePath == info.filePath {
            stopAudioPlayback()
        }
        do {
            try FileManager.default.removeItem(atPath: info.filePath)
            audioFileList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateEmptyLabelVisibility()
        } catch {
            showAlert(title: "删除失败", message: error.localizedDescription)
        }
    }
}

extension VoiceRecord_VC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudioPlayback()
        if !flag {
            showAlert(title: "播放失败", message: "播放器未能正常完成播放")
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopAudioPlayback()
        showAlert(title: "播放错误", message: error?.localizedDescription ?? "未知解码错误")
    }
}
