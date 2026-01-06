//
//  StereoAdpcmDecode_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/12/30.
//  立体声ADPCM解码功能示例页面
//

import AVFoundation
import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

// MARK: - 立体声音频文件信息结构

struct StereoAudioFileInfo {
    let fileName: String
    let filePath: String
    let fileSize: Int64
    let duration: TimeInterval
    let createDate: Date
}

// MARK: - StereoAdpcmDecode_VC

class StereoAdpcmDecode_VC: UIViewController {
    // MARK: - Properties

    /// 音频文件列表
    private var audioFileList: [StereoAudioFileInfo] = []

    /// 音频播放器
    private var audioPlayer: AVAudioPlayer?

    /// 当前播放的文件路径
    private var currentPlayingFilePath: String?

    /// 是否正在下载
    private var isDownloading = false

    /// 文件列表缓存
    private var collectedFiles: [FileInfoModel] = []

    /// 期望的文件总数
    private var expectedFileCount: Int = 0

    /// 当前下载的文件名
    private var currentDownloadFileName: String?

    /// 下载进度信息
    private var downloadTotalPackages: Int = 0
    private var downloadCurrentPackage: Int = 0

    /// 收集的PCM数据（解码后）
    private var collectedPcmData = Data()

    /// 收集的原始ADPCM数据（解码前）
    private var collectedRawAdpcmData = Data()

