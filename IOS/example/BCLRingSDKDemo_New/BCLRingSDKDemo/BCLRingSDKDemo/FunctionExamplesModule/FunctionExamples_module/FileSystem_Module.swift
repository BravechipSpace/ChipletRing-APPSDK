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
                guard let type = response.fileType else {
                    BDLogger.info("未知的文件类型")
                    return
                }
                switch type {
                case "1": BDLogger.info("文件数据:三轴数据-数据：\(response.fileDataType1 ?? [])")
                case "2": BDLogger.info("文件数据:六轴数据-数据：\(response.fileDataType2 ?? [])")
                case "3": BDLogger.info("文件数据:PPG数据红外+红色+x加速度+y加速度+z加速度-数据：\(response.fileDataType3 ?? [])")
                case "4": BDLogger.info("文件数据:PPG数据绿色-数据：\(response.fileDataType4 ?? [])")
                case "5": BDLogger.info("文件数据:PPG数据红外-数据：\(response.fileDataType5 ?? [])")
                case "6": BDLogger.info("文件数据:温度数据红外-数据：\(response.fileDataType6 ?? [])")
                case "7":
                    // (时间戳,[(绿色+红色+红外+加速度X+加速度Y+加速度Z+陀螺仪X+陀螺仪Y+陀螺仪Z+温度0+温度1+温度2)])
                    BDLogger.info("文件内容----时间戳：\(response.fileDataType7?.0 ?? 0)")
                    BDLogger.info("文件内容----数据：\(response.fileDataType7?.1 ?? [])")
                case "8":
                    // adpcm音频
                    if let data = response.fileDataType8 {
                        let preview = data.map { String(format: "%02x", $0) }
                        BDLogger.info("文件数据:adpcm音频，大小:\(data.count)字节，字节内容:\(preview)")
                    } else {
                        BDLogger.info("文件数据:adpcm音频：无数据")
                    }
                case "9":
                    // opus音频
                    if let data = response.fileDataType9 {
                        let preview = data.map { String(format: "%02x", $0) }
                        BDLogger.info("文件数据:opus音频，大小:\(data.count)字节，字节内容:\(preview)")
                    } else {
                        BDLogger.info("文件数据:opus音频：无数据")
                    }
                case "10", "A", "a":
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

}
