//
//  FirmwareUpgrade_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/25.
//  固件升级功能模块（341-350）
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 固件升级类型枚举
public enum FirmwareUpgradeType {
    case apollo
    case nordic
    case phy
    case phyBootMode
}

/// 固件升级功能模块（341-350） - 处理Apollo、Nordic、Phy固件升级
class FirmwareUpgrade_Module: BaseFunction_Module {
    /// 当前固件升级类型
    private var curFirmwareUpgradeType: FirmwareUpgradeType = .apollo

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 341 ... 350)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 341: // 341 - Apollo固件升级
            upgradeApolloFirmware()
        case 342: // 342 - Nordic固件升级
            upgradeNordicFirmware()
        case 343: // 343 - Phy固件升级
            upgradePhyFirmware()
        case 344: // 344 - Phy Boot Mode固件升级
            upgradePhyBootModeFirmware()
        case 345: // 345 - 获取固件升级类型
            showOTATypeConfigDialog()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 341 - Apollo固件升级
    private func upgradeApolloFirmware() {
        curFirmwareUpgradeType = .apollo
        openFilePicker()
    }

    // 342 - Nordic固件升级
    private func upgradeNordicFirmware() {
        curFirmwareUpgradeType = .nordic
        openFilePicker()
    }

    // 343 - Phy固件升级
    private func upgradePhyFirmware() {
        curFirmwareUpgradeType = .phy
        openFilePicker()
    }

    // 344 - Phy Boot Mode固件升级
    private func upgradePhyBootModeFirmware() {
        curFirmwareUpgradeType = .phyBootMode
        openFilePicker()
    }

