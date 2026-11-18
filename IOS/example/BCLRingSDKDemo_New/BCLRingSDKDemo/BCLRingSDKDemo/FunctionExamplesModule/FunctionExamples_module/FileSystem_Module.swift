//
//  FileSystem_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/27.
//  文件系统功能模块（381-400）
//

import BCLRingSDK
import QMUIKit
import RxSwift
import UIKit

/// 文件系统功能模块（381-400） -  获取文件列表、文件数据等
class FileSystem_Module: BaseFunction_Module {
    // MARK: - Properties

    /// 模块拥有的推送订阅；取消监听不影响其他业务的 Block 或 Observable。
    private var fileDownloadStateSubscription: Disposable?
    /// 避免重复点击覆盖本模块控制请求的加载提示。
    private var isControllingFileDownload = false

    deinit {
        fileDownloadStateSubscription?.dispose()
    }

    /// 文件列表缓存
    private var collectedFiles: [FileInfoModel] = []
    /// 期望的文件总数
    private var expectedFileCount: Int = 0
    /// 时间戳展示格式化器
    private lazy var timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 381 ... 400)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 381: // 381 - 获取文件系统空间信息
            getFileSystemSpaceInfo()
        case 382: // 382 - 获取文件系统状态
            getFileSystemStatus()
        case 383: // 383 - 格式化文件系统
            formatFileSystem()
        case 384: // 384 - 获取文件列表
            getFileList()
        case 385: // 385 - 获取指定文件数据
            configGetFileDataNameDialog()
        case 386: // 386 - 删除指定文件数据
            deleteFileData()
        case 387: // 387 - 获取全部文件数据
            getAllFileData()
        case 388: // 388 - 开始采集数据（部分固件支持）
            startSportMode()
        case 389: // 389 - 采集数据配置信息获取（部分固件支持）
            getStartSportModeConfigInfo()
        case 390: // 390 - 请求文件数据断点续传
            showRequestFileDataResumeDialog()
        case 391: // 391 - 暂停文件下载
            controlFileDownload(action: .pause)
        case 392: // 392 - 恢复文件下载（不是带偏移量的断点续传）
            controlFileDownload(action: .resume)
        case 393: // 393 - 取消文件下载（不删除设备文件）
            controlFileDownload(action: .cancel)
        case 394: // 394 - 开启下载状态推送监听
            startFileDownloadStateListening()
        case 395: // 395 - 取消下载状态推送监听
            stopFileDownloadStateListening()
        case 396: // 396 - 设置文件系统录制存储模式
            showSetFileSystemRecordingModeDialog()
        case 397: // 397 - 查询文件系统录制存储模式
            getFileSystemRecordingMode()
        case 398: // 398 - 读取异常日志
            readAbnormalLog()
        case 399: // 399 - 删除异常日志
            confirmDeleteAbnormalLog()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - 文件下载控制与主动推送

    /// 发送 0x3627，等待设备执行结果；下载状态和控制请求结果是独立通道。
    private func controlFileDownload(action: BCLFileDownloadControlAction) {
        guard !isControllingFileDownload else {
            showError("正在等待下载控制结果，请稍后再试")
            return
        }
        isControllingFileDownload = true
        let name = fileDownloadActionDescription(action)
        BDLogger.info("发送文件下载控制：\(name)")
        showLoading("正在\(name)文件下载...", userInteractionEnabled: false)
        BCLRingManager.shared.controlFileDownload(action: action) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isControllingFileDownload = false
                self.hideLoading()
                switch result {
                case let .success(response):
                    if response.status == 1 {
                        BDLogger.info("设备已执行文件下载控制：\(name)")
                        self.showSuccess("设备已执行\(name)下载")
                    } else {
                        BDLogger.warning("设备拒绝文件下载控制：\(name)")
                        self.showError("设备执行\(name)下载失败")
                    }
                case let .failure(error):
                    BDLogger.error("文件下载控制失败：\(error)")
                    self.showError("\(name)下载失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 监听 0x3628；原因 1 为录音，事件不包含文件名或文件 ID。
    private func startFileDownloadStateListening() {
        fileDownloadStateSubscription?.dispose()
        // Block 用法：BCLRingManager.shared.fileDownloadStatePushBlock = { response in ... }
        // Block 取消：将 fileDownloadStatePushBlock 置 nil。本示例仅管理自己的 Rx 订阅。
        fileDownloadStateSubscription = BCLRingManager.shared.fileDownloadStatePushObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                let action = response.action.map(self.fileDownloadActionDescription)
                    ?? "未知动作(\(response.actionRawValue.map(String.init) ?? "无"))"
                let reason = response.reason == .recording
                    ? "录音" : "未知原因(\(response.reasonRawValue.map(String.init) ?? "无"))"
                let message = "戒指推送：\(action)下载，原因：\(reason)"
                BDLogger.info(message)
                self.showSuccess(message)
            })
        BDLogger.info("已开启文件下载状态推送监听")
        showSuccess("已开启文件下载状态推送监听")
    }

    /// 仅释放本模块订阅，不改变下载状态或其他调用方的监听。
    private func stopFileDownloadStateListening() {
        fileDownloadStateSubscription?.dispose()
        fileDownloadStateSubscription = nil
        BDLogger.info("已取消文件下载状态推送监听")
        showSuccess("已取消文件下载状态推送监听")
    }

    private func fileDownloadActionDescription(_ action: BCLFileDownloadControlAction) -> String {
        switch action {
        case .pause: return "暂停"
        case .resume: return "恢复"
        case .cancel: return "取消"
        }
    }

    /// 原下载回调的取消是正常终止，不应显示为设备故障。
    private func handleFileDownloadError(_ error: BCLError) {
        DispatchQueue.main.async { [weak self] in
            if case .commandSending(.cancelled) = error {
                BDLogger.info("当前文件下载已取消，设备文件保留")
                self?.showSuccess("当前文件下载已取消")
            } else {
                BDLogger.error("文件下载失败：\(error)")
                self?.showError("文件下载失败：\(error.localizedDescription)")
            }
        }
    }

    // MARK: - Private Methods

    // 381 - 获取文件系统空间信息
    private func getFileSystemSpaceInfo() {
        BCLRingManager.shared.getFileSystemInfo { res in
            switch res {
            case let .success(response):
                BDLogger.info("获取文件系统空间信息成功: \(response)")
                BDLogger.info("文件系统空间信息-总空间: \(response.totalSize ?? 0)")
                BDLogger.info("文件系统空间信息-可用空间: \(response.freeSize ?? 0)")
                BDLogger.info("文件系统空间信息-已用空间: \(response.usedSize ?? 0)")
                self.showInfoAlert(message: "总空间：\(response.totalSize ?? 0)\n可用空间：\(response.freeSize ?? 0)\n已用空间：\(response.usedSize ?? 0)")

            case let .failure(error):
                BDLogger.error("获取文件系统空间信息失败: \(error)")
                self.showError("获取文件系统空间信息失败: \(error)")
            }
        }
    }

    // 382 - 获取文件系统状态
    private func getFileSystemStatus() {
        BCLRingManager.shared.getFileSystemStatus { res in
            switch res {
            case let .success(response):
                var message = ""
                BDLogger.info("获取文件系统状态成功: \(response)")
                if let status = response.status, status == 0 {
                    BDLogger.info("文件系统状态: 空闲")
                    message = "文件系统状态: 空闲"
                } else if let status = response.status, status == 1 {
                    BDLogger.info("文件系统状态: 上传文件状态")
                    message = "文件系统状态: 上传文件状态"
                } else if let status = response.status, status == 2 {
                    BDLogger.info("文件系统状态: 写状态")
                    message = "文件系统状态: 写状态"
                } else if let status = response.status, status == 3 {
                    BDLogger.info("文件系统状态: 忙")
                    message = "文件系统状态: 忙"
                } else {
                    BDLogger.info("未知的文件系统状态")
                    message = "未知的文件系统状态"
                }
                self.showInfoAlert(message: message)
            case let .failure(error):
                BDLogger.error("获取文件系统状态失败: \(error)")
                self.showError("获取文件系统状态失败: \(error)")
            }
        }
    }

    // 396 - 设置文件系统录制存储模式
    private func showSetFileSystemRecordingModeDialog() {
        guard let viewController = viewController else { return }
        let alert = UIAlertController(title: "设置录制存储模式",
                                      message: "请选择文件系统录满后的录制行为",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "循环覆盖", style: .default) { [weak self] _ in
            self?.setFileSystemRecordingMode(.loopOverwrite)
        })
        alert.addAction(UIAlertAction(title: "录满停止", style: .default) { [weak self] _ in
            self?.setFileSystemRecordingMode(.stopWhenFull)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController.present(alert, animated: true)
    }

    /// 设置文件系统录制存储模式，并区分设备拒绝与通信失败。
    private func setFileSystemRecordingMode(_ mode: BCLFileSystemRecordingMode) {
        let modeDescription = fileSystemRecordingModeDescription(mode)
        BCLRingManager.shared.setFileSystemRecordingMode(mode) { [weak self] result in
            switch result {
            case let .success(response):
                if response.isSuccess {
                    BDLogger.info("设置文件系统录制存储模式成功：\(modeDescription)")
                    self?.showSuccess("已设置为\(modeDescription)")
                } else {
                    BDLogger.error("设备拒绝设置文件系统录制存储模式：\(modeDescription)")
                    self?.showError("设备拒绝设置\(modeDescription)")
                }
            case let .failure(error):
                BDLogger.error("设置文件系统录制存储模式失败：\(error)")
                self?.showError("设置录制存储模式失败：\(error)")
            }
        }
    }

    // 397 - 查询文件系统录制存储模式
    private func getFileSystemRecordingMode() {
        BCLRingManager.shared.getFileSystemRecordingMode { [weak self] result in
            switch result {
            case let .success(response):
                guard let mode = response.mode else {
                    self?.showError("文件系统录制存储模式无效")
                    return
                }
                let modeDescription = self?.fileSystemRecordingModeDescription(mode) ?? "未知模式"
                BDLogger.info("当前文件系统录制存储模式：\(modeDescription)")
                self?.showInfoAlert(title: "录制存储模式", message: "当前模式：\(modeDescription)")
            case let .failure(error):
                BDLogger.error("查询文件系统录制存储模式失败：\(error)")
                self?.showError("查询录制存储模式失败：\(error)")
            }
        }
    }

    /// 返回录制存储模式的中文展示文本。
    private func fileSystemRecordingModeDescription(_ mode: BCLFileSystemRecordingMode) -> String {
        switch mode {
        case .loopOverwrite:
            return "循环覆盖"
        case .stopWhenFull:
            return "录满停止"
        }
    }

    // 398 - 读取异常日志
    /// 读取 0x36/0x25，展示完整日志并演示由客户 App 将内容保存到自身沙盒。
    private func readAbnormalLog() {
        BCLRingManager.shared.readAbnormalLog { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(response):
                    guard let timestamp = response.timestamp,
                          let date = response.date,
                          let content = response.logContent else {
                        BDLogger.error("读取异常日志失败：响应字段为空")
                        self.showError("读取异常日志失败：响应字段为空")
                        return
                    }
                    let localTime = self.timestampFormatter.string(from: date)
                    let displayContent = content.isEmpty ? "（无日志内容）" : content
                    let totalPacketCount = response.totalPacketCount ?? 0
                    do {
                        let fileURL = try self.saveAbnormalLog(content: content, timestamp: timestamp)
                        BDLogger.info("读取异常日志成功，本地时间：\(localTime)，时间戳：\(timestamp)，总包数：\(totalPacketCount)，保存路径：\(fileURL.path)，内容：\(displayContent)")
                        self.showInfoAlert(title: "异常日志已保存",
                                           message: "本地时间：\(localTime)\n时间戳：\(timestamp)\n总包数：\(totalPacketCount)\n保存路径：\(fileURL.path)\n\n\(displayContent)")
                    } catch {
                        BDLogger.error("异常日志读取成功但保存失败：\(error)，内容：\(displayContent)")
                        self.showInfoAlert(title: "异常日志读取成功，保存失败",
                                           message: "本地时间：\(localTime)\n时间戳：\(timestamp)\n总包数：\(totalPacketCount)\n保存错误：\(error.localizedDescription)\n\n\(displayContent)")
                    }
                case let .failure(error):
                    BDLogger.error("读取异常日志失败：\(error)")
                    self.showError("读取异常日志失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 将完整日志保存到 Documents/AbnormalLogs；同名文件通过递增后缀避免覆盖。
    private func saveAbnormalLog(content: String, timestamp: UInt32) throws -> URL {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "BCLRingSDKDemo.AbnormalLog",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "无法获取 App Documents 目录"])
        }

        let directoryURL = documentsURL.appendingPathComponent("AbnormalLogs", isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let baseName = "abnormal_log_\(timestamp)"
        var fileURL = directoryURL.appendingPathComponent("\(baseName).log")
        var suffix = 1
        while fileManager.fileExists(atPath: fileURL.path) {
            fileURL = directoryURL.appendingPathComponent("\(baseName)_\(suffix).log")
            suffix += 1
        }
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    // 399 - 删除异常日志
    /// 删除不可恢复，发送 0x36/0x26 前必须由用户二次确认。
    private func confirmDeleteAbnormalLog() {
        guard let viewController = viewController else { return }
        let alert = UIAlertController(title: "删除异常日志",
                                      message: "删除后无法恢复，确定继续吗？",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.deleteAbnormalLog()
        })
        viewController.present(alert, animated: true)
    }

    /// 用户确认后执行异常日志删除命令。
    private func deleteAbnormalLog() {
        BCLRingManager.shared.deleteAbnormalLog { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(response):
                    guard response.isSuccess else {
                        BDLogger.error("删除异常日志失败：设备未确认执行")
                        self.showError("删除异常日志失败：设备未确认执行")
                        return
                    }
                    BDLogger.info("异常日志已删除")
                    self.showSuccess("异常日志已删除")
                case let .failure(error):
                    BDLogger.error("删除异常日志失败：\(error)")
                    self.showError("删除异常日志失败：\(error.localizedDescription)")
                }
            }
        }
    }

    // 383 - 格式化文件系统
    private func formatFileSystem() {
        BCLRingManager.shared.formatFileSystem { res in
            switch res {
            case let .success(response):
                if let result = response.formatResult, result == 1 {
                    BDLogger.info("格式化文件系统成功: \(response)")
                    self.showSuccess("格式化文件系统成功")
                } else {
                    BDLogger.info("格式化文件系统失败: \(response)")
                    self.showError("格式化文件系统失败")
                }
            case let .failure(error):
                BDLogger.error("格式化文件系统失败: \(error)")
                self.showError("格式化文件系统失败: \(error)")
            }
        }
    }

    // 384 - 获取文件列表
    private func getFileList() {
        // 清空之前的缓存
        collectedFiles.removeAll()
        expectedFileCount = 0

        BCLRingManager.shared.getFileList { [weak self] res in
            guard let self = self else { return }

            switch res {
            case let .success(response):
                BDLogger.info("获取文件系统列表成功: \(response)")
                BDLogger.info("文件系统列表-总个数: \(response.fileTotalCount ?? 0)")
                BDLogger.info("文件系统列表-当前索引: \(response.fileIndex ?? 0)")
                BDLogger.info("文件系统列表-文件大小: \(response.fileSize ?? 0)")
                BDLogger.info("文件系统列表-用户ID: \(response.userId ?? "")")
                BDLogger.info("文件系统列表-日期: \(response.fileDate ?? "")")
                BDLogger.info("文件系统列表-文件名: \(response.fileName ?? "")")
                BDLogger.info("文件系统列表-文件类型: \(response.fileType ?? "")")

                // 记录期望的文件总数
                if let totalCount = response.fileTotalCount, self.expectedFileCount == 0 {
                    self.expectedFileCount = totalCount
                    // 如果没有文件，直接提示
                    if totalCount == 0 {
                        self.showInfoAlert(message: "文件系统中没有文件")
                        return
                    }
                }

                // 收集文件信息
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
                        // 弹出文件列表 Dialog
                        self.showFileListDialog()
                    }
                }

            case let .failure(error):
                BDLogger.error("获取文件系统列表失败: \(error)")
                self.showError("获取文件系统列表失败: \(error)")
            }
        }
    }

    // 385 - 获取指定文件数据
    private func getFileData(fileName: String) {
        BCLRingManager.shared.getFileData(fileName: fileName) { [weak self] res in
            switch res {
            case let .success(response):
                BDLogger.info("获取文件数据成功: \(response)")
                BDLogger.info("文件数据-状态: \(response.fileSystemStatus ?? 0)")
                if response.fileSystemStatus == 2 {
                    let message = "获取文件数据失败：文件系统正在写入，请稍后重试"
                    BDLogger.error(message)
                    self?.showError(message)
                    return
                }
                if response.fileSystemStatus == 3 {
                    let message = "获取文件数据失败：文件系统繁忙，请稍后重试"
                    BDLogger.error(message)
                    self?.showError(message)
                    return
                }
                if response.fileSystemStatus == 4 {
                    let message = "获取文件数据失败：文件大小错误"
                    BDLogger.error(message)
                    self?.showError(message)
                    return
                }
                BDLogger.info("文件数据-大小: \(response.fileSize ?? 0)")
                BDLogger.info("文件数据-总包数: \(response.totalNumber ?? 0)")
                BDLogger.info("文件数据-当前包号: \(response.currentNumber ?? 0)")
                BDLogger.info("文件数据-当前包长度: \(response.currentLength ?? 0)")
                let typeCode = (response.rawFileType?.rawValue ?? response.fileType ?? "").uppercased()
                guard !typeCode.isEmpty else {
                    BDLogger.info("未知的文件类型")
                    return
                }

                func logBinaryAudio(_ data: Data?, label: String) {
                    if let data = data {
                        let preview = data.map { String(format: "%02x", $0) }
                        BDLogger.info("文件数据:\(label)，大小:\(data.count)字节，字节内容:\(preview)")
                    } else {
                        BDLogger.info("文件数据:\(label)：无数据")
                    }
                }

                switch typeCode {
                case "1": BDLogger.info("文件数据:三轴数据-数据：\(response.fileDataType1 ?? [])")
                case "2": BDLogger.info("文件数据:六轴数据-数据：\(response.fileDataType2 ?? [])")
                case "3": BDLogger.info("文件数据:PPG数据红外+红色+x加速度+y加速度+z加速度-数据：\(response.fileDataType3 ?? [])")
                case "4":
                    // PPG数据绿色+三轴(HR)  (时间戳ms, [(绿色, 加速度X, 加速度Y, 加速度Z)]))
                    BDLogger.info("文件数据:PPG数据绿色+三轴(HR)-时间戳：\(response.fileDataType4?.0 ?? 0)")
                    BDLogger.info("文件数据:PPG数据绿色+三轴(HR)-数据：\(response.fileDataType4?.1 ?? [])")

                case "5": BDLogger.info("文件数据:PPG数据红外-数据：\(response.fileDataType5 ?? [])")
                case "6": BDLogger.info("文件数据:温度数据红外-数据：\(response.fileDataType6 ?? [])")
                case "7":
                    // (时间戳,[(绿色+红色+红外+加速度X+加速度Y+加速度Z+陀螺仪X+陀螺仪Y+陀螺仪Z+温度0+温度1+温度2)])
                    BDLogger.info("文件内容----时间戳：\(response.fileDataType7?.0 ?? 0)")
                    BDLogger.info("文件内容----数据：\(response.fileDataType7?.1 ?? [])")
                case "8":
                    logBinaryAudio(response.fileDataType8, label: "adpcm音频")
                case "B":
                    logBinaryAudio(response.fileDataTypeB, label: "按键捕获adpcm音频")
                case "D":
                    logBinaryAudio(response.fileDataTypeD, label: "adpcm 8K单麦音频")
                case "9":
                    logBinaryAudio(response.fileDataType9, label: "opus音频")
                case "C":
                    logBinaryAudio(response.fileDataTypeC, label: "按键捕获opus音频")
                case "E":
                    logBinaryAudio(response.fileDataTypeE, label: "opus 8K单麦音频")
                case "10", "A":
                    if let climbingData = response.fileDataType10 {
                        for (macAddress, utcTime, laccValue) in climbingData {
                            BDLogger.info("文件数据:攀岩项目数据，MAC:\(macAddress)，时间:\(utcTime)，LACC:\(laccValue)")
                        }
                    } else {
                        BDLogger.info("文件数据:攀岩项目数据：无数据")
                    }
                default:
                    BDLogger.info("未知的文件类型")
                }
            case let .failure(error):
                self?.handleFileDownloadError(error)
            }
        }
//        // 弹出输入框让用户输入文件名
//        showInputAlert(title: "获取文件数据", message: "请输入文件名", placeholder: "例如: 010203040506_2025_08_25_16_30_37_7.txt") { [weak self] fileName in
//            guard let self = self, let fileName = fileName, !fileName.isEmpty else {
//                BDLogger.warning("文件名不能为空")
//                return
//            }
//            self.downloadFile(fileName: fileName)
//        }
    }

    // 386 - 删除指定文件数据
    private func deleteFileData() {
        guard let viewController = viewController else { return }

        let alert = UIAlertController(
            title: "删除文件",
            message: "请输入要删除的文件名",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "例如：010203040506_2025_6_18:13:45:20_3.txt"
        }

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确认", style: .default) { [weak self, weak alert] _ in
            guard let self = self else { return }
            guard let fileName = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !fileName.isEmpty
            else {
                self.showError("文件名不能为空")
                return
            }

            self.deleteFile(fileName: fileName)
        })

        viewController.present(alert, animated: true)
    }

    /// 删除指定文件
    /// - Parameter fileName: 文件名
    private func deleteFile(fileName: String) {
        BCLRingManager.shared.deleteFile(fileName: fileName) { [weak self] res in
            guard let self = self else { return }

            switch res {
            case let .success(response):
                switch response.resultStatus {
                case .success:
                    BDLogger.info("删除文件成功: \(fileName), result=\(response.deleteResult ?? -1)")
                    self.showSuccess("删除文件成功")
                case .failure:
                    BDLogger.info("删除文件失败: \(fileName), result=\(response.deleteResult ?? -1)")
                    self.showError("删除文件失败")
                case .fileBusy:
                    BDLogger.info("删除文件失败，文件繁忙: \(fileName), result=\(response.deleteResult ?? -1)")
                    self.showError("文件繁忙，请稍后重试")
                case .unknown:
                    BDLogger.info("删除文件返回未知结果: \(fileName), result=\(response.deleteResult ?? -1)")
                    self.showError("删除文件返回未知结果")
                }

            case let .failure(error):
                BDLogger.error("删除文件失败: \(fileName), error=\(error)")
                self.showError("删除文件失败: \(error.localizedDescription)")
            }
        }
    }

    // 387 - 一键获取全部文件数据
    /// 一键上传从指定文件序号开始，供暂停/恢复/取消示例联动验证。
    private func getAllFileData() {
        let alert = UIAlertController(title: "获取全部文件数据", message: "请输入起始文件序号（0...255）", preferredStyle: .alert)
        alert.addTextField { field in
            field.text = "0"
            field.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "开始下载", style: .default) { [weak self, weak alert] _ in
            guard let self = self else { return }
            guard let text = alert?.textFields?.first?.text, let index = Int(text), (0...255).contains(index) else {
                self.showError("文件序号必须为0...255")
                return
            }
            // 不使用阻塞交互的持续加载态，传输中仍可点击下载控制入口。
            BCLRingManager.shared.requestFileDataOneKey(fileIndex: index) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(response):
                    guard let type = response.responseType else { return }
                    switch type {
                    case let .fileDataOneKey(status, _, _):
                        BDLogger.info("一键下载状态：\(status)，0忙、1开始、2完成、3序号无效")
                    case let .fileDataOneKeyProgress(progress):
                        BDLogger.info("一键下载总进度：\(progress)%")
                    case let .fileResponse(index, status, _, _, name):
                        BDLogger.info("一键下载文件：\(name)，序号：\(index)，状态：\(status)")
                    case let .fileProgress(index, progress):
                        BDLogger.info("文件\(index)下载进度：\(progress)%")
                    case .fileContentData:
                        BDLogger.debug("收到一键下载文件内容")
                    }
                case let .failure(error):
                    self.handleFileDownloadError(error)
                }
            }
        })
        viewController?.present(alert, animated: true)
    }

    // 388 - 开始采集数据（部分固件支持）
    private func startSportMode() {
        showStartSportModeConfigDialog()
    }

    // 389 - 采集数据配置信息获取（部分固件支持）
    private func getStartSportModeConfigInfo() {
        BCLRingManager.shared.getTimedStartSportMode { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                let collectionMode = response.collectionMode ?? -1
                let startTime = response.startTime ?? 0
                let endTime = response.endTime ?? 0

                BDLogger.info("获取定时启动运动采集配置成功: \(response)")
                BDLogger.info("采集模式: \(collectionMode)")
                BDLogger.info("开始时间: \(startTime)")
                BDLogger.info("结束时间: \(endTime)")

                let message = """
                采集模式：\(self.collectionModeDescription(collectionMode))
                开始时间：\(self.formatTimestamp(startTime))
                结束时间：\(self.formatTimestamp(endTime))
                """
                self.showInfoAlert(title: "采集配置", message: message)

            case let .failure(error):
                BDLogger.error("获取定时启动运动采集配置失败: \(error)")
                self.showError("获取采集配置失败: \(error.localizedDescription)")
            }
        }
    }

    // 390 - 请求文件数据断点续传
    private func requestFileDataResume(fileOffset: Int32, fileName: String) {
        BCLRingManager.shared.requestFileDataResume(fileOffset: fileOffset, fileName: fileName) { [weak self] res in
            guard let self = self else { return }
            switch res {
            case let .success(response):
                guard let responseType = response.responseType else {
                    BDLogger.warning("断点续传响应为空")
                    return
                }

                switch responseType {
                case let .fileDataResume(status, startTimestamp, endTimestamp):
                    BDLogger.info("断点续传状态响应(3618): status=\(status), start=\(startTimestamp), end=\(endTimestamp)")
                    if status == 2 {
                        self.showSuccess("断点续传完成")
                    }
                case let .fileDataResumeProgress(progress):
                    BDLogger.info("断点续传进度响应(3619): progress=\(progress)%")
                    if progress >= 100 {
                        self.showSuccess("断点续传进度100%，上传结束")
                    }
                case let .fileContentData(fileDataResponse):
                    let typeCode = (fileDataResponse.rawFileType?.rawValue ?? fileDataResponse.fileType ?? "").uppercased()
                    BDLogger.info("断点续传文件内容响应(3611): type=\(typeCode), total=\(fileDataResponse.totalNumber ?? 0), current=\(fileDataResponse.currentNumber ?? 0), length=\(fileDataResponse.currentLength ?? 0)")
                }

            case let .failure(error):
                self.handleFileDownloadError(error)
            }
        }
    }

    // MARK: - Dialog Methods

    /// 显示文件列表对话框
    private func showFileListDialog() {
        // 创建文件列表对话框
        let dialogWidth: CGFloat = UIScreen.main.bounds.width - 40
        let dialogHeight: CGFloat = UIScreen.main.bounds.height * 0.7
        let dialogX: CGFloat = 20
        let dialogY: CGFloat = (UIScreen.main.bounds.height - dialogHeight) / 2
        let fileListDialog = FileListDialog(x: dialogX, y: dialogY, width: dialogWidth, height: dialogHeight, files: collectedFiles)
        let modalPresentation_VC = QMUIModalPresentationViewController()
        // 设置下载按钮回调
        fileListDialog.downloadButtonCallback = { [weak self, weak modalPresentation_VC] selectedFiles in
            guard let self = self else { return }
            guard !selectedFiles.isEmpty else {
                BDLogger.warning("未选择任何文件进行下载")
                return
            }
            modalPresentation_VC?.hideWith(animated: true)
            BDLogger.info("开始下载选中的文件，共 \(selectedFiles.count) 个")
            // 此处因为指令是队列执行的，所以可以直接循环调用
            for fileName in selectedFiles {
                BDLogger.info("选中文件: \(fileName)")
                self.getFileData(fileName: fileName)
            }
        }
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = fileListDialog
        modalPresentation_VC.showWith(animated: true)
    }

    // 获取指定文件数据（预设文件名）Dialog
    private func configGetFileDataNameDialog() {
        // 创建文件名输入对话框
        let dialogWidth: CGFloat = UIScreen.main.bounds.width - 60
        let dialogHeight: CGFloat = 280.0
        let dialogX: CGFloat = 30
        let dialogY: CGFloat = (UIScreen.main.bounds.height - dialogHeight) / 2

        let inputDialog = FileNameInputDialog(x: dialogX, y: dialogY, width: dialogWidth, height: dialogHeight)

        // 设置确认按钮回调
        inputDialog.confirmButtonCallback = { [weak self] fileName in
            guard let self = self else { return }
            BDLogger.info("开始获取文件数据: \(fileName)")
            // 调用获取文件数据方法
            self.getFileData(fileName: fileName)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = inputDialog
        modalPresentation_VC.showWith(animated: true)
    }

    /// 断点续传参数输入Dialog
    private func showRequestFileDataResumeDialog() {
        guard let viewController = viewController else { return }

        let alert = UIAlertController(
            title: "文件断点续传",
            message: "请输入文件名与偏移量（字节）",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "文件名，例如：010203040506_2025_6_18:13:45:20_8.txt"
        }

        alert.addTextField { textField in
            textField.placeholder = "偏移量（Int32）"
            textField.text = "0"
            textField.keyboardType = .numbersAndPunctuation
        }

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确认", style: .default) { [weak self, weak alert] _ in
            guard let self = self else { return }
            guard let textFields = alert?.textFields, textFields.count == 2 else { return }

            guard let fileName = textFields[0].text?.trimmingCharacters(in: .whitespacesAndNewlines), !fileName.isEmpty else {
                self.showError("文件名不能为空")
                return
            }

            guard let offsetText = textFields[1].text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let offsetInt64 = Int64(offsetText),
                  offsetInt64 >= Int64(Int32.min), offsetInt64 <= Int64(Int32.max)
            else {
                self.showError("偏移量必须是 Int32 范围内的整数")
                return
            }

            let fileOffset = Int32(offsetInt64)
            BDLogger.info("开始请求断点续传，fileName=\(fileName), fileOffset=\(fileOffset)")
            self.requestFileDataResume(fileOffset: fileOffset, fileName: fileName)
        })

        viewController.present(alert, animated: true)
    }

    /// 开始采集参数配置对话框
    private func showStartSportModeConfigDialog() {
        guard let viewController = viewController else { return }

        let defaultStartTime = Int(Date().addingTimeInterval(10).timeIntervalSince1970)
        let defaultEndTime = Int(Date().addingTimeInterval(70).timeIntervalSince1970)

        let alert = UIAlertController(
            title: "开始信息采集参数",
            message: "采集模式: 0=周期采集, 1=连续采集\n开始/结束时间使用秒级时间戳",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "采集模式（0/1）"
            textField.text = "0"
            textField.keyboardType = .numberPad
        }

        alert.addTextField { textField in
            textField.placeholder = "开始时间（秒级时间戳）"
            textField.text = "\(defaultStartTime)"
            textField.keyboardType = .numbersAndPunctuation
        }

        alert.addTextField { textField in
            textField.placeholder = "结束时间（秒级时间戳）"
            textField.text = "\(defaultEndTime)"
            textField.keyboardType = .numbersAndPunctuation
        }

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确认", style: .default) { [weak self, weak alert] _ in
            guard let self = self else { return }
            guard let textFields = alert?.textFields, textFields.count == 3 else {
                self.showError("参数读取失败")
                return
            }

            guard let modeText = textFields[0].text,
                  let collectionMode = Int(modeText),
                  collectionMode == 0 || collectionMode == 1
            else {
                self.showError("采集模式仅支持 0 或 1")
                return
            }

            guard let startText = textFields[1].text,
                  let startTime = TimeInterval(startText),
                  let endText = textFields[2].text,
                  let endTime = TimeInterval(endText)
            else {
                self.showError("时间戳格式错误，请输入数字")
                return
            }

            guard endTime > startTime else {
                self.showError("结束时间必须大于开始时间")
                return
            }

            self.setTimedStartSportMode(collectionMode: collectionMode, startTime: startTime, endTime: endTime)
        })

        viewController.present(alert, animated: true)
    }

    /// 调用 SDK 设置定时启动运动采集
    private func setTimedStartSportMode(collectionMode: Int, startTime: TimeInterval, endTime: TimeInterval) {
        BDLogger.info("设置定时启动运动采集参数: mode=\(collectionMode), start=\(startTime), end=\(endTime)")
        BCLRingManager.shared.setTimedStartSportMode(collectionMode: collectionMode, startTime: startTime, endTime: endTime) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                let status = response.status ?? -1
                BDLogger.info("设置定时启动运动采集返回: \(response)")

                if status == 1 {
                    let message = """
                    设置成功
                    采集模式：\(self.collectionModeDescription(collectionMode))
                    开始时间：\(self.formatTimestamp(startTime))
                    结束时间：\(self.formatTimestamp(endTime))
                    """
                    self.showInfoAlert(title: "开始信息采集", message: message)
                } else {
                    self.showError("设置采集失败，状态码: \(status)")
                }

            case let .failure(error):
                BDLogger.error("设置定时启动运动采集失败: \(error)")
                self.showError("设置采集失败: \(error.localizedDescription)")
            }
        }
    }

    private func collectionModeDescription(_ mode: Int) -> String {
        switch mode {
        case 0:
            return "周期采集(0)"
        case 1:
            return "连续采集(1)"
        default:
            return "未知模式(\(mode))"
        }
    }

    private func formatTimestamp(_ timestamp: TimeInterval) -> String {
        guard timestamp > 0 else { return "0" }
        let date = Date(timeIntervalSince1970: timestamp)
        return "\(Int(timestamp)) (\(timestampFormatter.string(from: date)))"
    }
}
