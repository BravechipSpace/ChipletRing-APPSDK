//
//  MeasurementTemperature_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  主动测量——温度-功能模块 (81-85)
//

import BCLRingSDK
import UIKit

/// 主动测量——温度-功能模块 (81-85)
class MeasurementTemperature_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 81 ... 85)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 81: // 主动测量-温度
            measureTemperature()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 81 - 主动测量-温度
    private func measureTemperature() {
        BCLRingManager.shared.readTemperature { result in
            switch result {
            case let .success(response):
                if let error = response.status.error {
                    switch error {
                    case let .temperature(tempError):
                        switch tempError {
                        case .measuring:
                            BDLogger.info("测量中，请等待...")
                            BDLogger.info("温度值：\(response.temperature ?? 0)")
                            if let temperature = response.temperature, temperature <= 1000 {
                                self.showLoading("当前测量进度：\(String(format: "%.2f", Double(temperature) * 0.1))%")
                            } else {
                                self.showSuccess("测量中，请等待...\n温度值：\(response.temperature ?? 0)")
                            }
                        case .charging:
                            BDLogger.error("设备正在充电，无法测量")
                            self.showError("设备正在充电，无法测量")
                        case .notWearing:
                            BDLogger.error("检测未佩戴，测量失败")
                            self.showError("检测未佩戴，测量失败")
                        case .invalid:
                            BDLogger.error("无效数据")
                            self.showError("无效数据")
                        case .busy:
                            BDLogger.error("设备繁忙")
                            self.showError("设备繁忙")
                        @unknown default:
                            BDLogger.error("未知温度错误")
                            self.showError("未知温度错误")
                        }
                    default:
                        self.hideLoading()
                        BDLogger.error("读取温度失败: \(error)")
                        self.showError("读取温度失败: \(error)")
                    }
                } else if let temperature = response.temperature {
                    BDLogger.info("测量完成，温度：\(String(format: "%.2f", Double(temperature) * 0.01))℃")
                    self.hideLoading()
                    self.showSuccess("测量完成，温度：\(String(format: "%.2f", Double(temperature) * 0.01))℃")
                } else {
                    self.hideLoading()
                    BDLogger.error("无效的温度数据")
                    self.showError("无效的温度数据")
                }
            case let .failure(error):
                // 处理连接错误等其他错误
                BDLogger.error("读取温度失败: \(error)")
                self.showError("读取温度失败: \(error)")
            }
        }
    }
}