//    // 345 - PhyBootMode测试升级
//    private func upgradePhyBootModeTest() {
//        // 1、搜索蓝牙设备
//        BCLRingManager.shared.startScan { result in
//            switch result {
//            case let .success(devices):
//                for device in devices {
//                    if device.isPhyBootMode {
//                        BDLogger.info("找到Phy Boot Mode设备：\(device)")
//                        BCLRingManager.shared.stopScan()
//                        BDLogger.info("停止扫描设备")
//                        // 2、开始测试升级
//                        BDLogger.info("开始Phy Boot Mode测试升级...")
//                        self.startTestPhyBootModeTest(device: device)
//                    }
//                }
//
//            case let .failure(error):
//                BDLogger.error("scan failed: \(error)")
//            }
//        }
//    }
//
//    private func startTestPhyBootModeTest(device: BCLDeviceInfoModel) {
//        BDLogger.info("============开始查询最新固件版本...============")
//
//        var phyBootDeviceMacAddress = device.macAddress!
//        BDLogger.info("当前Phy Boot Mode设备的MAC地址: \(phyBootDeviceMacAddress)")
//        // 通过尾号查询固件列表
//        BCLRingManager.shared.getFirmwareVersionList(category: "Z47") { res in
//            switch res {
//            case let .success(response):
//                BDLogger.info("固件历史版本-总个数: \(response.count)")
//                // 解析版本号并找出最新版本
//                let latestVersion = self.findLatestVersion(from: response)
//                if let latest = latestVersion {
//                    BDLogger.info("============最新固件版本...============")
//                    let latestFileName = self.getFileName(from: latest)
//                    let latestFileUrl = self.getFileUrl(from: latest)
//                    BDLogger.info("✅ 找到最新版本：\(latestFileName)")
//                    BDLogger.info("✅ 最新版本号：\(self.extractVersionNumber(from: latestFileName))")
//                    BDLogger.info("✅ 最新版本下载链接：\(latestFileUrl)")
//                    guard !latestFileName.isEmpty, !latestFileUrl.isEmpty else {
//                        BDLogger.error("文件名或下载URL为空")
//                        return
//                    }
//                    BDLogger.info("开始下载最新固件：\(latestFileName)")
//                    // 获取文档目录路径
//                    let destinationPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//                    // 调用固件的下载方法
//                    BCLRingManager.shared.downloadFirmware(
//                        url: latestFileUrl,
//                        fileName: latestFileName,
//                        destinationPath: destinationPath,
//                        progress: { progress in
//                            BDLogger.info("固件下载进度：\(progress)%")
//                        },
//                        completion: { result in
//                            switch result {
//                            case let .success(filePath):
//                                // 线连接蓝牙设备
//                                BDLogger.info("++++++++先连接蓝牙设备++++++++++")
//                                BCLRingManager.shared.startConnect(device: device) { result in
//                                    switch result {
//                                    case .success:
//                                        BDLogger.info("connect success")
//                                        self.showSuccess("蓝牙设备连接成功")
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//
//                                            self?.startUpdatePhtBootModel(filePath: filePath, phyBootDeviceMacAddress: phyBootDeviceMacAddress)
//                                        }
//
//                                    case let .failure(error):
//                                        BDLogger.error("connect failed: \(error)")
//                                        self.showError("蓝牙设备连接失败：\(error.localizedDescription)")
//                                    }
//                                }
//                            case let .failure(error):
//                                BDLogger.error("❌ 固件下载失败：\(error)")
//                            }
//                        }
//                    )
//                } else {
//                    BDLogger.info("✅ 当前已是最新版本")
//                    // 如果当前版本已经是最新的，没有最新版本固件可以下载，则可以通过固件版本历史信息去查询最新的固件文件进行PHY Boot Mode升级
//                }
//            case let .failure(error):
//                BDLogger.error("获取固件历史版本失败: \(error)")
//            }
//        }
//    }
//
//    private func startUpdatePhtBootModel(filePath: String, phyBootDeviceMacAddress: String) {
//        BDLogger.info("✅ 固件下载成功：\(filePath)")
//        guard let currentDevice = BCLRingManager.shared.currentConnectedDevice else {
//            BDLogger.error("当前没有连接的设备")
//            return
//        }
//        BDLogger.info("开始PHY Boot Mode升级...")
//        // 如果开启了自动重连，需要先关掉。
//        BCLRingManager.shared.isAutoReconnectEnabled = false
//        BCLRingManager.shared.phyBootModeUpgrade(
//            filePath: filePath,
//            device: currentDevice,
//            peripheral: currentDevice.peripheral
//        ) { progress in
//            BDLogger.info("PHY Boot Mode 升级进度: \(progress)%")
//        } completion: { result in
//            switch result {
//            case let .success(response):
//                switch response {
//                case .preparing:
//                    BDLogger.info("PHY Boot Mode 升级中: 准备中...")
//                case .bootModeConnected:
//                    BDLogger.info("PHY Boot Mode 升级中: 已连接到Boot模式设备...")
//                case .upgrading:
//                    BDLogger.info("PHY Boot Mode 升级中: 文件传传输中...")
//                case .upgradingCompleted:
//                    BDLogger.info("PHY Boot Mode 升级中: 文件传输完成，准备退出Boot模式...")
//                case .exitingBootMode:
//                    BDLogger.info("PHY Boot Mode 升级中: 正在退出Boot模式...")
//                case .success:
//                    BDLogger.info("✅ PHY Boot Mode 升级成功: \(response)")
//                    // 📢 需要将Phy Boot 模式下的Mac地址进行-1操作，然后进行重新连接设备
//                    guard let targetDeviceMacAddress = self.decrementMac(macAddress: phyBootDeviceMacAddress) else {
//                        BDLogger.error("❌ 获取目标设备的MAC地址失败,无法重连蓝牙设备")
//                        return
//                    }
//                    BDLogger.info("升级成功后，目标设备的MAC地址: \(targetDeviceMacAddress)")
//                    self.connectDevice(macAddress: targetDeviceMacAddress)
//                case let .failed(errString):
//                    BDLogger.error("❌ PHY Boot Mode 升级失败: \(errString)")
//                }
//            case let .failure(error):
//                BDLogger.error("❌ PHY Boot Mode 升级失败: \(error)")
//            }
//        }
//    }
//
//    /// 从固件版本列表中找出最新版本
//    /// - Parameter versions: 固件版本列表
//    /// - Returns: 最新版本的固件信息
//    private func findLatestVersion(from versions: [Any]) -> Any? {
//        var latestVersion: Any?
//        var latestVersionNumber = ""
//
//        for version in versions {
//            // 使用 Mirror 反射来获取 fileName 属性
//            let mirror = Mirror(reflecting: version)
//            var fileName: String?
//
//            for child in mirror.children {
//                if child.label == "fileName" {
//                    fileName = child.value as? String
//                    break
//                }
//            }
//
//            if let fileName = fileName {
//                let versionNumber = extractVersionNumber(from: fileName)
//
//                if versionNumber.isEmpty {
//                    continue
//                }
//
//                if latestVersion == nil {
//                    latestVersion = version
//                    latestVersionNumber = versionNumber
//                } else {
//                    let comparison = compareVersions(versionNumber, latestVersionNumber)
//                    if comparison > 0 {
//                        latestVersion = version
//                        latestVersionNumber = versionNumber
//                    }
//                }
//            }
//        }
//
//        return latestVersion
//    }
//
//    /// 从文件名中提取版本号
//    /// - Parameter fileName: 文件名，例如 "2.7.5.0Z3N.hex16"
//    /// - Returns: 版本号字符串，例如 "2.7.5.0"
//    private func extractVersionNumber(from fileName: String) -> String {
//        // 使用正则表达式匹配版本号格式
//        let pattern = #"^(\d+\.\d+\.\d+\.\d+)"#
//
//        if let regex = try? NSRegularExpression(pattern: pattern),
//           let match = regex.firstMatch(in: fileName, range: NSRange(fileName.startIndex..., in: fileName)) {
//            let versionRange = Range(match.range(at: 1), in: fileName)!
//            return String(fileName[versionRange])
//        }
//
//        // 如果正则匹配失败，使用简单的字符串分割
//        let components = fileName.components(separatedBy: "Z")
//        if let firstComponent = components.first {
//            return firstComponent
//        }
//
//        return ""
//    }
//
//    /// 比较两个版本号
//    /// - Parameters:
//    ///   - version1: 第一个版本号
//    ///   - version2: 第二个版本号
//    /// - Returns: 比较结果：-1表示version1更旧，0表示相等，1表示version1更新
//    private func compareVersions(_ version1: String, _ version2: String) -> Int {
//        let components1 = version1.components(separatedBy: ".").compactMap { Int($0) }
//        let components2 = version2.components(separatedBy: ".").compactMap { Int($0) }
//
//        let maxLength = max(components1.count, components2.count)
//
//        for i in 0 ..< maxLength {
//            let num1 = i < components1.count ? components1[i] : 0
//            let num2 = i < components2.count ? components2[i] : 0
//
//            if num1 < num2 {
//                return -1
//            } else if num1 > num2 {
//                return 1
//            }
//        }
//
//        return 0
//    }
//
//    /// 从固件版本对象中获取文件名
//    /// - Parameter version: 固件版本对象
//    /// - Returns: 文件名
//    private func getFileName(from version: Any) -> String {
//        let mirror = Mirror(reflecting: version)
//        for child in mirror.children {
//            if child.label == "fileName" {
//                return child.value as? String ?? ""
//            }
//        }
//        return ""
//    }
//
//    /// 从固件版本对象中获取文件URL
//    /// - Parameter version: 固件版本对象
//    /// - Returns: 文件URL
//    private func getFileUrl(from version: Any) -> String {
//        let mirror = Mirror(reflecting: version)
//        for child in mirror.children {
//            if child.label == "fileUrl" {
//                return child.value as? String ?? ""
//            }
//        }
//        return ""
//    }
//
//    /// 递减MAC地址(当前Mac地址-1)
//    /// - Parameter macAddress: MAC地址
//    /// - Returns: 递减后的MAC地址
//    func decrementMac(macAddress: String) -> String? {
//        let components = macAddress.components(separatedBy: ":")
//        var bytes = [UInt8]()
//
//        for component in components {
//            if let byte = UInt8(component, radix: 16) {
//                bytes.append(byte)
//            } else {
//                return nil // 非法的MAC地址格式
//            }
//        }
//
//        for i in (0 ..< 6).reversed() {
//            if bytes[i] > 0 {
//                bytes[i] -= 1
//                break
//            } else {
//                bytes[i] = 255
//            }
//        }
//
//        let decrementedMacAddress = bytes.map { String(format: "%02X", $0) }.joined(separator: ":")
//        return decrementedMacAddress
//    }
//
//    // 连接设备
//    func connectDevice(macAddress: String) {
//        showLoading("开始连接蓝牙设备.......")
//        BCLRingManager.shared.startConnect(macAddress: macAddress, isAutoReconnect: true, autoReconnectTimeLimit: 1000, autoReconnectMaxAttempts: 5000) { result in
//            self.hideLoading()
//            switch result {
//            case .success:
//                BDLogger.info("connect success")
//                self.showSuccess("蓝牙设备连接成功")
//            case let .failure(error):
//                BDLogger.error("connect failed: \(error)")
//                self.showError("蓝牙设备连接失败：\(error.localizedDescription)")
//            }
//        }
//    }

    // 345 - 获取固件升级类型弹窗
    private func showOTATypeConfigDialog() {
        let contentView = OTATypeConfig_Dialog(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 260)
        contentView.confirmButtonCallback = { version in
            BDLogger.info("开始获取固件升级类型 - 版本号:\(version)")
            self.getOTAType(firmwareVersion: version)
        }
        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 执行获取固件升级类型
    private func getOTAType(firmwareVersion: String) {
        showLoading("查询升级类型...")
        BCLRingManager.shared.getOTAType(firmwareVersion: firmwareVersion) { [weak self] response in
            self?.hideLoading()
            BDLogger.info("固件升级类型 rawValue: \(response.rawValue)")
            switch response.rawValue {
            case 0:
                BDLogger.error("固件升级类型: 未知")
                self?.showError("固件升级类型: 未知")
            case 1:
                BDLogger.info("""
                固件升级类型: Apollo
                对应升级方法: apolloUpgradeFirmware(filePath:progressHandler:completion:)
                固件文件格式: .bin
                """)
                self?.showSuccess("固件升级类型: Apollo")
            case 2:
                BDLogger.info("""
                固件升级类型: Nordic
                对应升级方法: nrfUpgradeFirmware(filePath:fileName:progressHandler:completion:)
                固件文件格式: .zip
                """)
                self?.showSuccess("固件升级类型: Nordic")
            case 3:
                BDLogger.info("""
                固件升级类型: Phy
                对应升级方法: phyUpgradeFirmware(filePath:progressHandler:completion:)
                固件文件格式: .hex16
                """)
                self?.showSuccess("固件升级类型: Phy")
            default:
                BDLogger.error("固件升级类型: 未知 (rawValue: \(response.rawValue))")
                self?.showError("固件升级类型: 未知")
            }
        }
    }

    // 打开文件选择器
    private func openFilePicker() {
        guard let viewController = viewController else {
            BDLogger.error("viewController为空，无法打开文件选择器")
            return
        }

        let filePicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        filePicker.delegate = self
        filePicker.allowsMultipleSelection = false
        viewController.present(filePicker, animated: true, completion: nil)
    }
}

