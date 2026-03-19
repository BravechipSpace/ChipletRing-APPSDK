//
//  MeasurementQingHuaPPG_Module.swift
//  BCLRingSDKDemo
//
//  Created by Codex on 2026/3/12.
//  主动测量——清华实时PPG-功能模块 (131-132)
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 主动测量——清华实时PPG-功能模块(131-132)
class MeasurementQingHuaPPG_Module: BaseFunction_Module {
    // MARK: - Properties

    private var waveformPacketCount = 0
    private var waveformSampleCount = 0
    private var latestRRICount = 0
    private var latestResult: BCLQingHuaPPGResultData?
    private var lastMeasurementTime: BCLQingHuaPPGMeasurementTimeData?

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 131 ... 132)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 131:
            showQingHuaPPGConfigDialog()
        case 132:
            stopQingHuaPPGMeasurement()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    private func showQingHuaPPGConfigDialog() {
        let contentView = QingHuaPPGConfig_Dialog(x: 0, y: 0, width: 320, height: 520)
        contentView.confirmButtonCallback = { collectTime,
                                              collectFrequency,
                                              greenLEDCurrent,
                                              infraredLEDCurrent,
                                              redLEDCurrent,
                                              progressConfig,
                                              waveformConfig in
            BDLogger.info("""
            开始清华实时PPG测量 - 采集时间:\(collectTime)秒, 采集频率:\(collectFrequency)Hz, \
            绿灯电流:\(greenLEDCurrent), 红外灯电流:\(infraredLEDCurrent), 红灯电流:\(redLEDCurrent), \
            进度配置:\(progressConfig), 波形配置:\(waveformConfig)
            """)
            self.startQingHuaPPGMeasurement(collectTime: collectTime,
                                            collectFrequency: collectFrequency,
                                            greenLEDCurrent: greenLEDCurrent,
                                            infraredLEDCurrent: infraredLEDCurrent,
                                            redLEDCurrent: redLEDCurrent,
                                            progressConfig: progressConfig,
                                            waveformConfig: waveformConfig)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func startQingHuaPPGMeasurement(collectTime: Int,
                                            collectFrequency: Int,
                                            greenLEDCurrent: Int,
                                            infraredLEDCurrent: Int,
                                            redLEDCurrent: Int,
                                            progressConfig: Int,
                                            waveformConfig: Int)
    {
        resetMeasurementState()

        let callbacks = BCLQingHuaPPGMeasurementCallbacks(
            onTime: { timeData in
                self.lastMeasurementTime = timeData
                BDLogger.info("清华实时PPG时间回调 - UTC: \(self.string(from: timeData.utcDate)), 本地: \(self.string(from: timeData.localDate))")
            },
            onWaveform: { waveformData in
                self.waveformPacketCount += 1
                self.waveformSampleCount += waveformData.samples.count
                BDLogger.info("清华实时PPG波形回调 - 包序号: \(waveformData.seq), 组数: \(waveformData.dataNum), 样本数: \(waveformData.samples.count)")
            },
            onRRI: { rriData in
                self.latestRRICount = rriData.count
                let previewValues = Array(rriData.values.prefix(5))
                BDLogger.info("清华实时PPG RRI回调 - 数量: \(rriData.count), 预览: \(previewValues)")
            },
            onResult: { resultData in
                self.latestResult = resultData
                self.hideLoading()
                BDLogger.info("清华实时PPG结果回调 - 心率: \(resultData.heartRate), 血氧: \(resultData.oxygen), 温度原始值: \(resultData.temperatureRaw)")
                self.showSuccess(self.measurementSummary(resultData: resultData))
                // 结果值会在测量过程中持续上报，不能在这里提前清理回调。
            },
            onProgress: { progress in
                BDLogger.info("清华实时PPG测量进度: \(progress)%")
                self.showLoading("清华实时PPG测量中... \(progress)%", userInteractionEnabled: false)
            },
            onError: { error in
                BDLogger.error("清华实时PPG测量错误: \(error)")
                self.hideLoading()
                self.showError("清华实时PPG测量失败: \(error.localizedDescription)")
                BCLQingHuaPPGMeasurementResponse.cleanupCurrentMeasurement()
            }
        )

        showLoading("清华实时PPG测量已启动...", userInteractionEnabled: false)
        BCLRingManager.shared.startQingHuaPPGMeasurement(collectTime: collectTime,
                                                         collectFrequency: collectFrequency,
                                                         greenLEDCurrent: greenLEDCurrent,
                                                         infraredLEDCurrent: infraredLEDCurrent,
                                                         redLEDCurrent: redLEDCurrent,
                                                         progressConfig: progressConfig,
                                                         waveformConfig: waveformConfig,
                                                         callbacks: callbacks) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                if case .qingHuaPPGMeasurement(.measurementStopped) = error {
                    self.hideLoading()
                    return
                }
                BDLogger.error("启动清华实时PPG测量失败: \(error)")
                self.hideLoading()
                self.showError("启动清华实时PPG测量失败: \(error.localizedDescription)")
                BCLQingHuaPPGMeasurementResponse.cleanupCurrentMeasurement()
            }
        }
    }

    private func stopQingHuaPPGMeasurement() {
        BCLRingManager.shared.stopQingHuaPPGMeasurement { result in
            switch result {
            case .success:
                BDLogger.info("已停止清华实时PPG测量")
                self.hideLoading()
                self.showSuccess("已停止清华实时PPG测量")
                BCLQingHuaPPGMeasurementResponse.cleanupCurrentMeasurement()
            case let .failure(error):
                BDLogger.error("停止清华实时PPG测量失败: \(error)")
                self.hideLoading()
                self.showError("停止清华实时PPG测量失败: \(error.localizedDescription)")
            }
        }
    }

    private func resetMeasurementState() {
        waveformPacketCount = 0
        waveformSampleCount = 0
        latestRRICount = 0
        latestResult = nil
        lastMeasurementTime = nil
    }

    private func measurementSummary(resultData: BCLQingHuaPPGResultData) -> String {
        var message = """
        心率: \(resultData.heartRate)次/分
        血氧: \(resultData.oxygen)%
        温度: \(String(format: "%.2f°C", Double(resultData.temperatureRaw) * 0.01))
        波形包数: \(waveformPacketCount)
        波形样本数: \(waveformSampleCount)
        RRI数量: \(latestRRICount)
        """

        if let timeData = lastMeasurementTime {
            message += "\n时间: \(string(from: timeData.localDate))"
        }
        return message
    }

    private func string(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
