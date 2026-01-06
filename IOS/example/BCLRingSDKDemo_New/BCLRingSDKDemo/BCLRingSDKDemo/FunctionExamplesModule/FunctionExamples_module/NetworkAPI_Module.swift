//
//  NetworkAPI_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  网络API功能模块 (201-300)
//

import BCLRingSDK
import Foundation
import QMUIKit
import UIKit

/// 网络API功能模块 - 处理睡眠数据获取、Token创建、固件更新检查等
class NetworkAPI_Module: BaseFunction_Module {
    // MARK: - Properties

    /// 历史数据缓存
    private var historyData: [BCLRingDBModel] = []

    /// 波形数据
    private var bloodGlucoseWaveData: [(Int, Int, Int, Int, Int)] = []

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 201 ... 300)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 201: // 切换服务器-国内
            switchToDomesticServer()
        case 202: // 切换服务器-海外
            switchToOverseasServer()
        case 203: // 创建Token
            showCreateTokenConfigDialog()
        case 204: // 刷新Token
            refreshToken()
        case 205: // 提交历史数据到云端
            submitHistoricalData()
        case 206: // 提交波形数据，获取血压结果
            submitWaveformForBloodPressure()
        case 207: // 提交波形数据，获取血糖结果
            submitWaveformForBloodGlucose()
        case 208: // 固件版本更新检查
            showFirmwareVersionConfigDialog()
        case 209: // 查询固件版本历史列表
            showFirmwareCategoryConfigDialog()
        case 210: // 下载特定固件文件
            showFirmwareDownloadConfigDialog()
        case 211: // 时间线数据
            showTimelineDataConfigDialog()
        case 212: // 获取用户最新一条历史数据
            loadUserLatestHistory()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 201 - 切换服务器-国内
    private func switchToDomesticServer() {
        // 配置网络地址（国外地址：.overseas、国内地址：.domestic（默认））
        BCLRingManager.shared.networkRegion = .domestic
        showSuccess("已切换到国内服务器")
    }

    // 202 - 切换服务器-海
    private func switchToOverseasServer() {
        // 配置网络地址（国外地址：.overseas、国内地址：.domestic（默认））
        BCLRingManager.shared.networkRegion = .overseas
        showSuccess("已切换到海外服务器")
    }

    // 203 - 创建Token参数配置弹窗
    private func showCreateTokenConfigDialog() {
        let contentView = TokenConfig_Dialog(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 330)
        contentView.confirmButtonCallback = { apiKey, userIdentifier in
            BDLogger.info("开始创建Token - API Key:\(apiKey), 用户标识符:\(userIdentifier)")
            self.createToken(apiKey: apiKey, userIdentifier: userIdentifier)
        }
        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 执行创建Token请求
    private func createToken(apiKey: String, userIdentifier: String) {
        // 注意：创建Token接口需要网络请求，请确保设备已联网，且需要注意服务器区域的选择，国内用户可以使用国内服务器(SDK默认使用国内服务器)，海外用户请使用海外服务器
        showLoading("获取Token...")
        BCLRingManager.shared.createToken(apiKey: apiKey, userIdentifier: userIdentifier) { result in
            self.hideLoading()
            switch result {
            case let .success(token):
                BDLogger.info("Token获取成功: \(token)")
                self.showSuccess("Token获取成功")
            case let .failure(error):
                self.handleNetworkError(error)
            }
        }
    }

    // 204 - 刷新token
    private func refreshToken() {
        showLoading("刷新Token...")
        BCLRingManager.shared.refreshToken { result in
            self.hideLoading()
            switch result {
            case let .success(token):
                BDLogger.info("Token刷新成功: \(token)")
                self.showSuccess("Token刷新成功")
            case let .failure(error):
                self.handleNetworkError(error)
            }
        }
    }

    // 205 - 提交历史数据到云端
    private func submitHistoricalData() {
        guard let device = BCLRingManager.shared.currentConnectedDevice else {
            BDLogger.error("请连接蓝牙设备")
            showError("请连接蓝牙设备")
            return
        }
        guard let mac = device.macAddress else {
            BDLogger.error("设备MAC地址为空")
            showError("设备MAC地址为空")
            return
        }

        guard !historyData.isEmpty else {
            BDLogger.error("历史数据为空")
            showError("历史数据为空")
            return
        }
        BCLRingManager.shared.uploadHistory(historyData: historyData, mac: mac) { res in
            switch res {
            case let .success(response):
                BDLogger.info("上传历史记录成功: \(response)")
                self.showSuccess("上传历史记录成功")
            case let .failure(error):
                switch error {
                case let .network(networkError):
                    switch networkError {
                    case .tokenError:
                        BDLogger.error("Token错误,需要重新获取Token")
                        self.showError("Token错误,需要重新获取Token")
                    case let .serverError(code, message):
                        BDLogger.error("服务器错误: \(code), \(message)")
                        self.showError("服务器错误: \(code), \(message)")
                    default:
                        BDLogger.error("上传失败: \(error)")
                        self.showError("上传失败: \(error)")
                    }
                default:
                    BDLogger.error("上传失败: \(error)")
                    self.showError("上传失败: \(error)")
                }
            }
        }
    }

    // 206-提交波形数据，获取血压结果
    private func submitWaveformForBloodPressure() {
        bloodGlucoseWaveData = []
        let mac = BCLRingManager.shared.currentConnectedDevice?.macAddress ?? ""
        BDLogger.info("Mac地址:\(mac)")

        // 注意：此处需要将戒指的mac地址和采集到的波形数据上传至云端进行血压计算
        // 注意：该接口需要使用到Token，请确保已登录并获取到Token
        // 血压云端算法
        BCLRingManager.shared.uploadBloodPressureData(mac: mac, waveData: bloodGlucoseWaveData) { res in
            self.hideLoading()
            switch res {
            case let .success(data):
                BDLogger.info("收缩压：\(data.0)、舒张压：\(data.1)")
                self.showSuccess("收缩压：\(data.0)、舒张压：\(data.1)")
            case let .failure(error):
                BDLogger.error("血压数据计算失败: \(error.localizedDescription)")
                self.showError("血压数据计算失败: \(error.localizedDescription)")
            }
        }
    }

    // 207-提交波形数据，获取血糖结果
    private func submitWaveformForBloodGlucose() {
        bloodGlucoseWaveData = []
        let mac = BCLRingManager.shared.currentConnectedDevice?.macAddress ?? ""
        BDLogger.info("Mac地址:\(mac)")
        // 注意：此处需要将戒指的mac地址和采集到的波形数据上传至云端进行血糖计算
        // 注意：该接口需要使用到Token，请确保已登录并获取到Token
        BCLRingManager.shared.uploadBloodGlucoseData(mac: mac, waveData: bloodGlucoseWaveData) { res in
            self.hideLoading()
            switch res {
            case let .success(data):
                BDLogger.info("血糖数据：\(data) mmol/L")
                self.showSuccess("血糖数据：\(data) mmol/L")
            case let .failure(error):
                BDLogger.error("血糖数据上传失败: \(error.localizedDescription)")
                self.showError("血糖数据计算失败: \(error.localizedDescription)")
            }
        }
    }

    // 208 - 固件版本更新检查弹窗
    private func showFirmwareVersionConfigDialog() {
        let contentView = FirmwareVersionConfig_Dialog(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 260)
        contentView.confirmButtonCallback = { version in
            BDLogger.info("开始检查固件版本更新 - 版本号:\(version)")
            self.checkFirmwareUpdate(version: version)
        }
        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 执行固件版本更新检查
    private func checkFirmwareUpdate(version: String) {
        showLoading("检查固件更新...")
        BCLRingManager.shared.checkFirmwareUpdate(version: version) { result in
            self.hideLoading()
            switch result {
            case let .success(versionInfo):
                if versionInfo.hasNewVersion {
                    BDLogger.info("""
                    ✅ 发现新版本：
                    - 版本号：\(versionInfo.version ?? "")
                    - 下载地址：\(versionInfo.downloadUrl ?? "")
                    - 文件名：\(versionInfo.fileName ?? "")
                    """)
                    self.showSuccess("发现新版本: \(versionInfo.version ?? "")")
                } else {
                    BDLogger.info("✅ 当前已是最新版本")
                    self.showSuccess("当前已是最新版本")
                }
            case let .failure(error):
                switch error {
                case let .network(.invalidParameters(message)):
                    BDLogger.error("❌ 参数无效，请检查版本号格式: \(message)")
                    self.showError("参数无效，请检查版本号格式")
                case let .network(.httpError(code)):
                    BDLogger.error("❌ HTTP请求失败：状态码 \(code)")
                    self.showError("HTTP请求失败：状态码 \(code)")
                case let .network(.serverError(code, message)):
                    BDLogger.error("❌ 服务器错误：[\(code)] \(message)")
                    self.showError("服务器错误：[\(code)] \(message)")
                case .network(.invalidResponse):
                    BDLogger.error("❌ 响应数据无效")
                    self.showError("响应数据无效")
                case let .network(.decodingError(decodingError)):
                    BDLogger.error("❌ 数据解析失败：\(decodingError.localizedDescription)")
                    self.showError("数据解析失败")
                case let .network(.networkError(message)):
                    BDLogger.error("❌ 网络错误：\(message)")
                    self.showError("网络错误：\(message)")
                case let .network(.tokenError(message)):
                    BDLogger.error("❌ Token异常：\(message)")
                    self.showError("Token异常：\(message)")
                default:
                    BDLogger.error("❌ 其他错误：\(error)")
                    self.showError("检查失败：\(error.localizedDescription)")
                }
            }
        }
    }

    // 209 - 查询固件版本历史列表弹窗
    private func showFirmwareCategoryConfigDialog() {
        let contentView = FirmwareCategoryConfig_Dialog(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 260)
        contentView.confirmButtonCallback = { category in
            BDLogger.info("开始查询固件版本历史列表 - category:\(category)")
            self.getFirmwareVersionList(category: category)
        }
        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 执行查询固件版本历史列表
    private func getFirmwareVersionList(category: String) {
        showLoading("查询固件版本列表...")
        BCLRingManager.shared.getFirmwareVersionList(category: category) { [weak self] result in
            self?.hideLoading()
            switch result {
            case let .success(response):
                BDLogger.info("固件历史版本-总个数: \(response.count)")
                response.forEach { item in
                    BDLogger.info("""
                    固件历史版本:
                    - 文件名: \(item.fileName)
                    - 文件路径: \(item.filePath)
                    - 下载链接: \(item.fileUrl)
                    """)
                }

                if response.isEmpty {
                    self?.showError("未找到固件版本")
                } else {
                    self?.showFirmwareVersionListDialog(versions: response)
                }
            case let .failure(error):
                BDLogger.error("获取固件历史版本失败: \(error)")
                switch error {
                case let .network(.tokenError(message)):
                    BDLogger.error("Token异常: \(message)")
                    self?.showError("请先获取Token后再查询")
                case .network(.decodingError):
                    // 解码错误通常是因为服务器返回了401等错误信息
                    self?.showError("请先获取Token后再查询")
                case let .network(.serverError(code, message)):
                    BDLogger.error("服务器错误[\(code)]: \(message)")
                    if code == 401 {
                        self?.showError("请先获取Token后再查询")
                    } else {
                        self?.showError("服务器错误：[\(code)] \(message)")
                    }
                case let .network(.httpError(code)):
                    BDLogger.error("HTTP错误: \(code)")
                    if code == 401 {
                        self?.showError("请先获取Token后再查询")
                    } else {
                        self?.showError("网络错误：\(code)")
                    }
                case let .network(.invalidParameters(message)):
                    BDLogger.error("参数无效: \(message)")
                    self?.showError("参数无效：\(message)")
                case .network(.invalidResponse):
                    self?.showError("响应数据无效")
                case let .network(.networkError(message)):
                    BDLogger.error("网络错误: \(message)")
                    self?.showError("网络错误：\(message)")
                default:
                    self?.showError("获取固件历史版本失败")
                }
            }
        }
    }

    // 显示固件版本列表弹窗
    private func showFirmwareVersionListDialog(versions: [FirmwareVersionItem]) {
        let screenHeight = UIScreen.main.bounds.height
        let dialogHeight = min(screenHeight * 0.7, 500.0)
        let contentView = FirmwareVersionListDialog(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width - 30,
            height: dialogHeight,
            versions: versions
        )
        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 下载特定固件文件弹窗
    private func showFirmwareDownloadConfigDialog() {
        let contentView = FirmwareDownloadConfig_Dialog(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 420)
        contentView.confirmButtonCallback = { [weak self] url, fileName, destinationPath in
            BDLogger.info("开始下载固件 - URL:\(url), 文件名:\(fileName), 保存路径:\(destinationPath)")
            self?.downloadFirmware(url: url, fileName: fileName, destinationPath: destinationPath)
        }
        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 210 - 执行固件下载
    private func downloadFirmware(url: String, fileName: String, destinationPath: String) {
        showLoading("下载中... 0%", userInteractionEnabled: false)
        BCLRingManager.shared.downloadFirmware(url: url, fileName: fileName, destinationPath: destinationPath) { [weak self] progress in
            let percentage = Int(progress * 100)
            DispatchQueue.main.async {
                self?.tipsView?.showLoading("下载中... \(percentage)%")
            }
        } completion: { [weak self] result in
            self?.hideLoading()
            switch result {
            case let .success(filePath):
                BDLogger.info("✅ 固件下载成功，保存路径: \(filePath)")
                self?.showSuccess("固件下载成功")
            case let .failure(error):
                self?.handleFirmwareDownloadError(error)
            }
        }
    }

    // 211 - 时间线数据配置弹窗
    private func showTimelineDataConfigDialog() {
        let contentView = TimelineDataConfig_Dialog(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 360)
        contentView.confirmButtonCallback = { [weak self] startTime, endTime in
            BDLogger.info("开始查询时间线数据 - 开始时间:\(startTime), 结束时间:\(endTime)")
            self?.fetchTimelineData(startTime: startTime, endTime: endTime)
        }
        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 执行时间线数据查询
    private func fetchTimelineData(startTime: Int, endTime: Int) {
        showLoading("查询时间线数据...")
        BCLRingManager.shared.getTimeline(startTime: Int64(startTime), endTime: Int64(endTime)) { [weak self] result in
            self?.hideLoading()
            switch result {
            case let .success(items):
                BDLogger.info("✅ 时间线数据查询成功，共 \(items.count) 条记录")
                for item in items {
                    BDLogger.info("活动类型: \(item.type), 开始时间: \(item.startTime), 结束时间: \(item.endTime)")
                }
                if items.isEmpty {
                    self?.showSuccess("未查询到时间线数据")
                } else {
                    self?.showSuccess("查询成功，共 \(items.count) 条记录")
                }
            case let .failure(error):
                BDLogger.error("❌ 时间线数据查询失败: \(error)")
                self?.handleNetworkError(error)
            }
        }
    }

    // 212 - 获取用户最新一条历史数据
    private func loadUserLatestHistory() {
        showLoading("获取最新历史数据...")
        BCLRingManager.shared.loadUserLatestHistory { [weak self] result in
            self?.hideLoading()
            switch result {
            case let .success(latestHistory):
                BDLogger.info("最新历史数据：\(String(describing: latestHistory?.localizedDescription))")
                self?.showSuccess("获取成功")
            case let .failure(error):
                BDLogger.error("获取最新历史数据失败: \(error)")
                self?.handleNetworkError(error)
            }
        }
    }

    // 处理固件下载错误
    private func handleFirmwareDownloadError(_ error: BCLError) {
        switch error {
        case let .network(.tokenError(message)):
            BDLogger.error("❌ Token异常: \(message)")
            showError("Token异常，请先获取Token")
        case let .network(.networkError(message)):
            BDLogger.error("❌ 网络错误: \(message)")
            showError("网络错误，请检查网络连接")
        case let .network(.httpError(code)):
            BDLogger.error("❌ HTTP请求失败: \(code)")
            showError("HTTP请求失败：状态码 \(code)")
        case let .network(.serverError(code, message)):
            BDLogger.error("❌ 服务器错误[\(code)]: \(message)")
            showError("服务器错误：[\(code)] \(message)")
        case let .network(.invalidParameters(message)):
            BDLogger.error("❌ 参数无效: \(message)")
            showError("参数无效，请检查输入")
        case .network(.invalidResponse):
            BDLogger.error("❌ 响应数据无效")
            showError("响应数据无效")
        case let .network(.decodingError(decodingError)):
            BDLogger.error("❌ 数据解析失败: \(decodingError.localizedDescription)")
            showError("数据解析失败")
        default:
            BDLogger.error("❌ 下载失败: \(error)")
            showError("固件下载失败：\(error.localizedDescription)")
        }
    }
}
