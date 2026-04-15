//
//  FileSystem_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/27.
//  文件系统功能模块（381-400）
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 文件系统功能模块（381-400） -  获取文件列表、文件数据等
class FileSystem_Module: BaseFunction_Module {
    // MARK: - Properties

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
        default:
            showError("未知功能ID: \(id)")
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
        BCLRingManager.shared.getFileData(fileName: fileName) { res in
            switch res {
            case let .success(response):
                BDLogger.info("获取文件数据成功: \(response)")
                BDLogger.info("文件数据-状态: \(response.fileSystemStatus ?? 0)")
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
                BDLogger.error("获取文件数据失败: \(error)")
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
    }

    // 387 - 一键获取全部文件数据
    private func getAllFileData() {
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
                BDLogger.error("请求文件数据断点续传失败: \(error)")
                self.showError("请求文件数据断点续传失败: \(error.localizedDescription)")
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
        // 设置下载按钮回调
        fileListDialog.downloadButtonCallback = { [weak self] selectedFiles in
            guard let self = self else { return }
            guard !selectedFiles.isEmpty else {
                BDLogger.warning("未选择任何文件进行下载")
                return
            }
            BDLogger.info("开始下载选中的文件，共 \(selectedFiles.count) 个")
            // 此处因为指令是队列执行的，所以可以直接循环调用
            for fileName in selectedFiles {
                BDLogger.info("选中文件: \(fileName)")
                self.getFileData(fileName: fileName)
            }
        }
        let modalPresentation_VC = QMUIModalPresentationViewController()
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
