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
}
