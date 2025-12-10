//
//  TenMeterSixAxisThreeAxisProtocol_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  十米游戏：六轴、三轴协议功能模块 (321-325)
//

import BCLRingSDK
import UIKit

/// 十米游戏：六轴、三轴协议功能模块 (321-325) 六轴、三轴开始、停止、加速度计校准等功能
class TenMeterSixAxisThreeAxisProtocol_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 321 ... 325)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 321: // 321 - 六轴开始
            startSixAxis()
        case 322: // 322 - 三轴开始
            startThreeAxis()
        case 323: // 323 - 停止六轴/三轴
            stopSixAxisThreeAxis()
        case 324: // 324 - 加速度计校准
            calibrateAccelerometer()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 321 - 六轴开始
    private func startSixAxis() {
        BCLRingManager.shared.startSixAxis { res in
            switch res {
            case let .success(response):
                if let status = response.deviceStatus, status == 0 { // 正常
                    BDLogger.info("十米游戏-六轴开始采集数据-轴实时转向：\(response.axisRealTurn ?? 0)")
                    BDLogger.info("十米游戏-六轴开始采集数据-轴实时俯仰：\(response.axisRealPitch ?? 0)")
                    BDLogger.info("十米游戏-六轴开始采集数据-实时速度：\(response.realSpeed ?? 0)")
                    BDLogger.info("十米游戏-六轴开始采集数据-瞬间转向：\(response.instantTurn ?? 0)")
                    BDLogger.info("十米游戏-六轴开始采集数据-瞬间俯仰：\(response.instantPitch ?? 0)")
                    BDLogger.info("十米游戏-六轴开始采集数据-Z轴加速度计：\(response.zAxisAccelerometer ?? 0)")
                    BDLogger.info("十米游戏-六轴开始采集数据-Y轴加速度计：\(response.yAxisAccelerometer ?? 0)")
                    BDLogger.info("十米游戏-六轴开始采集数据-X轴加速度计：\(response.xAxisAccelerometer ?? 0)")
                    BDLogger.info("十米游戏-六轴开始采集数据-计数：\(response.count ?? 0)")
                    self.showSuccess("十米游戏-六轴开始采集成功\n轴实时转向：\(response.axisRealTurn ?? 0)\n轴实时俯仰：\(response.axisRealPitch ?? 0)\n实时速度：\(response.realSpeed ?? 0)\n瞬间转向：\(response.instantTurn ?? 0)\n瞬间俯仰：\(response.instantPitch ?? 0)\nZ轴加速度计：\(response.zAxisAccelerometer ?? 0)\nY轴加速度计：\(response.yAxisAccelerometer ?? 0)\nX轴加速度计：\(response.xAxisAccelerometer ?? 0)\n计数：\(response.count ?? 0)")
                } else {
                    BDLogger.info("十米游戏-六轴开始采集-设备繁忙")
                    self.showError("十米游戏-六轴开始采集失败: 设备繁忙")
                }
            case let .failure(error):
                BDLogger.error("十米游戏-六轴开始采集失败: \(error)")
                self.showError("十米游戏-六轴开始采集失败: \(error.localizedDescription)")
            }
        }
    }

    // 322 - 三轴开始
    private func startThreeAxis() {
        BCLRingManager.shared.startThreeAxis { res in
            switch res {
            case let .success(response):
                if let status = response.deviceStatus, status == 0 { // 正常
                    BDLogger.info("十米游戏-三轴开始采集数据-Z轴加速度计：\(response.zAxisAccelerometer ?? 0)")
                    BDLogger.info("十米游戏-三轴开始采集数据-Y轴加速度计：\(response.yAxisAccelerometer ?? 0)")
                    BDLogger.info("十米游戏-三轴开始采集数据-X轴加速度计：\(response.xAxisAccelerometer ?? 0)")
                    self.showSuccess("十米游戏-三轴开始采集成功\nZ轴加速度计：\(response.zAxisAccelerometer ?? 0)\nY轴加速度计：\(response.yAxisAccelerometer ?? 0)\nX轴加速度计：\(response.xAxisAccelerometer ?? 0)")
                } else {
                    BDLogger.info("十米游戏-三轴开始采集-设备繁忙")
                    self.showError("十米游戏-三轴开始采集失败: 设备繁忙")
                }
            case let .failure(error):
                BDLogger.error("十米游戏-三轴开始采集失败: \(error)")
                self.showError("十米游戏-三轴开始采集失败: \(error.localizedDescription)")
            }
        }
    }

    // 323 - 停止六轴/三轴
    private func stopSixAxisThreeAxis() {
        BCLRingManager.shared.stop { res in
            switch res {
            case .success:
                BDLogger.info("十米游戏-六轴三轴协议-停止-成功")
                self.showSuccess("十米游戏-六轴三轴协议-停止-成功")
            case let .failure(error):
                BDLogger.error("十米游戏-六轴三轴协议-停止失败: \(error)")
                self.showError("十米游戏-六轴三轴协议-停止失败: \(error.localizedDescription)")
            }
        }
    }

    // 324 - 加速度计校准
    private func calibrateAccelerometer() {
        BCLRingManager.shared.accelerationCalibration { res in
            switch res {
            case let .success(response):
                if let status = response.calibrationResult, status == 0 {
                    BDLogger.info("十米-六轴三轴协议-加速度计校准-成功")
                    self.showSuccess("十米-六轴三轴协议-加速度计校准-成功")
                } else {
                    BDLogger.info("十米-六轴三轴协议-加速度计校准-失败")
                    self.showError("十米-六轴三轴协议-加速度计校准-失败")
                }
            case let .failure(error):
                BDLogger.error("十米-六轴三轴协议-加速度计校准失败: \(error)")
                self.showError("十米-六轴三轴协议-加速度计校准失败: \(error.localizedDescription)")
            }
        }
    }
}
