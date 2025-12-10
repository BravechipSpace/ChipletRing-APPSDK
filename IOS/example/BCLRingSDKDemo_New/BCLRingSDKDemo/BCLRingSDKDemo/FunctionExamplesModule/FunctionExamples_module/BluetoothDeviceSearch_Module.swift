//
//  BluetoothDiscovery_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/22.
//  基础连接功能模块 (1-10)
//

import BCLRingSDK
import UIKit

///
class BluetoothDeviceSearch_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 1 ... 10)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 1: /// 扫描蓝牙设备
            startScanBluetoothDevices()
        case 2: /// 停止扫描
            stopScanBluetoothDevices()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 1: 扫描蓝牙外设
    private func startScanBluetoothDevices() {
        BDLogger.info("-----------扫描蓝牙外设-功能示例-----------")
        BCLRingManager.shared.startScan { result in
            switch result {
            case let .success(devices):
                for device in devices {
                    BDLogger.info("蓝牙设备信息-设备名称：\(device.peripheralName ?? "")")
                    BDLogger.info("蓝牙设备信息-本地名称（广播协议中 kCBAdvDataLocalName的值）：\(device.localName ?? "")")
                    BDLogger.info("蓝牙设备信息-MAC地址：\(device.macAddress ?? "")")
                    BDLogger.info("蓝牙设备信息-RSSI：\(device.rssi ?? 0)")
                    // 充电状态标志
                    switch device.chargingIndicator {
                    case 0: BDLogger.info("蓝牙设备信息-充电指示：未充电")
                    case 1: BDLogger.info("蓝牙设备信息-充电指示：充电中")
                    case 2: BDLogger.info("蓝牙设备信息-充电指示：充电完成")
                    default: BDLogger.info("蓝牙设备信息-充电指示：未知状态")
                    }
                    // 支持配对模式标志
                    switch device.bindingIndicatorBit {
                    case 0: BDLogger.info("蓝牙设备信息-配对模式：不支持配对模式")
                    case 1: BDLogger.info("蓝牙设备信息-配对模式：支持配对模式")
                    case 2: BDLogger.info("蓝牙设备信息-配对模式：支持配对模式")
                    default: BDLogger.info("蓝牙设备信息-配对模式：未知状态")
                    }

                    // 扫描阶段连接状态
                    if device.isScannedAndConnected {
                        BDLogger.info("蓝牙设备信息-扫描阶段已经被检索到并且是连接状态: 是")
                    } else {
                        BDLogger.info("蓝牙设备信息-扫描阶段已经被检索到并且是连接状态: 否")
                    }

                    // 协议版本
                    switch device.communicationProtocolVersion {
                    case 0:
                        BDLogger.info("蓝牙设备信息-协议版本: 1代版本协议，不支持App复合指令")
                    case 1:
                        BDLogger.info("蓝牙设备信息-协议版本: 2代版本协议，支持App复合指令")
                    case 2:
                        BDLogger.info("蓝牙设备信息-协议版本: 2代版本协议，支持App复合指令，支持分段记步模式")
                    default:
                        BDLogger.info("蓝牙设备信息-协议版本: 未知版本协议")
                    }

                    // 蓝牙设备广播数据
                    if let advertisementData = device.advertisementData {
                        BDLogger.info("蓝牙设备信息-广播数据(原始): \(advertisementData)")
                        BDLogger.info("蓝牙设备信息-广播数据(详细):")
                        for (key, value) in advertisementData {
                            if let data = value as? Data {
                                let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
                                BDLogger.info("  \(key): \(hexString) (Hex)")
                            } else {
                                BDLogger.info("  \(key): \(value)")
                            }
                        }
                    }

                    // 制造商数据
                    let manufacturerData = device.advDataManufacturerData
                    if !manufacturerData.isEmpty {
                        BDLogger.info("蓝牙设备信息-制造商数据(原始): \(manufacturerData)")
                        let hexString = manufacturerData.map { String(format: "%02X", $0) }.joined(separator: " ")
                        BDLogger.info("蓝牙设备信息-制造商数据(十六进制): \(hexString)")
                        BDLogger.info("蓝牙设备信息-制造商数据(长度): \(manufacturerData.count) bytes")
                    }
                    // Phy固件升级中断状态下的Boot模式（此处适配Phy蓝牙设备使用）
                    BDLogger.info("蓝牙设备信息-是否为Phy固件升级中断状态下的Boot模式： \(device.isPhyBootMode ? "是" : "否")")

                    /**
                     需要注意此处
                     */
                }
            case let .failure(error):
                self.showError("扫描蓝牙外设失败: \(error.localizedDescription)")
            }
        }
    }

    /// 2: 停止扫描蓝牙外设
    private func stopScanBluetoothDevices() {
        BDLogger.info("-----------停止扫描蓝牙外设-功能示例-----------")
        BCLRingManager.shared.stopScan()
    }
}
