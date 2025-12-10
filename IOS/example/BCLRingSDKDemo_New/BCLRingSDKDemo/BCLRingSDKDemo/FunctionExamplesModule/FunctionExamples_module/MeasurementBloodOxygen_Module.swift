//
//  MeasurementBloodOxygen_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  主动测量——血氧-功能模块 (86-90)
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 主动测量——血氧-功能模块 (86-90)
class MeasurementBloodOxygen_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 86 ... 90)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 86: // 主动测量-开始血氧测量
            showBloodOxygenConfigDialog()
        case 87: // 主动测量-停止血氧测量
            stopBloodOxygenMeasurement()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 血氧测量参数配置弹窗
    private func showBloodOxygenConfigDialog() {
        let contentView = BloodOxygenConfig_Dialog(x: 0, y: 0, width: 300, height: 400)
        contentView.confirmButtonCallback = { collectTime, collectFrequency, waveformConfig, progressConfig in
            BDLogger.info("开始血氧测量 - 采集时间:\(collectTime)秒, 采集频率:\(collectFrequency)Hz, 波形配置:\(waveformConfig), 进度配置:\(progressConfig)")
            self.startBloodOxygenMeasurement(collectTime: collectTime,
                                             collectFrequency: collectFrequency,
                                             waveformConfig: waveformConfig,
                                             progressConfig: progressConfig)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    /// 86 - 主动测量-开始血氧测量
    private func startBloodOxygenMeasurement(collectTime: Int, collectFrequency: Int, waveformConfig: Int, progressConfig: Int) {
        // 血氧值
        var bloodOxygenValue = 0
        // 心率值
        var heartRateValue = 0
        // 温度值
        var temperatureValue = 0

        // 设置回调
        BCLBloodOxygenResponse.setCallbacks(BCLBloodOxygenCallbacks(
            onProgress: { progress in
                BDLogger.info("测量进度: \(progress)%")
                self.showLoading("测量中... \(progress)%", userInteractionEnabled: false)
            },
            onStatusChanged: { status in
                switch status {
                case .completed:
                    BDLogger.info("测量完成")
                    self.hideLoading()
                    self.showSuccess("血氧: \(bloodOxygenValue)%\n心率: \(heartRateValue)次/分\n温度: \(String(format: "%.2f°C", Double(temperatureValue) * 0.01))")
                    // 清理回调
                    BCLBloodOxygenResponse.cleanupCurrentMeasurement()
                case .measuring:
                    BDLogger.info("测量中...")
                case .busy:
                    BDLogger.error("设备正忙，无法开始测量")
                    self.hideLoading()
                    self.showError("设备正忙，无法开始测量")
                    // 清理回调
                    BCLBloodOxygenResponse.cleanupCurrentMeasurement()
                case .chargingNotAllowed:
                    BDLogger.error("设备正在充电，无法测量")
                    self.hideLoading()
                    self.showError("设备正在充电，无法测量")
                    // 清理回调
                    BCLBloodOxygenResponse.cleanupCurrentMeasurement()
                case .notWearing:
                    BDLogger.error("设备未佩戴，请先佩戴设备")
                    self.hideLoading()
                    self.showError("设备未佩戴，请先佩戴设备")
                    // 清理回调
                    BCLBloodOxygenResponse.cleanupCurrentMeasurement()
                case .dataCollectionTimeout:
                    BDLogger.error("数据采集超时")
                    self.hideLoading()
                    self.showError("数据采集超时")
                    // 清理回调
                    BCLBloodOxygenResponse.cleanupCurrentMeasurement()
                default:
                    break
                }
            },
            onMeasureValue: { bloodOxygen, heartRate, temperature in
                BDLogger.info("血氧: \(bloodOxygen ?? 0)%")
                bloodOxygenValue = bloodOxygen ?? 0
                BDLogger.info("心率: \(heartRate ?? 0)次/分")
                heartRateValue = heartRate ?? 0
                // 温度 (需要先解包，然后转换)
                if let temp = temperature {
                    BDLogger.info("温度：\(String(format: "%.2f°C", Double(temp) * 0.01))")
                    temperatureValue = temp
                }

            },
            onPerfusionRate: { rate in
                BDLogger.info("灌注率: \(rate)")
            },
            onBloodPressure: { diastolic, systolic in
                BDLogger.info("血压: \(systolic)/\(diastolic)mmHg")
            },
            onWaveform: { seq, num, datas in
                // 处理波形数据
                BDLogger.info("波形数据: 序号\(seq), 数量\(num)")
                BDLogger.info("波形数据: \(datas)")
            },
            onError: { error in
                BDLogger.info("错误: \(error)")
                self.hideLoading()
                switch error {
                case .bloodOxygen(.notWearing):
                    self.showError("设备未佩戴，无法测量")
                case .bloodOxygen(.chargingNotAllowed):
                    self.showError("设备正在充电，无法测量")
                case .bloodOxygen(.busy):
                    self.showError("设备正忙，无法测量")
                default:
                    self.showError("测量过程中发生错误: \(error)")
                }
            }
        ))

        // 开始测量
        // 注意：此处的参数需要根据实际需求进行调整
        BCLRingManager.shared.startBloodOxygen(collectTime: collectTime,
                                               collectFrequency: collectFrequency,
                                               waveformConfig: waveformConfig,
                                               progressConfig: progressConfig) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                BDLogger.error("启动血氧测量失败: \(error)")
                if case .bloodOxygen(.measurementStopped) = error { // 停止测量
                    self.hideLoading()
                }
                // 发生错误时清理回调
                BCLBloodOxygenResponse.cleanupCurrentMeasurement()
            }
        }
    }

    /// 87 - 主动测量-停止血氧测量
    private func stopBloodOxygenMeasurement() {
        BCLRingManager.shared.stopBloodOxygen { result in
            switch result {
            case .success:
                BDLogger.info("已停止血氧测量")
                self.showSuccess("已停止血氧测量")
            case let .failure(error):
                BDLogger.error("停止血氧测量失败: \(error)")
                self.showError("停止血氧测量失败: \(error)")
            }
        }
    }
}