extension FirmwareUpgrade_Module: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }

        if curFirmwareUpgradeType == .apollo {
            // 检查文件扩展名是否为.bin
            guard fileURL.pathExtension.lowercased() == "bin" else {
                showError("请选择.bin格式的固件文件")
                return
            }
            BDLogger.info("选择的文件：\(fileURL)")
            BDLogger.info("文件名称：\(fileURL.lastPathComponent)")
            BDLogger.info("开始Apollo固件升级...")

            guard let fileurl = fileURL as URL? else {
                showError("文件路径无效")
                return
            }

            showLoading("开始升级...")
            BCLRingManager.shared.apolloUpgradeFirmware(filePath: fileurl.path, progressHandler: { [weak self] progress in
                BDLogger.info("Apollo升级进度：\(progress)%")
                self?.showLoading("升级进度：\(progress)%")
            },
            completion: { [weak self] result in
                self?.hideLoading()
                switch result {
                case .success:
                    BDLogger.info("Apollo固件升级成功")
                    self?.showSuccess("Apollo固件升级成功")
                case let .failure(error):
                    BDLogger.error("Apollo固件升级失败：\(error)")
                    self?.showError("升级失败：\(error.localizedDescription)")
                }
            }
            )
        } else if curFirmwareUpgradeType == .nordic {
            // 检查文件扩展名是否为.zip
            guard fileURL.pathExtension.lowercased() == "zip" else {
                showError("请选择.zip格式的固件文件")
                return
            }
            BDLogger.info("选择的文件：\(fileURL)")
            BDLogger.info("文件名称：\(fileURL.lastPathComponent)")
            BDLogger.info("开始Nordic固件升级...")

            let fileName = fileURL.lastPathComponent
            showLoading("设备重启中.....")

            BCLRingManager.shared.nrfUpgradeFirmware(filePath: fileURL.path, fileName: fileName) { [weak self] progress in
                BDLogger.info("Nordic升级进度：\(progress)%")
                self?.showLoading("升级进度：\(progress)%")
            } completion: { [weak self] res in
                switch res {
                case let .success(state):
                    if state == .rebooting {
                        BDLogger.info("Nordic固件升级-设备重启中")
                        self?.showLoading("设备重启中")
                    } else if state == .completed {
                        BDLogger.info("Nordic固件升级成功")
                        self?.hideLoading()
                        self?.showSuccess("Nordic固件升级成功")
                    }
                case let .failure(error):
                    BDLogger.error("Nordic固件升级失败：\(error)")
                    self?.hideLoading()
                    self?.showError("升级失败：\(error.localizedDescription)")
                }
            }
        } else if curFirmwareUpgradeType == .phy {
            // 检查文件扩展名是否为.hex16
            guard fileURL.pathExtension.lowercased() == "hex16" else {
                showError("请选择.hex16格式的固件文件")
                return
            }
            BDLogger.info("选择的文件：\(fileURL)")
            BDLogger.info("文件名称：\(fileURL.lastPathComponent)")
            BDLogger.info("开始Phy固件升级...")

            // 如果开启了自动重连，需要先关掉
            BCLRingManager.shared.isAutoReconnectEnabled = false
            showLoading("开始升级...")

            BCLRingManager.shared.phyUpgradeFirmware(filePath: fileURL.path) { [weak self] progress in
                let progressPercent = Int(progress * 100)
                BDLogger.info("Phy升级进度：\(progressPercent)%")
                self?.showLoading("升级进度：\(progressPercent)%")
            } completion: { [weak self] res in
                self?.hideLoading()
                switch res {
                case let .success(state):
                    BDLogger.info("Phy固件升级成功：\(state)")
                    self?.showSuccess("Phy固件升级成功")
                case let .failure(error):
                    BDLogger.error("Phy固件升级失败：\(error)")
                    self?.showError("升级失败：\(error.localizedDescription)")
                }
            }
        } else if curFirmwareUpgradeType == .phyBootMode {
            // 检查文件扩展名是否为.hex16
            guard fileURL.pathExtension.lowercased() == "hex16" else {
                showError("请选择.hex16格式的固件文件")
                return
            }

            // 检查当前设备是否可用
            guard let currentDevice = BCLRingManager.shared.currentConnectedDevice else {
                showError("当前没有连接的设备")
                return
            }

            BDLogger.info("选择的文件：\(fileURL)")
            BDLogger.info("文件名称：\(fileURL.lastPathComponent)")
            BDLogger.info("开始Phy Boot Mode固件升级...")

            // 如果开启了自动重连，需要先关掉
            BCLRingManager.shared.isAutoReconnectEnabled = false
            showLoading("开始升级...")

            BCLRingManager.shared.phyBootModeUpgrade(filePath: fileURL.path, device: currentDevice, peripheral: currentDevice.peripheral) { [weak self] progress in
                BDLogger.info("PHY Boot Mode升级进度：\(Int(progress))%")
                self?.showLoading("升级进度：\(Int(progress))%")
            } completion: { [weak self] res in
                self?.hideLoading()
                switch res {
                case let .success(response):
                    BDLogger.info("PHY Boot Mode升级成功：\(response)")
                    self?.showSuccess("PHY Boot Mode固件升级成功")
                case let .failure(error):
                    BDLogger.error("PHY Boot Mode升级失败：\(error)")
                    self?.showError("升级失败：\(error.localizedDescription)")
                }
            }
        }
    }
}
