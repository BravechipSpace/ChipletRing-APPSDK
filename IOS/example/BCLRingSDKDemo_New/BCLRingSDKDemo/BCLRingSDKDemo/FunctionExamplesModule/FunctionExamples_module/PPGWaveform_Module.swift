//
//  PPGWaveform_Module.swift
//  BCLRingSDKDemo
//
//  Created by Codex on 2026/8/2.
//  PPG波形透传输-功能模块 (150-152)
//

import BCLRingSDK
import UIKit

/// PPG波形透传输-功能模块(150-152)
class PPGWaveform_Module: BaseFunction_Module {
    // MARK: - Properties

    private var waveformPacketCount = 0
    private var waveformSampleCount = 0
    private var latestHeartRate = 0
    private var latestOxygen = 0

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 150 ... 152)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 150: // 开始PPG波形透传输
            showPPGWaveformConfigDialog()
        case 151: // 停止PPG波形透传输
            stopPPGWaveformMeasurement()
        case 152: // 设置PPG波形电流
            showPPGWaveformCurrentDialog()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 显示PPG波形透传输参数配置弹窗
    private func showPPGWaveformConfigDialog() {
        let alert = UIAlertController(title: "PPG波形透传输",
                                      message: "请输入测量参数",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "采集时间（秒，0为一直采集）"
            textField.keyboardType = .numberPad
            textField.text = "30"
        }
        alert.addTextField { textField in
            textField.placeholder = "波形配置（0不上传，1上传）"
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        alert.addTextField { textField in
            textField.placeholder = "进度配置（0不上传，1上传）"
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        alert.addTextField { textField in
            textField.placeholder = "波形设置（0/1/2/3/4/5/6/7/8/9/12/13）"
            textField.keyboardType = .numberPad
            textField.text = "0"
        }
        alert.addTextField { textField in
            textField.placeholder = "波形子配置"
            textField.keyboardType = .numberPad
            textField.text = "0"
        }

        let startAction = UIAlertAction(title: "开始", style: .default) { _ in
            guard let collectTimeText = alert.textFields?[0].text,
                  let waveConfigText = alert.textFields?[1].text,
                  let progressConfigText = alert.textFields?[2].text,
                  let waveSettingText = alert.textFields?[3].text,
                  let waveSubConfigText = alert.textFields?[4].text,
                  let collectTime = Int(collectTimeText),
                  let waveConfig = Int(waveConfigText),
                  let progressConfig = Int(progressConfigText),
                  let waveSetting = Int(waveSettingText),
                  let waveSubConfig = Int(waveSubConfigText),
                  self.isUInt8Value(collectTime),
                  self.isUInt8Value(waveConfig),
                  self.isUInt8Value(progressConfig),
                  self.isUInt8Value(waveSetting),
                  self.isUInt8Value(waveSubConfig) else {
                self.showError("请输入0-255范围内的有效参数")
                return
            }
            self.startPPGWaveformMeasurement(collectTime: collectTime,
                                             waveConfig: waveConfig,
                                             progressConfig: progressConfig,
                                             waveSetting: waveSetting,
                                             waveSubConfig: waveSubConfig)
        }
        alert.addAction(startAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    /// 150 - 开始PPG波形透传输
    private func startPPGWaveformMeasurement(collectTime: Int,
                                             waveConfig: Int,
                                             progressConfig: Int,
                                             waveSetting: Int,
                                             waveSubConfig: Int)
    {
        resetMeasurementState()

        let callbacks = BCLPPGWaveFormCallbacks(
            onProgress: { progress in
                BDLogger.info("PPG波形透传输进度: \(progress)%")
                self.showLoading("PPG波形透传输中... \(progress)%", userInteractionEnabled: false)
            },
            onStatusChanged: { status in
                BDLogger.info("PPG波形透传输状态: \(status)")
                if status == .completed {
                    self.hideLoading()
                    self.showSuccess(self.measurementSummary())
                }
            },
            onMeasureValue: { heartRate, oxygen in
                self.latestHeartRate = heartRate ?? 0
                self.latestOxygen = oxygen ?? 0
                BDLogger.info("PPG波形透传输测量值 - 心率: \(self.latestHeartRate), 血氧: \(self.latestOxygen)")
            },
            onWaveform0: { seq, num, values in
                self.waveformPacketCount += 1
                self.waveformSampleCount += values.count
                BDLogger.info("PPG绿色波形 - 序号: \(seq), 声明数量: \(num), 实际数量: \(values.count)")
            },
            onWaveform1: { seq, num, values in
                self.waveformPacketCount += 1
                self.waveformSampleCount += values.count
                BDLogger.info("PPG绿色+红外波形 - 序号: \(seq), 声明数量: \(num), 实际数量: \(values.count)")
            },
            onWaveformPacket: { packet in
                BDLogger.info("PPG通用波形包 - 序号: \(packet.seq), 数量: \(packet.dataNum), 波形设置: \(packet.waveSettingRawValue), payload长度: \(packet.payload.count)")
            },
            onError: { error in
                BDLogger.error("PPG波形透传输错误: \(error)")
                self.hideLoading()
                self.showError("PPG波形透传输失败: \(error.localizedDescription)")
                BCLPPGWaveFormResponse.cleanupCurrentMeasurement()
            }
        )

        BCLPPGWaveFormResponse.setCallbacks(callbacks)
        showLoading("PPG波形透传输已启动...", userInteractionEnabled: false)
        BCLRingManager.shared.ppgWaveFormMeasurement(collectTime: collectTime,
                                                     waveConfig: waveConfig,
                                                     progressConfig: progressConfig,
                                                     waveSetting: waveSetting,
                                                     waveSubConfig: waveSubConfig) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                if case .ppgWaveForm(.measurementStopped) = error {
                    self.hideLoading()
                    return
                }
                BDLogger.error("启动PPG波形透传输失败: \(error)")
                self.hideLoading()
                self.showError("启动PPG波形透传输失败: \(error.localizedDescription)")
                BCLPPGWaveFormResponse.cleanupCurrentMeasurement()
            }
        }
    }

    /// 151 - 停止PPG波形透传输
    private func stopPPGWaveformMeasurement() {
        BCLRingManager.shared.ppgWaveFormStop { result in
            switch result {
            case .success:
                BDLogger.info("已停止PPG波形透传输")
                self.hideLoading()
                self.showSuccess("已停止PPG波形透传输")
                BCLPPGWaveFormResponse.cleanupCurrentMeasurement()
            case let .failure(error):
                BDLogger.error("停止PPG波形透传输失败: \(error)")
                self.hideLoading()
                self.showError("停止PPG波形透传输失败: \(error.localizedDescription)")
            }
        }
    }

    /// 显示设置PPG波形电流弹窗
    private func showPPGWaveformCurrentDialog() {
        let alert = UIAlertController(title: "设置PPG波形电流",
                                      message: "请输入4个电流档位（每档0.25mA）",
                                      preferredStyle: .alert)
        for index in 0 ..< 4 {
            alert.addTextField { textField in
                textField.placeholder = "电流档位\(index)"
                textField.keyboardType = .numberPad
                textField.text = "0"
            }
        }
        let setAction = UIAlertAction(title: "设置", style: .default) { _ in
            guard let textFields = alert.textFields, textFields.count == 4 else {
                self.showError("电流参数数量错误")
                return
            }
            var currents: [UInt8] = []
            for textField in textFields {
                guard let text = textField.text,
                      let value = Int(text),
                      self.isUInt8Value(value) else {
                    self.showError("请输入0-255范围内的电流档位")
                    return
                }
                currents.append(UInt8(value))
            }
            self.setPPGWaveformCurrent(currents: currents)
        }
        alert.addAction(setAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    /// 152 - 设置PPG波形电流
    private func setPPGWaveformCurrent(currents: [UInt8]) {
        BCLRingManager.shared.setPPGWaveFormCurrent(currents: currents) { result in
            switch result {
            case .success:
                BDLogger.info("设置PPG波形电流成功: \(currents)")
                self.showSuccess("设置PPG波形电流成功: \(currents)")
            case let .failure(error):
                BDLogger.error("设置PPG波形电流失败: \(error)")
                self.showError("设置PPG波形电流失败: \(error.localizedDescription)")
            }
        }
    }

    private func resetMeasurementState() {
        waveformPacketCount = 0
        waveformSampleCount = 0
        latestHeartRate = 0
        latestOxygen = 0
    }

    private func measurementSummary() -> String {
        return """
        心率：\(latestHeartRate)
        血氧：\(latestOxygen)
        波形包数：\(waveformPacketCount)
        波形样本数：\(waveformSampleCount)
        """
    }

    private func isUInt8Value(_ value: Int) -> Bool {
        return (0 ... Int(UInt8.max)).contains(value)
    }
}
