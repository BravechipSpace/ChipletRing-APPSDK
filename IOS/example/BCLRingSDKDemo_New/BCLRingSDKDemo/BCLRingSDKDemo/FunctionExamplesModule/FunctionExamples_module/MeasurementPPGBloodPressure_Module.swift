//
//  MeasurementPPGBloodPressure_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2026/1/22.
//  主动测量——PPG血压曲线-功能模块 (98-99)

import BCLRingSDK
import QMUIKit
import UIKit

/// 主动测量——PPG血压曲线-功能模块(98-99)
class MeasurementPPGBloodPressure_Module: BaseFunction_Module {
    // MARK: - Properties

    private var ppgBloodPressureWaveData: [Int] = []

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 98 ... 99)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 98: // 主动测量-开始PPG血压曲线测量
            showPPGBloodPressureConfigDialog()
        case 99: // 主动测量-停止PPG血压曲线测量
            stopPPGBloodPressureMeasurement()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // PPG血压曲线测量参数配置弹窗
    private func showPPGBloodPressureConfigDialog() {
        let contentView = PPGBloodPressureConfig_Dialog(x: 0, y: 0, width: 300, height: 350)
        contentView.confirmButtonCallback = { collectTime, waveformConfig, progressConfig in
            BDLogger.info("开始PPG血压曲线测量 - 采集时间:\(collectTime)秒, 波形配置:\(waveformConfig), 进度配置:\(progressConfig)")
            self.startPPGBloodPressureMeasurement(collectTime: collectTime,
                                                  waveformConfig: waveformConfig,
                                                  progressConfig: progressConfig)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    /// 98 - 主动测量-开始PPG血压曲线测量
    private func startPPGBloodPressureMeasurement(collectTime: Int, waveformConfig: Int, progressConfig: Int) {
        // 清除历史波形数据
        ppgBloodPressureWaveData = []

        // 设置回调
        let callbacks = BCLPPGBloodPressureCallbacks(
            onProgress: { progress in
                BDLogger.info("PPG血压曲线测量进度: \(progress)%")
                self.showLoading("测量中... \(progress)%", userInteractionEnabled: false)
            },
            onMeasureValue: { diastolicPressure, systolicPressure in
                BDLogger.info("舒张压: \(diastolicPressure)")
                BDLogger.info("收缩压: \(systolicPressure)")
                self.hideLoading()
                self.showSuccess("测量完成 - 舒张压:\(diastolicPressure) 收缩压:\(systolicPressure)\n波形数据量:\(self.ppgBloodPressureWaveData.count)")
            },
            onWaveform: { seq, dataLength, waveData in
                // 处理波形数据
                BDLogger.info("PPG血压波形数据: 序号\(seq), 数据长度\(dataLength), 实际数据量\(waveData.count)")
                // 将波形数据添加到数组中
                self.ppgBloodPressureWaveData.append(contentsOf: waveData)
            },
            onError: { error in
                BDLogger.error("PPG血压曲线测量错误: \(error)")
                self.hideLoading()
                self.showError("测量过程中发生错误: \(error.localizedDescription)")
            }
        )

        // 开始测量
        /// - Parameters:
        ///   - collectTime: 采集时间(单位：秒)，默认60，0为一直采集（保留）
        ///   - waveformConfig: 波形配置(0:不上传 1:上传)
        ///   - progressConfig: 进度配置(0:不上传 1:上传)
        ///   注意：此处无特殊需求，建议使用默认值
        BCLRingManager.shared.startPPGBloodPressure(collectTime: collectTime,
                                                     waveformConfig: waveformConfig,
                                                     progressConfig: progressConfig,
                                                     callbacks: callbacks) { result in
            switch result {
            case .success:
                BDLogger.info("PPG血压曲线测量已启动")
            case let .failure(error):
                BDLogger.error("启动PPG血压曲线测量失败: \(error)")
                self.hideLoading()
                self.showError("启动测量失败: \(error.localizedDescription)")
            }
        }
    }

    /// 99 - 主动测量-停止PPG血压曲线测量
    private func stopPPGBloodPressureMeasurement() {
        BCLRingManager.shared.stopPPGBloodPressure { result in
            switch result {
            case .success:
                BDLogger.info("已停止PPG血压曲线测量")
                self.showSuccess("已停止PPG血压曲线测量")
            case let .failure(error):
                BDLogger.error("停止PPG血压曲线测量失败: \(error)")
                self.showError("停止PPG血压曲线测量失败: \(error)")
            }
        }
    }
}
