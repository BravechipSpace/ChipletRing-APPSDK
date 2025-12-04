//
//  BasicConnection_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  基础连接功能模块 (11-20)
//

import BCLRingSDK
import UIKit

/// 基础连接功能模块 - 处理设备连接、断开、自动重连等功能
class BasicConnection_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 11 ... 20)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 11:
            openDeviceList()
        case 12:
            disconnect()
        case 13:
            toggleAutoReconnect()
        case 14:
            startReadRSSI()
        case 15:
            stopReadRSSI()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 11 - 打开设备列表
    private func openDeviceList() {
        guard let nav = viewController?.navigationController else {
            BDLogger.error("无法获取导航控制器")
            return
        }
        let deviceTableVC = DeviceTableVC()
        nav.pushViewController(deviceTableVC, animated: true)
    }

    /// 12 - 断开连接
    private func disconnect() {
        BCLRingManager.shared.disconnect()
        BDLogger.info("已发送断开连接指令")
    }

    /// 13 - 切换自动重连
    private func toggleAutoReconnect() {
        let isEnabled = BCLRingManager.shared.isAutoReconnectEnabled
        BCLRingManager.shared.isAutoReconnectEnabled = !isEnabled
        BDLogger.info("自动重连已\(isEnabled ? "关闭" : "开启")")
        showSuccess("自动重连已\(isEnabled ? "关闭" : "开启")")
    }

    /// 14 - 开启实时读取RSSI
    private func startReadRSSI() {
        //  每隔1s开始读取RSSI
        BCLRingManager.shared.startReadRSSI(interval: 1, readRSSIBlock: { result in
            switch result {
            case let .success(rssi):
                BDLogger.info("实时读取RSSI: \(rssi)")
            case let .failure(error):
                BDLogger.error("读取RSSI失败: \(error)")
            }
        })
    }

    /// 15 - 关闭实时读取RSSI
    private func stopReadRSSI() {
        BCLRingManager.shared.stopReadRSSI()
    }
}
