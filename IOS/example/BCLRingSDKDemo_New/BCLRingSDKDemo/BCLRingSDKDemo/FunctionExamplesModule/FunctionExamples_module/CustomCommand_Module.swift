//
//  CustomCommand_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/12/15.
//  自定义指令功能模块 - 发送、接收自定义指令及分享 SDK 日志（1001-1100）

import BCLRingSDK
import QMUIKit
import UIKit

/// 自定义指令和日志分享功能模块 - 处理自定义指令、指令停止和日志分享（1001-1100）
class CustomCommand_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 1001 ... 1100)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 1001: // 1001 - 发送自定义指令并接收响应
            presentCustomCommandDialog()
        case 1002: // 1002 - 停止所有自定义指令
            stopAllCustomCommands()
        case 1003: // 1003 - 分享 Log 日志文件
            shareLogFiles()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 1001 - 显示自定义指令输入对话框
    private func presentCustomCommandDialog() {
        let contentView = CustomCommandDialog(x: 0, y: 0, width: 320, height: 360)
        contentView.confirmButtonCallback = { [weak self] hexCommand in
            self?.sendCustomCommand(hexCommand: hexCommand)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    /// 发送自定义指令
    private func sendCustomCommand(hexCommand: String) {
        // 将十六进制字符串转换为 Data
        guard let commandData = hexStringToData(hexCommand) else {
            BDLogger.error("❌ 十六进制字符串转换失败: \(hexCommand)")
            showError("指令转换失败")
            return
        }

        BDLogger.info("📤 开始发送自定义指令，数据长度: \(commandData.count) 字节")
        BDLogger.info("指令内容(Hex): \(hexCommand.uppercased())")

        showLoading("发送指令中...", userInteractionEnabled: false)

        // 调用 SDK 发送自定义指令
        let result = BCLRingManager.shared.sendCustomCommand(commandData: commandData) { [weak self] responseData in
            self?.hideLoading()
            self?.handleCustomCommandResponse(responseData)
        }

        // 检查发送结果
        switch result {
        case let .success(message):
            BDLogger.info("✅ 自定义指令已发送，ID: \(message)")
        case let .failure(error):
            hideLoading()
            BDLogger.error("❌ 发送自定义指令失败: \(error)")
            showError("发送指令失败")
        }
    }

    /// 处理自定义指令响应
    private func handleCustomCommandResponse(_ responseData: Data) {
        let hexResponse = dataToHexString(responseData)
        BDLogger.info("📥 收到自定义指令响应:")
        BDLogger.info("长度: \(responseData.count) 字节")
        BDLogger.info("内容(Hex): \(hexResponse)")
        showSuccess("指令响应已接收，请查看日志")
    }

    /// 1002 - 停止所有自定义指令
    private func stopAllCustomCommands() {
        BDLogger.info("⏹ 停止所有自定义指令监听")

        BCLRingManager.shared.stopAllCustomCommands()

        BDLogger.info("✅ 已停止所有自定义指令监听")
        showSuccess("已停止监听自定义指令")
    }

    /// 1003 - 分享 SDK Log 日志文件
    private func shareLogFiles() {
        BDLogger.info("📦 开始打包 SDK 日志文件")

        showLoading("正在打包日志文件...", userInteractionEnabled: false)

        // 调用 SDK 压缩日志文件（不指定日期，打包所有日志）
        BCLRingManager.shared.compressLogAndDataFiles(fromDate: nil) { [weak self] result in
            self?.hideLoading()
            self?.handleCompressLogResult(result)
        }
    }

    /// 处理压缩日志结果
    private func handleCompressLogResult(_ result: Result<(String, Data), BCLError>) {
        switch result {
        case let .success((filePath, fileData)):
            BDLogger.info("✅ 日志文件压缩成功")
            BDLogger.info("文件路径: \(filePath)")
            BDLogger.info("文件大小: \(fileData.count) 字节")

            // 通过文件路径创建 URL 对象用于分享
            let fileURL = URL(fileURLWithPath: filePath)
            presentShareSheet(with: fileURL)

        case let .failure(error):
            BDLogger.error("❌ 压缩日志失败: \(error)")
            showError("打包日志失败，请稍后重试")
        }
    }

    /// 呈现系统分享界面
    private func presentShareSheet(with fileURL: URL) {
        // 验证文件是否存在
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            BDLogger.error("❌ 压缩文件不存在: \(fileURL.path)")
            showError("压缩文件获取失败")
            return
        }

        // 创建可分享的项目（使用文件 URL）
        let shareItems: [Any] = [fileURL]

        // 创建 UIActivityViewController
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)

        // 设置排除的活动类型（可选）
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
        ]

        // 设置完成处理器
        activityViewController.completionWithItemsHandler = { [weak self] activity, completed, _, _ in
            BDLogger.info("📤 分享操作已完成")
            BDLogger.info("分享方式: \(activity?.rawValue ?? "未知")")
            BDLogger.info("是否成功: \(completed)")

            // 无论成功还是取消，都需要清理压缩文件
            self?.cleanCompressedLogFiles()
        }

        // 在 iPad 上设置弹出框位置（避免崩溃）
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = viewController?.view
            popoverController.sourceRect = viewController?.view.bounds ?? .zero
        }

        // 显示分享界面
        viewController?.present(activityViewController, animated: true)
    }

    /// 清理压缩的日志文件
    private func cleanCompressedLogFiles() {
        BDLogger.info("🧹 开始清理临时压缩文件")

        BCLRingManager.shared.cleanCompressedFiles { [weak self] result in
            switch result {
            case .success:
                BDLogger.info("✅ 临时文件清理成功")
                self?.showSuccess("日志分享完成")

            case let .failure(error):
                BDLogger.error("⚠️ 清理文件失败: \(error)")
                // 清理失败不显示用户提示，只记录日志
            }
        }
    }

    // MARK: - Helper Methods

    /// 将十六进制字符串转换为 Data
    private func hexStringToData(_ hexString: String) -> Data? {
        // 移除空格
        let cleanHexString = hexString.replacingOccurrences(of: " ", with: "")

        // 验证长度为偶数
        guard cleanHexString.count % 2 == 0 else {
            return nil
        }

        var data = Data()
        var index = cleanHexString.startIndex

        while index < cleanHexString.endIndex {
            let nextIndex = cleanHexString.index(index, offsetBy: 2)
            let hexByte = String(cleanHexString[index ..< nextIndex])

            guard let byte = UInt8(hexByte, radix: 16) else {
                return nil
            }

            data.append(byte)
            index = nextIndex
        }

        return data
    }

    /// 将 Data 转换为十六进制字符串
    private func dataToHexString(_ data: Data) -> String {
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}
