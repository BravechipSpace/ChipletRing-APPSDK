//
//  MeasurementHeartRate_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  主动测量——心率-功能模块 (91-95)
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 主动测量——心率-功能模块(91-95)
class MeasurementHeartRate_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 91 ... 95)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 91: // 主动测量-开始心率测量
            showHeartRateConfigDialog()
        case 92: // 主动测量-停止心率测量
            stopHeartRateMeasurement()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods
    
    // 心率测量参数配置弹窗
    private func showHeartRateConfigDialog() {
        let contentView = HeartRateConfig_Dialog(x: 0, y: 0, width: 300, height: 450)
        contentView.confirmButtonCallback = { collectTime, collectFrequency, waveformConfig, progressConfig, intervalConfig in
            BDLogger.info("开始心率测量 - 采集时间:\(collectTime)秒, 采集频率:\(collectFrequency)Hz, 波形配置:\(waveformConfig), 进度配置:\(progressConfig), 间期配置:\(intervalConfig)")
            self.startHeartRateMeasurement(collectTime: collectTime,
                                          collectFrequency: collectFrequency,
                                          waveformConfig: waveformConfig,
                                          progressConfig: progressConfig,
                                          intervalConfig: intervalConfig)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    /// 91 - 主动测量-开始心率测量
    private func startHeartRateMeasurement(collectTime: Int, collectFrequency: Int, waveformConfig: Int, progressConfig: Int, intervalConfig: Int) {
        // 心率值
        var heartRateValue = 0
        // 心率变异性
        var hrvValue = 0
        // 精神压力指数
        var stressValue = 0
        // 温度值
        var temperatureValue = 0

        let callBacks = BCLHeartRateCallbacks(
            onProgress: { progress in
                BDLogger.info("测量进度: \(progress)%")
                self.showLoading("测量中... \(progress)%", userInteractionEnabled: false)
            },
            onStatusChanged: { status in
                switch status {
                case .completed:
                    BDLogger.info("测量完成")
                    self.hideLoading()
                    self.showSuccess("心率: \(heartRateValue)次/分\n心率变异性: \(hrvValue)\n精神压力指数: \(stressValue)\n温度: \(String(format: "%.2f°C", Double(temperatureValue) * 0.01))")
                    // 清理回调
                case .measuring:
                    BDLogger.info("测量中...")
                case .busy:
                    BDLogger.error("设备正忙，无法开始测量")
                    self.hideLoading()
                    self.showError("设备正忙，无法开始测量")
                case .notWearing:
                    BDLogger.error("设备未佩戴，请先佩戴设备")
                    self.hideLoading()
                    self.showError("设备未佩戴，请先佩戴设备")
                case .dataCollectionTimeout:
                    BDLogger.error("数据采集超时")
                    self.hideLoading()
                    self.showError("数据采集超时")
                default:
                    break
                }
            },
            onMeasureValue: { heartRate, heartRateVariability, stressIndex, temperature in
                BDLogger.info("心率: \(heartRate ?? 0)次/分")
                heartRateValue = heartRate ?? 0
                BDLogger.info("心率变异性: \(heartRateVariability ?? 0)")
                hrvValue = heartRateVariability ?? 0
                BDLogger.info("精神压力指数: \(stressIndex ?? 0)")
                stressValue = stressIndex ?? 0
                if let temp = temperature {
                    BDLogger.info("温度：\(String(format: "%.2f°C", Double(temp) * 0.01))")
                    temperatureValue = temp
                }
            },
            onWaveform: { seq, num, datas in
                // 处理波形数据
                BDLogger.info("波形数据: 序号\(seq), 数量\(num)")
                BDLogger.info("波形数据: \(datas)")
            },
            onRRInterval: { seq, num, datas in
                // 处理间期数据
                BDLogger.info("间期数据: 序号\(seq), 数量\(num)")
                BDLogger.info("间期数据: \(datas)")
            },
            onError: { error in
                BDLogger.info("错误: \(error)")
                self.hideLoading()
                switch error {
                case .heartRate(.notWearing):
                    self.showError("设备未佩戴，无法测量")
                case .heartRate(.busy):
                    self.showError("设备正忙，无法测量")
                default:
                    self.showError("测量过程中发生错误: \(error)")
                }
            }
        )

        // 开始测量
        BCLRingManager.shared.startHeartRate(collectTime: collectTime,
                                             collectFrequency: collectFrequency,
                                             waveformConfig: waveformConfig,
                                             progressConfig: progressConfig,
                                             intervalConfig: intervalConfig,
                                             callbacks: callBacks) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                BDLogger.error("启动心率测量失败: \(error)")
                if case .heartRate(.measurementStopped) = error { // 停止测量
                    self.hideLoading()
                }
            }
        }
    }

    /// 92 - 主动测量-停止心率测量
    private func stopHeartRateMeasurement() {
        BCLRingManager.shared.stopHeartRate { result in
            switch result {
            case .success:
                BDLogger.info("已停止心率测量")
                self.showSuccess("已停止心率测量")
            case let .failure(error):
                BDLogger.error("停止心率测量失败: \(error)")
                self.showError("停止心率测量失败: \(error)")
            }
        }
    }
}
