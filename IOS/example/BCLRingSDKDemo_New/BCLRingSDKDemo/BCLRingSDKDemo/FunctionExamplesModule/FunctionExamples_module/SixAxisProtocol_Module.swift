//
//  SixAxisProtocol_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  六轴协议功能模块 (301-320)
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 六轴协议功能模块 - 加速度、陀螺仪等六轴传感器相关功能
class SixAxisProtocol_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 301 ... 320)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 301: // 301-设置六轴传感器工作频率
            setSixAxisSensorFrequency()
        case 302: // 302-获取六轴传感器工作频率
            getSixAxisSensorFrequency()
        case 303: // 303-获取六轴传感器-加速度数据(单次)
            getSixAxisAccelerometerDataOnce()
        case 304: // 304-获取六轴传感器-陀螺仪数据(单次)
            getSixAxisGyroscopeDataOnce()
        case 305: // 305-获取六轴传感器-加速度和陀螺仪数据(单次)
            getSixAxisAccelerometerAndGyroscopeDataOnce()
        case 306: // 306-获取六轴传感器-加速度数据(开启后一直上传直至接收到停止指令)
            startContinuousAccelerometerDataUpload()
        case 307: // 307-获取六轴传感器-加速度和陀螺仪数据(开启后一直上传直至接收到停止指令)
            startContinuousAccelerometerAndGyroscopeDataUpload()
        case 308: // 308-停止六轴传感器数据上传
            stopSixAxisDataUpload()
        case 309: // 309-设置六轴传感器省电模式
            setSixAxisSensorPowerSavingMode()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 设置六轴传感器工作频率参数配置弹窗
    private func setSixAxisSensorFrequency() {
        let contentView = SixAxisFrequencyConfig_Dialog(x: 0, y: 0, width: 320, height: 380)
        contentView.confirmButtonCallback = { frequency in
            BDLogger.info("设置六轴传感器工作频率 - 加速度频率:\(frequency)Hz, 陀螺仪频率:\(frequency)Hz")
            // 加速度和陀螺仪使用相同的频率
            self.setSixAxisSensorFrequency(accelerationFrequency: frequency, gyroscopeFrequency: frequency)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 301-设置六轴传感器工作频率
    private func setSixAxisSensorFrequency(accelerationFrequency: Int, gyroscopeFrequency: Int) {
        // 注意：此处的频率值需参考具体设备支持的频率范围进行设置，且加速度和陀螺仪的频率需要保持一致
        BCLRingManager.shared.setSixAxisWorkFrequency(accelerationFrequency: accelerationFrequency, gyroscopeFrequency: gyroscopeFrequency) { res in
            switch res {
            case let .success(response):
                BDLogger.info("设置六轴传感器工作频率返回数据: \(response)")
                if let status = response.status, status == 1 {
                    BDLogger.info("设置六轴传感器工作频率成功")
                    self.showSuccess("设置六轴传感器工作频率成功")
                } else {
                    BDLogger.info("设置六轴传感器工作频率失败")
                    self.showError("设置六轴传感器工作频率失败")
                }
            case let .failure(error):
                BDLogger.error("设置六轴传感器工作频率失败: \(error)")
                self.showError("设置六轴传感器工作频率失败: \(error)")
            }
        }
    }

    // 302-获取六轴传感器工作频率
    private func getSixAxisSensorFrequency() {
        BCLRingManager.shared.getSixAxisWorkFrequency { res in
            switch res {
            case let .success(response):
                BDLogger.info("获取六轴传感器工作频率返回数据: \(response)")
                BDLogger.info("加速度频率: \(response.accelerationFrequency ?? 0)")
                BDLogger.info("陀螺仪频率: \(response.gyroscopeFrequency ?? 0)")
                self.showSuccess("获取六轴传感器工作频率成功\n加速度频率: \(response.accelerationFrequency ?? 0)\n陀螺仪频率: \(response.gyroscopeFrequency ?? 0)")
            case let .failure(error):
                BDLogger.error("获取六轴传感器工作频率失败: \(error)")
                self.showError("获取六轴传感器工作频率失败: \(error)")
            }
        }
    }

    // 303-获取六轴传感器-加速度数据(单次)
    private func getSixAxisAccelerometerDataOnce() {
        BCLRingManager.shared.getSixAxisAccelerationData { res in
            switch res {
            case let .success(data):
                BDLogger.info("六轴-加速度-单次数据: \(data)")
                BDLogger.info("六轴-加速度-单次数据-状态: \(data.status ?? 0)")
                BDLogger.info("六轴-加速度-单次数据-X: \(data.xAcceleration ?? 0)")
                BDLogger.info("六轴-加速度-单次数据-Y: \(data.yAcceleration ?? 0)")
                BDLogger.info("六轴-加速度-单次数据-Z: \(data.zAcceleration ?? 0)")
                self.showSuccess("六轴-加速度-单次数据成功\n状态: \(data.status ?? 0)\nX: \(data.xAcceleration ?? 0)\nY: \(data.yAcceleration ?? 0)\nZ: \(data.zAcceleration ?? 0)")
            case let .failure(error):
                BDLogger.error("六轴-加速度-单次数据失败: \(error)")
                self.showError("六轴-加速度-单次数据失败: \(error)")
            }
        }
    }

    // 304-获取六轴传感器-陀螺仪数据(单次)
    private func getSixAxisGyroscopeDataOnce() {
        BCLRingManager.shared.getSixAxisGyroscopeData { res in
            switch res {
            case let .success(data):
                BDLogger.info("六轴-陀螺仪-单次数据: \(data)")
                BDLogger.info("六轴-陀螺仪-单次数据-状态: \(data.status ?? 0)")
                BDLogger.info("六轴-陀螺仪-单次数据-X: \(data.xGyroscope ?? 0)")
                BDLogger.info("六轴-陀螺仪-单次数据-Y: \(data.yGyroscope ?? 0)")
                BDLogger.info("六轴-陀螺仪-单次数据-Z: \(data.zGyroscope ?? 0)")
                self.showSuccess("六轴-陀螺仪-单次数据成功\n状态: \(data.status ?? 0)\nX: \(data.xGyroscope ?? 0)\nY: \(data.yGyroscope ?? 0)\nZ: \(data.zGyroscope ?? 0)")
            case let .failure(error):
                BDLogger.error("六轴-陀螺仪-单次数据失败: \(error)")
                self.showError("六轴-陀螺仪-单次数据失败: \(error)")
            }
        }
    }

    // 305-获取六轴传感器-加速度和陀螺仪数据(单次)
    private func getSixAxisAccelerometerAndGyroscopeDataOnce() {
        BCLRingManager.shared.getSixAxisAccelerationAndGyroscopeData { res in
            switch res {
            case let .success(data):
                BDLogger.info("六轴-加速度、陀螺仪-单次数据: \(data)")
                BDLogger.info("六轴-加速度、陀螺仪-单次数据-状态: \(data.status ?? 0)")
                BDLogger.info("六轴-加速度、陀螺仪-单次数据-xAcceleration: \(data.xAcceleration ?? 0)")
                BDLogger.info("六轴-加速度、陀螺仪-单次数据-yAcceleration: \(data.yAcceleration ?? 0)")
                BDLogger.info("六轴-加速度、陀螺仪-单次数据-zAcceleration: \(data.zAcceleration ?? 0)")
                BDLogger.info("六轴-加速度、陀螺仪-单次数据-xGyroscope: \(data.xGyroscope ?? 0)")
                BDLogger.info("六轴-加速度、陀螺仪-单次数据-yGyroscope: \(data.yGyroscope ?? 0)")
                BDLogger.info("六轴-加速度、陀螺仪-单次数据-zGyroscope: \(data.zGyroscope ?? 0)")
                self.showSuccess("六轴-加速度、陀螺仪-单次数据成功\n状态: \(data.status ?? 0)\nX加速度: \(data.xAcceleration ?? 0)\nY加速度: \(data.yAcceleration ?? 0)\nZ加速度: \(data.zAcceleration ?? 0)\nX陀螺仪: \(data.xGyroscope ?? 0)\nY陀螺仪: \(data.yGyroscope ?? 0)\nZ陀螺仪: \(data.zGyroscope ?? 0)")
            case let .failure(error):
                BDLogger.error("六轴-加速度、陀螺仪-单次数据失败: \(error)")
                self.showError("六轴-加速度、陀螺仪-单次数据失败: \(error)")
            }
        }
    }

    // 306-获取六轴传感器-加速度数据(开启后一直上传直至接收到停止指令)
    private func startContinuousAccelerometerDataUpload() {
        BCLRingManager.shared.getSixAxisRealTimeAccelerationData { res in
            switch res {
            case let .success(data):
                BDLogger.info("六轴-加速度-持续数据: \(data)")
                BDLogger.info("六轴-加速度-持续数据-状态: \(data.status ?? 0)")
                BDLogger.info("六轴-加速度-持续数据-X: \(data.xAcceleration ?? 0)")
                BDLogger.info("六轴-加速度-持续数据-Y: \(data.yAcceleration ?? 0)")
                BDLogger.info("六轴-加速度-持续数据-Z: \(data.zAcceleration ?? 0)")
                self.showSuccess("六轴-加速度-持续数据成功\n状态: \(data.status ?? 0)\nX: \(data.xAcceleration ?? 0)\nY: \(data.yAcceleration ?? 0)\nZ: \(data.zAcceleration ?? 0)")
            case let .failure(error):
                BDLogger.error("六轴-加速度-持续数据失败: \(error)")
                self.showError("六轴-加速度-持续数据失败: \(error)")
            }
        }
    }

    // 307-获取六轴传感器-加速度和陀螺仪数据(开启后一直上传直至接收到停止指令)
    private func startContinuousAccelerometerAndGyroscopeDataUpload() {
        BCLRingManager.shared.getSixAxisRealTimeGyroscopeData { res in
            switch res {
            case let .success(data):
                BDLogger.info("六轴-陀螺仪-持续数据: \(data)")
                BDLogger.info("六轴-陀螺仪-持续数据-状态: \(data.status ?? 0)")
                BDLogger.info("六轴-陀螺仪-持续数据-X: \(data.xGyroscope ?? 0)")
                BDLogger.info("六轴-陀螺仪-持续数据-Y: \(data.yGyroscope ?? 0)")
                BDLogger.info("六轴-陀螺仪-持续数据-Z: \(data.zGyroscope ?? 0)")
                self.showSuccess("六轴-陀螺仪-持续数据成功\n状态: \(data.status ?? 0)\nX: \(data.xGyroscope ?? 0)\nY: \(data.yGyroscope ?? 0)\nZ: \(data.zGyroscope ?? 0)")
            case let .failure(error):
                BDLogger.error("六轴-陀螺仪-持续数据失败: \(error)")
                self.showError("六轴-陀螺仪-持续数据失败: \(error)")
            }
        }
    }

    // 308-停止六轴传感器数据上传
    private func stopSixAxisDataUpload() {
        BCLRingManager.shared.stopSixAxisData { res in
            switch res {
            case .success:
                BDLogger.info("停止采集获取六轴数据成功")
                self.showSuccess("停止采集获取六轴数据成功")
            case let .failure(error):
                BDLogger.error("停止采集获取六轴数据失败: \(error)")
                self.showError("停止采集获取六轴数据失败: \(error)")
            }
        }
    }

    // 309-设置六轴传感器省电模式
    private func setSixAxisSensorPowerSavingMode() {
        BCLRingManager.shared.setSixAxisPowerSavingMode { res in
            switch res {
            case let .success(response):
                BDLogger.info("设置六轴传感器省电模式返回数据: \(response)")
                if let status = response.status, status == 1 {
                    BDLogger.info("设置六轴传感器省电模式-成功")
                    self.showSuccess("设置六轴传感器省电模式-成功")
                } else {
                    BDLogger.info("设置六轴传感器省电模式-失败")
                    self.showError("设置六轴传感器省电模式-失败")
                }
            case let .failure(error):
                BDLogger.error("设置六轴传感器省电模式失败: \(error)")
                self.showError("设置六轴传感器省电模式失败: \(error)")
            }
        }
    }
}
