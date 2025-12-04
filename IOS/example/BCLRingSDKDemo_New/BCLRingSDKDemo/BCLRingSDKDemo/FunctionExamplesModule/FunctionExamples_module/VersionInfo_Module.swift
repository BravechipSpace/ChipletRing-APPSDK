//
//  VersionInfo_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/23.
//  蓝牙设备版本信息相关模块 (41-42)
//

import BCLRingSDK
import UIKit

/// 版本信息模块
class VersionInfo_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 41 ... 50)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 41:
            readHardwareVersion()
        case 42:
            readFirmwareVersion()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 41 - 读取蓝牙设备硬件版本信息
    private func readHardwareVersion() {
        BCLRingManager.shared.readHardware { res in
            switch res {
            case let .success(response):
                BDLogger.info("硬件版本: \(response.hardwareVersion)")
                self.showSuccess("硬件版本: \(response.hardwareVersion)")
            case let .failure(error):
                BDLogger.error("读取硬件版本失败: \(error)")
                self.showError("读取硬件版本失败: \(error)")
            }
        }
    }

    /// 42 - 读取蓝牙设备固件版本信息
    private func readFirmwareVersion() {
        BCLRingManager.shared.readFirmware { res in
            switch res {
            case let .success(response):
                BDLogger.info("固件版本: \(response.firmwareVersion)")
                self.showSuccess("固件版本: \(response.firmwareVersion)")
            case let .failure(error):
                BDLogger.error("读取固件版本失败: \(error)")
                self.showError("读取固件版本失败: \(error)")
            }
        }
    }
}
