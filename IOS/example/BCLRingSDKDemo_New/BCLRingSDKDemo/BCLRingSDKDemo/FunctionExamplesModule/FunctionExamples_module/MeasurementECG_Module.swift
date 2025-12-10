//
//  MeasurementECG_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  主动测量——心电-功能模块 (106-110)
//

import BCLRingSDK
import UIKit

/// 主动测量——心电-功能模块(106-110)
class MeasurementECG_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 106 ... 110)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 106: // 主动测量-开始ECG采集人体心电信号
            startECGMeasurement()
        case 107: // 主动测量-ECG采集模拟信号
            simulateECGMeasurement()
        case 108: // 主动测量-停止心电测量
            stopECGMeasurement()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 106 - 主动测量-开始ECG采集人体心电信号
    private func startECGMeasurement() {
        BCLRingManager.shared.startTakeECG { res in
            switch res {
            case let .success(response):
                BDLogger.info("开始ECG采集人体心电-HeadTypeSize: \(response.headTypeSize)")
                BDLogger.info("开始ECG采集人体心电-HeadType: \(response.headType)")
                BDLogger.info("开始ECG采集人体心电-DeviceType: \(response.deviceType)")
                BDLogger.info("开始ECG采集人体心电-seq: \(response.seq)")
                BDLogger.info("开始ECG采集人体心电-hr: \(response.hr)")
                BDLogger.info("开始ECG采集人体心电-dataLength: \(response.dataLength)")
                BDLogger.info("开始ECG采集人体心电-ecgValues: \(response.ecgValues)")
            case let .failure(error):
                BDLogger.error("开始ECG采集人体心电信号失败: \(error)")
                self.showError("开始ECG采集人体心电信号失败: \(error.localizedDescription)")
            }
        }
    }

    /// 107 - 主动测量-ECG采集模拟信号
    private func simulateECGMeasurement() {
        BCLRingManager.shared.startTakeECGSimulator { res in
            switch res {
            case let .success(response):
                BDLogger.info("开始ECG采集模拟信号-HeadTypeSize: \(response.headTypeSize)")
                BDLogger.info("开始ECG采集模拟信号-HeadType: \(response.headType)")
                BDLogger.info("开始ECG采集模拟信号-DeviceType: \(response.deviceType)")
                BDLogger.info("开始ECG采集模拟信号-seq: \(response.seq)")
                BDLogger.info("开始ECG采集模拟信号-hr: \(response.hr)")
                BDLogger.info("开始ECG采集模拟信号-dataLength: \(response.dataLength)")
                BDLogger.info("开始ECG采集模拟信号-ecgValues: \(response.ecgValues)")
            case let .failure(error):
                BDLogger.error("开始ECG采集模拟信号失败: \(error)")
                self.showError("开始ECG采集模拟信号失败: \(error.localizedDescription)")
            }
        }
    }

    /// 108 - 主动测量-停止ECG采集
    private func stopECGMeasurement() {
        BCLRingManager.shared.stopECG { res in
            switch res {
            case .success:
                BDLogger.info("停止ECG采集成功")
                self.showSuccess("停止ECG采集成功")
            case let .failure(error):
                BDLogger.error("停止ECG采集失败: \(error)")
                self.showError("停止ECG采集失败: \(error.localizedDescription)")
            }
        }
    }
}
