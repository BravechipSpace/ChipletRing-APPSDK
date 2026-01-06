//
//  FunctionDemoModel.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//

import Foundation

// MARK: - 功能分类枚举

enum FunctionCategory: String, CaseIterable {
    case bluetoothDeviceSearch = "发现蓝牙设备"
    case bluetoothConnection = "连接蓝牙设备"
    case appEvent = "APP事件(复合指令)"
    case timeSync = "时间同步"
    case versionInfo = "版本号获取"
    case batteryManagement = "电池管理"
    case deviceSystemSettings = "设备系统设置"
    case measurementTemperature = "主动测量-温度"
    case measurementBloodOxygen = "主动测量-血氧"
    case measurementHeartRate = "主动测量-心率"
    case measurementBloodPressure = "主动测量-血压"
    case measurementBloodGlucose = "主动测量-血糖"
    case measurementECG = "主动测量-心电图"
    case stepCount = "计步"
    case sportMode = "运动模式"
    case ringData = "戒指内数据"
    case hidControl = "HID功能"
    case sixAxisProtocol = "六轴协议"
    case tenMeterSixAxisThreeAxisProtocol = "十米：6轴、3轴协议"
    case alarmSettings = "闹钟设置"
    case vibrationMotor = "振动马达"
    case firmwareUpgrade = "固件升级功能"
    case audioTransmission = "音频数据传输"
    case fileSystem = "文件系统"
    case sleepData = "睡眠数据"
    case goMoreFunction = "GoMore功能"
    case ppgWaveform = "PPG波形透传输"
    case keyEvent = "按键事件"
    case displayEvent = "显示事件"
    case customCommand = "自定义指令"
    case sdkNetwork = "SDK-网络相关"
    case sdkDatabase = "SDK-数据库相关"
    case sdkLog = "SDK-Log日志相关"

    /// 获取所有分类的排序
    static var displayOrder: [FunctionCategory] {
        return [
            .bluetoothDeviceSearch,
            .bluetoothConnection,
            .appEvent,
            .timeSync,
            .versionInfo,
            .batteryManagement,
            .deviceSystemSettings,
            .measurementTemperature,
            .measurementBloodOxygen,
            .measurementHeartRate,
            .measurementBloodPressure,
            .measurementBloodGlucose,
            .measurementECG,
            .stepCount,
            .sportMode,
            .audioTransmission,
            .ringData,
            .ppgWaveform,
            .sixAxisProtocol,
            .tenMeterSixAxisThreeAxisProtocol,
            .keyEvent,
            .displayEvent,
            .vibrationMotor,
            .hidControl,
            .alarmSettings,
            .sdkNetwork,
            .firmwareUpgrade,
            .fileSystem,
            .sleepData,
            .goMoreFunction,
            .customCommand,
            .sdkDatabase,
            .sdkLog,
        ]
    }
}

// MARK: - 功能数据模型

struct FunctionDemoModel {
    /// 功能ID (对应Main_VC中的tag值)
    let id: Int

    /// 功能名称
    let title: String

    /// 功能分类
    let category: FunctionCategory

    /// 功能描述(可选)
    let description: String?

    /// 是否需要连接设备
    let requiresConnection: Bool

    /// 执行闭包
    let action: (() -> Void)?

    init(
        id: Int,
        title: String,
        category: FunctionCategory,
        description: String? = nil,
        requiresConnection: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.description = description
        self.requiresConnection = requiresConnection
        self.action = action
    }
}

// MARK: - 功能分组模型

struct FunctionSection {
    let category: FunctionCategory
    let items: [FunctionDemoModel]
    var title: String {
        return category.rawValue
    }
}