    /// 立体声音频参数（根据SDK文档设置）
    private let stereoSampleRate: UInt32 = 16000  // 采样率16kHz
    private let stereoChannels: UInt16 = 2        // 双声道
    private let stereoBitsPerSample: UInt16 = 16  // 16位

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .systemBackground
        return table
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无立体声音频文件"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        return label
    }()

    private lazy var getFileListButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("获取文件列表", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(getFileListButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var progressContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 10
        view.isHidden = true
        return view
    }()

    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "下载中..."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        return label
    }()

    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = UIColor.systemGray4
        progress.progressTintColor = UIColor.systemBlue
        return progress
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(cancelDownloadButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioSession()
        loadAudioFileList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAudioPlayback()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white
        title = "立体声ADPCM解码"

        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(progressContainerView)
        progressContainerView.addSubview(progressLabel)
        progressContainerView.addSubview(progressView)
        progressContainerView.addSubview(cancelButton)
        view.addSubview(getFileListButton)

        // 音频文件列表
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(progressContainerView.snp.top).offset(-10)
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }

        // 进度容器
        progressContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(getFileListButton.snp.top).offset(-15)
            make.height.equalTo(80)
        }

        progressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }

        progressView.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(cancelButton.snp.left).offset(-10)
        }

        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(progressView)
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(50)
        }

        // 获取文件列表按钮
        getFileListButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.width.equalTo(200)
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
            BDLogger.error("设置音频会话失败: \(error)")
        }
    }

    private func updateEmptyLabelVisibility() {
        emptyLabel.isHidden = !audioFileList.isEmpty
    }

    // MARK: - Actions

    @objc private func getFileListButtonTapped() {
        // 检查设备连接
        guard BCLRingManager.shared.currentConnectedDevice != nil else {
            showAlert(title: "提示", message: "设备未连接")
            return
        }

        getFileList()
    }

    @objc private func cancelDownloadButtonTapped() {
        cancelDownload()
    }

    // MARK: - 获取文件列表

    private func getFileList() {
        // 清空之前的缓存
        collectedFiles.removeAll()
        expectedFileCount = 0

        QMUITips.showLoading("获取文件列表中...", in: view)

        BCLRingManager.shared.getFileList { [weak self] res in
            guard let self = self else { return }

            switch res {
            case let .success(response):
                BDLogger.info("获取文件系统列表成功: \(response)")
                BDLogger.info("文件系统列表-总个数: \(response.fileTotalCount ?? 0)")
                BDLogger.info("文件系统列表-当前索引: \(response.fileIndex ?? 0)")
                BDLogger.info("文件系统列表-文件名: \(response.fileName ?? "")")
                BDLogger.info("文件系统列表-文件类型: \(response.fileType ?? "")")

                // 记录期望的文件总数
                if let totalCount = response.fileTotalCount, self.expectedFileCount == 0 {
                    self.expectedFileCount = totalCount
                    // 如果没有文件，直接提示
                    if totalCount == 0 {
                        DispatchQueue.main.async {
                            QMUITips.hideAllTips(in: self.view)
                            self.showAlert(title: "提示", message: "设备中没有文件")
                        }
                        return
                    }
                }

                // 收集文件信息（只收集ADPCM音频文件，类型为8）
                if let fileName = response.fileName, !fileName.isEmpty {
                    let fileInfo = FileInfoModel(
                        fileName: fileName,
                        userId: response.userId,
                        fileDate: response.fileDate,
                        fileSize: response.fileSize,
                        fileType: response.fileType,
                        isSelected: false
                    )
                    self.collectedFiles.append(fileInfo)

                    // 检查是否已经收集完所有文件
                    if self.collectedFiles.count >= self.expectedFileCount {
                        BDLogger.info("所有文件信息收集完成，共 \(self.collectedFiles.count) 个文件")
                        DispatchQueue.main.async {
                            QMUITips.hideAllTips(in: self.view)
                            // 筛选ADPCM音频文件
                            let adpcmFiles = self.collectedFiles.filter { $0.fileType == "8" }
                            if adpcmFiles.isEmpty {
                                self.showAlert(title: "提示", message: "设备中没有ADPCM音频文件")
                            } else {
                                self.showFileListDialog(files: adpcmFiles)
                            }
                        }
                    }
                }

            case let .failure(error):
                BDLogger.error("获取文件系统列表失败: \(error)")
                DispatchQueue.main.async {
                    QMUITips.hideAllTips(in: self.view)
                    self.showAlert(title: "获取失败", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - 显示文件列表Dialog

    private func showFileListDialog(files: [FileInfoModel]) {
        let dialogWidth: CGFloat = UIScreen.main.bounds.width - 40
        let dialogHeight: CGFloat = UIScreen.main.bounds.height * 0.6
        let dialogX: CGFloat = 20
        let dialogY: CGFloat = (UIScreen.main.bounds.height - dialogHeight) / 2

        let fileListDialog = FileListDialog(x: dialogX, y: dialogY, width: dialogWidth, height: dialogHeight, files: files)
        fileListDialog.downloadButtonCallback = { [weak self] selectedFiles in
            guard let self = self else { return }
            guard let fileName = selectedFiles.first else {
                BDLogger.warning("未选择任何文件进行下载")
                return
            }
            // 只下载第一个选中的文件
            BDLogger.info("开始下载文件: \(fileName)")
            self.startDownloadFile(fileName: fileName)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = fileListDialog
        modalPresentation_VC.showWith(animated: true)
    }

    // MARK: - 文件下载和解码

    private func startDownloadFile(fileName: String) {
        guard !isDownloading else {
            BDLogger.warning("已有下载任务正在进行")
            return
        }

        isDownloading = true
        currentDownloadFileName = fileName
        downloadTotalPackages = 0
        downloadCurrentPackage = 0
        collectedPcmData = Data()
        collectedRawAdpcmData = Data()

        // 初始化立体声ADPCM处理器
        BCLRingManager.shared.initAdpcmProcessors()

        // 显示进度UI
        progressContainerView.isHidden = false
        progressView.progress = 0
        progressLabel.text = "准备下载..."
        getFileListButton.isEnabled = false
        getFileListButton.alpha = 0.5

        // 调用SDK下载文件
        BCLRingManager.shared.getFileData(fileName: fileName) { [weak self] res in
            guard let self = self, self.isDownloading else { return }

            switch res {
            case let .success(response):
//                BDLogger.info("获取文件数据成功")
//                BDLogger.info("文件数据-状态: \(response.fileSystemStatus ?? 0)")
                BDLogger.info("文件数据-大小: \(response.fileSize ?? 0)")
                BDLogger.info("文件数据-总包数: \(response.totalNumber ?? 0)")
                BDLogger.info("文件数据-当前包号: \(response.currentNumber ?? 0)")
//                BDLogger.info("文件数据-当前包长度: \(response.currentLength ?? 0)")

                // 更新总包数
                if let totalNumber = response.totalNumber, self.downloadTotalPackages == 0 {
                    self.downloadTotalPackages = totalNumber
                }

                // 更新当前包号
                if let currentNumber = response.currentNumber {
                    self.downloadCurrentPackage = currentNumber
                }

                // 收集ADPCM数据（类型8）
                if let adpcmData = response.fileDataType8 {
                    // 保存原始ADPCM数据（用于调试）
                    self.collectedRawAdpcmData.append(adpcmData)

                    // 解码立体声ADPCM数据
                    // 交错格式：左0字节,右0字节,左1字节,右1字节...
                    // 每声道ADPCM字节数 = adpcmData.count / 2
                    // 每个ADPCM字节包含2个4位样本
                    // 每声道样本数 = (adpcmData.count / 2) * 2 = adpcmData.count
                    let sampleCountPerChannel = adpcmData.count

                    if let pcmData = BCLRingManager.shared.decodeStereoAdpcm(adpcmData: adpcmData, sampleCount: sampleCountPerChannel) {
                        self.collectedPcmData.append(pcmData)
                        BDLogger.info("解码成功，PCM数据大小: \(pcmData.count)字节，累计: \(self.collectedPcmData.count)字节")
                    } else {
                        BDLogger.error("立体声ADPCM解码失败")
                    }
                }

                // 更新进度UI
                DispatchQueue.main.async {
                    let progress = Float(self.downloadCurrentPackage) / Float(max(self.downloadTotalPackages, 1))
                    self.progressView.progress = progress
                    let percentage = Int(progress * 100)
                    self.progressLabel.text = "下载中: \(self.downloadCurrentPackage)/\(self.downloadTotalPackages) 包 (\(percentage)%)"
                }

                // 检查是否下载完成
                if self.downloadCurrentPackage >= self.downloadTotalPackages {
                    self.downloadCompleted()
                }

            case let .failure(error):
                BDLogger.error("获取文件数据失败: \(error)")
                DispatchQueue.main.async {
                    self.resetDownloadState()
                    self.showAlert(title: "下载失败", message: error.localizedDescription)
                }
            }
        }
    }

    private func downloadCompleted() {
        BDLogger.info("文件下载完成，原始ADPCM: \(collectedRawAdpcmData.count) 字节，解码后PCM: \(collectedPcmData.count) 字节")

        // 调用SDK传输完成方法
        BCLRingManager.shared.adpcmTransferFinish()

        // 保存音频文件（同时保存ADPCM、PCM和WAV）
        saveAllAudioFiles()

        DispatchQueue.main.async {
            self.resetDownloadState()
            self.loadAudioFileList()
            self.showAlert(title: "完成", message: "音频文件已解码并保存")
        }
    }

    private func cancelDownload() {
        BDLogger.info("取消下载")
        BCLRingManager.shared.adpcmTransferFinish()
        resetDownloadState()
    }

    private func resetDownloadState() {
        isDownloading = false
        currentDownloadFileName = nil
        downloadTotalPackages = 0
        downloadCurrentPackage = 0
        collectedPcmData = Data()
        collectedRawAdpcmData = Data()

        progressContainerView.isHidden = true
        getFileListButton.isEnabled = true
        getFileListButton.alpha = 1.0
    }

    // MARK: - 保存立体声音频文件

    private func saveAllAudioFiles() {
        guard !collectedPcmData.isEmpty else {
            BDLogger.error("PCM数据为空")
            return
        }

        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let deviceMac = BCLRingManager.shared.currentConnectedDevice?.macAddress ?? "unknown"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = dateFormatter.string(from: Date())
        let baseFileName = "stereo_\(deviceMac)_\(dateString)"

        // 1. 保存原始ADPCM文件（用于调试）
        if !collectedRawAdpcmData.isEmpty {
            let adpcmFileName = "\(baseFileName).adpcm"
            let adpcmFilePath = (documentPath as NSString).appendingPathComponent(adpcmFileName)
            do {
                try collectedRawAdpcmData.write(to: URL(fileURLWithPath: adpcmFilePath))
                BDLogger.info("原始ADPCM文件已保存: \(adpcmFilePath), 大小: \(collectedRawAdpcmData.count)字节")
            } catch {
                BDLogger.error("保存ADPCM文件失败: \(error)")
            }
        }

        // 2. 保存解码后的PCM文件
        let pcmFileName = "\(baseFileName).pcm"
        let pcmFilePath = (documentPath as NSString).appendingPathComponent(pcmFileName)
        do {
            try collectedPcmData.write(to: URL(fileURLWithPath: pcmFilePath))
            BDLogger.info("立体声PCM文件已保存: \(pcmFilePath), 大小: \(collectedPcmData.count)字节")
        } catch {
            BDLogger.error("保存PCM文件失败: \(error)")
        }

        // 3. 保存WAV文件（带文件头，可直接播放）
        let wavFileName = "\(baseFileName).wav"
        let wavFilePath = (documentPath as NSString).appendingPathComponent(wavFileName)
        let wavData = createStereoWAVData(from: collectedPcmData)
        do {
            try wavData.write(to: URL(fileURLWithPath: wavFilePath))
            BDLogger.info("立体声WAV文件已保存: \(wavFilePath), 大小: \(wavData.count)字节")
        } catch {
            BDLogger.error("保存WAV文件失败: \(error)")
        }
    }

    private func createStereoWAVData(from pcmData: Data) -> Data {
        var wavData = Data()

        // WAV文件头（立体声配置）
        let byteRate = stereoSampleRate * UInt32(stereoChannels) * UInt32(stereoBitsPerSample) / 8
        let blockAlign = stereoChannels * stereoBitsPerSample / 8
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
        var channelsCopy = stereoChannels
        withUnsafeBytes(of: channelsCopy.littleEndian) { wavData.append(Data($0)) }
        var sampleRateCopy = stereoSampleRate
        withUnsafeBytes(of: sampleRateCopy.littleEndian) { wavData.append(Data($0)) }
        var byteRateCopy = byteRate
        withUnsafeBytes(of: byteRateCopy.littleEndian) { wavData.append(Data($0)) }
        var blockAlignCopy = blockAlign
        withUnsafeBytes(of: blockAlignCopy.littleEndian) { wavData.append(Data($0)) }
        var bitsPerSampleCopy = stereoBitsPerSample
        withUnsafeBytes(of: bitsPerSampleCopy.littleEndian) { wavData.append(Data($0)) }

        // data子块
        wavData.append("data".data(using: .ascii)!)
        var dataSizeCopy = dataSize
        withUnsafeBytes(of: dataSizeCopy.littleEndian) { wavData.append(Data($0)) }
        wavData.append(pcmData)

        return wavData
    }

    // MARK: - 加载音频文件列表

    private func loadAudioFileList() {
        audioFileList.removeAll()

        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default

        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentPath)

            for file in files {
                // 只加载立体声WAV文件（以stereo_开头）
                if file.hasPrefix("stereo_") && file.hasSuffix(".wav") {
                    let filePath = (documentPath as NSString).appendingPathComponent(file)

                    if let attributes = try? fileManager.attributesOfItem(atPath: filePath) {
                        let fileSize = attributes[.size] as? Int64 ?? 0
                        let createDate = attributes[.creationDate] as? Date ?? Date()

                        // 计算音频时长（立体声：采样率16000Hz，双声道，16位）
                        let dataSize = max(fileSize - 44, 0) // 减去WAV文件头
                        let bytesPerSecond = Double(stereoSampleRate) * Double(stereoChannels) * Double(stereoBitsPerSample) / 8
                        let duration = Double(dataSize) / bytesPerSecond

                        let audioInfo = StereoAudioFileInfo(
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

    private func playWAVFile(_ filePath: String) {
        // 如果正在播放同一个文件，则停止
        if currentPlayingFilePath == filePath {
            stopAudioPlayback()
            return
        }

        // 停止之前的播放
        stopAudioPlayback()

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
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

    private func stopAudioPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentPlayingFilePath = nil
        tableView.reloadData()
    }

    // MARK: - Helper Methods

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension StereoAdpcmDecode_VC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFileList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StereoAudioFileCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "StereoAudioFileCell")
        let audioInfo = audioFileList[indexPath.row]

        // 格式化文件大小
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        let sizeString = formatter.string(fromByteCount: audioInfo.fileSize)

        // 格式化时长
        let minutes = Int(audioInfo.duration) / 60
        let seconds = Int(audioInfo.duration) % 60
        let durationString = String(format: "%02d:%02d", minutes, seconds)

        // 配置cell（兼容iOS 13）
        cell.textLabel?.text = audioInfo.fileName
        cell.detailTextLabel?.text = "\(durationString) | \(sizeString) | 立体声"

        // 如果正在播放这个文件，显示播放图标
        if currentPlayingFilePath == audioInfo.filePath {
            cell.accessoryView = UIImageView(image: UIImage(systemName: "speaker.wave.2.fill"))
            cell.accessoryView?.tintColor = .systemBlue
        } else {
            cell.accessoryView = UIImageView(image: UIImage(systemName: "play.circle"))
            cell.accessoryView?.tintColor = .systemGray
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension StereoAdpcmDecode_VC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let audioInfo = audioFileList[indexPath.row]
        playWAVFile(audioInfo.filePath)
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
                BDLogger.info("已删除文件: \(audioInfo.fileName)")
            } catch {
                showAlert(title: "删除失败", message: error.localizedDescription)
            }
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension StereoAdpcmDecode_VC: AVAudioPlayerDelegate {
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
