//
//  VoiceRecord_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/9/19.
//

import AVFoundation
import BCLRingSDK
import SnapKit
import UIKit

// 音频文件信息结构
struct AudioFileInfo {
    let fileName: String
    let filePath: String
    let fileSize: Int64
    let duration: TimeInterval
    let createDate: Date
}

class VoiceRecord_VC: UIViewController {
    private var isRecording = false

    // 音频文件列表
    private var audioFileList: [AudioFileInfo] = []

    // 缓存收到的ADPCM格式音频数据
    private var adpcmAudioDataList: [(length: Int, seq: Int, audioData: [Int])] = []

    // 音频播放器
    private var audioPlayer: AVAudioPlayer?

    // 当前播放的文件路径
    private var currentPlayingFilePath: String?

    private lazy var startRecordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开始录音", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        return button
    }()

    private lazy var stopRecordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("结束录音", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        return button
    }()

    private lazy var recordingAnimationView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    private lazy var waveformView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        view.layer.cornerRadius = 75
        return view
    }()

    private lazy var waveformView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
        view.layer.cornerRadius = 100
        return view
    }()

    private lazy var waveformView3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        view.layer.cornerRadius = 125
        return view
    }()

    private lazy var recordingLabel: UILabel = {
        let label = UILabel()
        label.text = "录音中..."
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor.systemRed
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .regular)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "AudioFileCell")
        table.backgroundColor = .systemBackground
        return table
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无录音文件"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        return label
    }()

    private var recordingTimer: Timer?
    private var recordingStartTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioSession()
        loadAudioFileList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isRecording {
            stopRecording()
        }
        stopAudioPlayback()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "录音"

        view.addSubview(tableView)
        view.addSubview(recordingAnimationView)
        recordingAnimationView.addSubview(waveformView3)
        recordingAnimationView.addSubview(waveformView2)
        recordingAnimationView.addSubview(waveformView1)

        view.addSubview(recordingLabel)
        view.addSubview(timeLabel)
        view.addSubview(startRecordButton)
        view.addSubview(stopRecordButton)
        view.addSubview(emptyLabel)

        // 音频文件列表
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }

        recordingAnimationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom).offset(20)
            make.width.height.equalTo(250)
        }

        waveformView3.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(250)
        }

        waveformView2.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }

        waveformView1.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(150)
        }

        recordingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(recordingAnimationView.snp.top).offset(-10)
        }

        timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(recordingAnimationView.snp.bottom).offset(10)
        }

        startRecordButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-80)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            make.width.equalTo(120)
            make.height.equalTo(50)
        }

        stopRecordButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(80)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            make.width.equalTo(120)
            make.height.equalTo(50)
        }

        updateEmptyLabelVisibility()
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            BDLogger.error("Failed to set up audio session: \(error)")
        }
    }

    private func updateEmptyLabelVisibility() {
        emptyLabel.isHidden = !audioFileList.isEmpty
    }

    @objc private func startRecording() {
        isRecording = true
        recordingStartTime = Date()
        adpcmAudioDataList.removeAll()

        startRecordButton.isEnabled = false
        startRecordButton.alpha = 0.5
        stopRecordButton.isEnabled = true
        stopRecordButton.alpha = 1.0

        recordingLabel.isHidden = false
        timeLabel.isHidden = false
        recordingAnimationView.isHidden = false

        startRecordingAnimation()
        startTimer()

        // 调用SDK开始录音
        controlADPCMFormatAudio(isOpen: true)

        BDLogger.info("开始从SDK获取音频数据")
    }

    @objc private func stopRecording() {
        isRecording = false

        startRecordButton.isEnabled = true
        startRecordButton.alpha = 1.0
        stopRecordButton.isEnabled = false
        stopRecordButton.alpha = 0.5

        recordingLabel.isHidden = true
        timeLabel.isHidden = true
        recordingAnimationView.isHidden = true

        stopRecordingAnimation()
        stopTimer()

        // 调用SDK停止录音
        controlADPCMFormatAudio(isOpen: false)

        BDLogger.info("停止从SDK获取音频数据")
    }

    // MARK: - SDK音频控制

    private func controlADPCMFormatAudio(isOpen: Bool) {
        BCLRingManager.shared.controlADPCMFormatAudio(isOpen: isOpen) { [weak self] result in
            switch result {
            case let .success(response):
                BDLogger.info("ADPCM音频数据 - 长度: \(response.audioDataLength), 序号: \(response.seq)")

                if isOpen {
                    // 收集音频数据
                    self?.adpcmAudioDataList.append((
                        length: response.audioDataLength,
                        seq: response.seq,
                        audioData: response.audioData
                    ))
                } else {
                    // 停止录音时处理数据
                    self?.processADPCMData()
                }

            case let .failure(error):
                BDLogger.error("控制ADPCM音频失败: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showAlert(title: isOpen ? "开启录音失败" : "停止录音失败",
                                    message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - 处理ADPCM数据

    private func processADPCMData() {
        guard !adpcmAudioDataList.isEmpty else {
            BDLogger.error("没有音频数据需要处理")
            return
        }

        // 按序号排序
        let sortedDataList = adpcmAudioDataList.sorted { $0.seq < $1.seq }

        var processedPCMData = Data()

        // 将每段ADPCM数据转换为PCM
        for dataItem in sortedDataList {
            // 将Int数组转换为Data
            let int16Array = dataItem.audioData.map { Int16($0) }
            let adpcmData = int16Array.withUnsafeBufferPointer { buffer in
                Data(bytes: buffer.baseAddress!, count: buffer.count * MemoryLayout<Int16>.size)
            }

            // 使用SDK提供的转换方法
            if let pcmData = BCLRingManager.shared.convertAdpcmToPcm(adpcmData: adpcmData) {
                processedPCMData.append(pcmData)
            }
        }

        // 保存PCM文件
        savePCMFile(processedPCMData)
    }

    // MARK: - 保存PCM文件

    private func savePCMFile(_ pcmData: Data) {
        guard !pcmData.isEmpty else {
            BDLogger.error("PCM数据为空")
            return
        }

        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let deviceMac = BCLRingManager.shared.currentConnectedDevice?.macAddress ?? "unknown"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "\(deviceMac)_\(dateString).pcm"
        let filePath = (documentPath as NSString).appendingPathComponent(fileName)

        do {
            try pcmData.write(to: URL(fileURLWithPath: filePath))
            BDLogger.info("PCM文件已保存: \(filePath)")

            DispatchQueue.main.async {
                self.loadAudioFileList()
                self.showAlert(title: "录音完成", message: "音频文件已保存")
            }
        } catch {
            BDLogger.error("保存PCM文件失败: \(error)")
            DispatchQueue.main.async {
                self.showAlert(title: "保存失败", message: error.localizedDescription)
            }
        }
    }

    // MARK: - 加载音频文件列表

    private func loadAudioFileList() {
        audioFileList.removeAll()

        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default

        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentPath)

            for file in files {
                if file.hasSuffix(".pcm") {
                    let filePath = (documentPath as NSString).appendingPathComponent(file)

                    if let attributes = try? fileManager.attributesOfItem(atPath: filePath) {
                        let fileSize = attributes[.size] as? Int64 ?? 0
                        let createDate = attributes[.creationDate] as? Date ?? Date()

                        // 计算音频时长（PCM格式：采样率8000Hz，单声道，16位）
                        let duration = Double(fileSize) / (8000 * 2)

                        let audioInfo = AudioFileInfo(
                            fileName: file,
                            filePath: filePath,
                            fileSize: fileSize,
                            duration: duration,
                            createDate: createDate
                        )

                        audioFileList.append(audioInfo)
                    }
                }
            }

            // 按创建时间排序，最新的在前
            audioFileList.sort { $0.createDate > $1.createDate }

            tableView.reloadData()
            updateEmptyLabelVisibility()

        } catch {
            BDLogger.error("读取文件列表失败: \(error)")
        }
    }

    // MARK: - 播放音频

    private func playPCMFile(_ filePath: String) {
        // 如果正在播放同一个文件，则停止
        if currentPlayingFilePath == filePath {
            stopAudioPlayback()
            return
        }

        // 停止之前的播放
        stopAudioPlayback()

        do {
            let pcmData = try Data(contentsOf: URL(fileURLWithPath: filePath))

            // 将PCM转换为WAV格式（添加WAV文件头）
            let wavData = createWAVData(from: pcmData)

            // 创建播放器
            audioPlayer = try AVAudioPlayer(data: wavData)
            audioPlayer?.delegate = self
            audioPlayer?.play()

            currentPlayingFilePath = filePath
            tableView.reloadData()

            BDLogger.info("开始播放: \(filePath)")

        } catch {
            BDLogger.error("播放失败: \(error)")
            showAlert(title: "播放失败", message: error.localizedDescription)
        }
    }

    // MARK: - 停止播放

    private func stopAudioPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentPlayingFilePath = nil
        tableView.reloadData()
    }

    // MARK: - 创建WAV数据

    private func createWAVData(from pcmData: Data) -> Data {
        var wavData = Data()

        // WAV文件头
        let sampleRate: UInt32 = 8000
        let bitsPerSample: UInt16 = 16
        let channels: UInt16 = 1
        let byteRate = sampleRate * UInt32(channels) * UInt32(bitsPerSample) / 8
        let blockAlign = channels * bitsPerSample / 8
        let dataSize = UInt32(pcmData.count)
        var fileSize = dataSize + 36

        // RIFF标识
        wavData.append("RIFF".data(using: .ascii)!)
        withUnsafeBytes(of: fileSize.littleEndian) { wavData.append(Data($0)) }
        wavData.append("WAVE".data(using: .ascii)!)

        // fmt子块
        wavData.append("fmt ".data(using: .ascii)!)
        var subchunk1Size: UInt32 = 16
        withUnsafeBytes(of: subchunk1Size.littleEndian) { wavData.append(Data($0)) }
        var audioFormat: UInt16 = 1 // PCM
        withUnsafeBytes(of: audioFormat.littleEndian) { wavData.append(Data($0)) }
        var channelsCopy = channels
        withUnsafeBytes(of: channelsCopy.littleEndian) { wavData.append(Data($0)) }
        var sampleRateCopy = sampleRate
        withUnsafeBytes(of: sampleRateCopy.littleEndian) { wavData.append(Data($0)) }
        var byteRateCopy = byteRate
        withUnsafeBytes(of: byteRateCopy.littleEndian) { wavData.append(Data($0)) }
        var blockAlignCopy = blockAlign
        withUnsafeBytes(of: blockAlignCopy.littleEndian) { wavData.append(Data($0)) }
        var bitsPerSampleCopy = bitsPerSample
        withUnsafeBytes(of: bitsPerSampleCopy.littleEndian) { wavData.append(Data($0)) }

        // data子块
        wavData.append("data".data(using: .ascii)!)
        var dataSizeCopy = dataSize
        withUnsafeBytes(of: dataSizeCopy.littleEndian) { wavData.append(Data($0)) }
        wavData.append(pcmData)

        return wavData
    }

    private func startRecordingAnimation() {
        let animation1 = CABasicAnimation(keyPath: "transform.scale")
        animation1.fromValue = 1.0
        animation1.toValue = 1.2
        animation1.duration = 1.5
        animation1.repeatCount = .infinity
        animation1.autoreverses = true
        animation1.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let animation2 = CABasicAnimation(keyPath: "transform.scale")
        animation2.fromValue = 1.0
        animation2.toValue = 1.3
        animation2.duration = 1.5
        animation2.repeatCount = .infinity
        animation2.autoreverses = true
        animation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation2.beginTime = CACurrentMediaTime() + 0.3

        let animation3 = CABasicAnimation(keyPath: "transform.scale")
        animation3.fromValue = 1.0
        animation3.toValue = 1.4
        animation3.duration = 1.5
        animation3.repeatCount = .infinity
        animation3.autoreverses = true
        animation3.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation3.beginTime = CACurrentMediaTime() + 0.6

        waveformView1.layer.add(animation1, forKey: "scale1")
        waveformView2.layer.add(animation2, forKey: "scale2")
        waveformView3.layer.add(animation3, forKey: "scale3")

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.3
        opacityAnimation.duration = 0.8
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.autoreverses = true

        recordingLabel.layer.add(opacityAnimation, forKey: "opacity")
    }

    private func stopRecordingAnimation() {
        waveformView1.layer.removeAllAnimations()
        waveformView2.layer.removeAllAnimations()
        waveformView3.layer.removeAllAnimations()
        recordingLabel.layer.removeAllAnimations()
    }

    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimeLabel()
        }
    }

    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private func updateTimeLabel() {
        guard let startTime = recordingStartTime else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60

        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension VoiceRecord_VC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFileList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioFileCell", for: indexPath)
        let audioInfo = audioFileList[indexPath.row]

        // 格式化文件大小
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        let sizeString = formatter.string(fromByteCount: audioInfo.fileSize)

        // 格式化时长
        let minutes = Int(audioInfo.duration) / 60
        let seconds = Int(audioInfo.duration) % 60
        let durationString = String(format: "%02d:%02d", minutes, seconds)

        // 设置cell内容
        cell.textLabel?.text = audioInfo.fileName
        cell.detailTextLabel?.text = "\(durationString) | \(sizeString)"

        // 如果正在播放这个文件，显示播放图标
        if currentPlayingFilePath == audioInfo.filePath {
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = .systemBlue
        } else {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .label
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension VoiceRecord_VC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let audioInfo = audioFileList[indexPath.row]
        playPCMFile(audioInfo.filePath)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let audioInfo = audioFileList[indexPath.row]

            // 如果正在播放这个文件，先停止
            if currentPlayingFilePath == audioInfo.filePath {
                stopAudioPlayback()
            }

            // 删除文件
            do {
                try FileManager.default.removeItem(atPath: audioInfo.filePath)
                audioFileList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                updateEmptyLabelVisibility()
            } catch {
                showAlert(title: "删除失败", message: error.localizedDescription)
            }
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension VoiceRecord_VC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudioPlayback()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopAudioPlayback()
        if let error = error {
            showAlert(title: "播放错误", message: error.localizedDescription)
        }
    }
}
