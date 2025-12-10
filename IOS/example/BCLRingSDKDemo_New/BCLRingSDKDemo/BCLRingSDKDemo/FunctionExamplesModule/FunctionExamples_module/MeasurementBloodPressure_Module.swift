//
//  MeasurementBloodPressure_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  主动测量——血压-功能模块 (96-100)
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 主动测量——血压-功能模块(96-100)
class MeasurementBloodPressure_Module: BaseFunction_Module {
    // MARK: - Properties

    private var bloodPressureWaveData: [(Int, Int, Int, Int, Int)] = []

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 96 ... 100)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 96: // 主动测量-开始血压测量
            showBloodPressureConfigDialog()
        case 97: // 主动测量-停止血压测量
            stopBloodPressureMeasurement()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 血压测量参数配置弹窗
    private func showBloodPressureConfigDialog() {
        let contentView = BloodPressureConfig_Dialog(x: 0, y: 0, width: 300, height: 350)
        contentView.confirmButtonCallback = { collectTime, waveformConfig, progressConfig in
            BDLogger.info("开始血压测量 - 采集时间:\(collectTime)秒, 波形配置:\(waveformConfig), 进度配置:\(progressConfig)")
            self.startBloodPressureMeasurement(collectTime: collectTime,
                                              waveformConfig: waveformConfig,
                                              progressConfig: progressConfig)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    /// 96 - 主动测量-开始血压测量
    private func startBloodPressureMeasurement(collectTime: Int, waveformConfig: Int, progressConfig: Int) {
        // 清除历史波形数据
        bloodPressureWaveData = []
        // 设置回调
        BCLBloodPressureResponse.setCallbacks(BCLBloodPressureCallbacks(
            onProgress: { progress in
                BDLogger.info("测量进度: \(progress)%")
                self.showLoading("测量中... \(progress)%", userInteractionEnabled: false)
            },
            onStatusChanged: { status in
                switch status {
                case .completed:
                    BDLogger.info("血压测量完成")
                    BDLogger.info("血压波形数据量:\(self.bloodPressureWaveData.count)")
                    self.hideLoading()
                    self.showLoading("正在计算血压数据...")

                    let mac = BCLRingManager.shared.currentConnectedDevice?.macAddress ?? ""
                    BDLogger.info("Mac地址:\(mac)")

                    // 注意：此处需要将戒指的mac地址和采集到的波形数据上传至云端进行血压计算
                    // 注意：该接口需要使用到Token，请确保已登录并获取到Token
                    // 血压云端算法
                    BCLRingManager.shared.uploadBloodPressureData(mac: mac, waveData: self.bloodPressureWaveData) { res in
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
            onMeasureValue: { heartRate, systolicPressure, diastolicPressure in
                BDLogger.info("心率: \(heartRate ?? 0)次/分")
                BDLogger.info("收缩压: \(systolicPressure ?? 0)")
                BDLogger.info("舒张压: \(diastolicPressure ?? 0)")
            },
            onWaveform: { seq, num, datas in
                // 处理波形数据
                BDLogger.info("波形数据: 序号\(seq), 数量\(num)")
                switch datas {
                case let .redAndInfrared(waveData):
                    BDLogger.info("波形数据数量: \(waveData.count)")
                    // 将波形数据添加到数组中
                    self.bloodPressureWaveData.append(contentsOf: waveData)
                default:
                    BDLogger.error("不支持的波形数据类型")
                }
            },
            onError: { error in
                BDLogger.info("错误: \(error)")
                self.hideLoading()
                switch error {
                case .bloodPressure(.notWearing):
                    self.showError("设备未佩戴，无法测量")
                case .bloodPressure(.busy):
                    self.showError("设备正忙，无法测量")
                default:
                    self.showError("测量过程中发生错误: \(error)")
                }
            }
        ))

        // 开始测量
        /// - Parameters:
        ///   - collectTime: 采集时间(单位：秒)
        ///   - waveformConfig: 波形配置(0:不上传 1:上传)
        ///   - progressConfig: 进度配置(0:不上传 1:上传)
        ///   注意：此处无特殊需求，建议使用默认值
        BCLRingManager.shared.startBloodPressure(collectTime: collectTime,
                                                 waveformConfig: waveformConfig,
                                                 progressConfig: progressConfig) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                BDLogger.error("启动血血压测量失败: \(error)")
                if case .bloodPressure(.measurementStopped) = error { // 停止测量
                    self.hideLoading()
                }
            }
        }
    }

    /// 97 - 主动测量-停止血压测量
    private func stopBloodPressureMeasurement() {
        BCLRingManager.shared.stopBloodPressure { result in
            switch result {
            case .success:
                BDLogger.info("已停止血压测量")
                self.showSuccess("已停止血压测量")
            case let .failure(error):
                BDLogger.error("停止血压测量失败: \(error)")
                self.showError("停止血压测量失败: \(error)")
            }
        }
    }
}
