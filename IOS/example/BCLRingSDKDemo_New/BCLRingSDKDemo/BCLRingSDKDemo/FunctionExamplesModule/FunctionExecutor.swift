//
//  FunctionExecutor.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  功能执行协调器 - 负责分发功能到各个模块
//

import BCLRingSDK
import Foundation
import QMUIKit
import UIKit

/// 功能执行协调器 - 管理所有功能模块并分发任务
class FunctionExecutor {
    // MARK: - Properties

    /// 单例
    static let shared = FunctionExecutor()

    /// 当前所在的ViewController (用于显示提示信息、弹窗等)
    weak var currentViewController: UIViewController? {
        didSet {
            // 同步更新所有模块的viewController
            modules.forEach { $0.viewController = currentViewController }
        }
    }

    /// 所有功能模块
    private var modules: [FunctionProtocol_Module] = []

    // MARK: - Initialization

    private init() {
        setupModules()
        setupNotifications()
    }

    // MARK: - Setup

    /// 初始化所有功能模块
    private func setupModules() {
        modules = [
            BluetoothDeviceSearch_Module(), // 1-10: 设备搜索
            BasicConnection_Module(), // 11-20: 基础连接
            AppEvent_Module(), // 21-30: App复合指令
            Time_Module(), // 31-40: 时间同步
            VersionInfo_Module(), // 41-50: 版本信息
            BatteryManagement_Module(), // 51-60: 电池管理
            DeviceSystemSettings_Module(), // 61-80: 设备系统设置
            MeasurementTemperature_Module(), // 81-85: 主动测量-温度测量
            MeasurementBloodOxygen_Module(), // 86-90: 主动测量-血氧测量
            MeasurementHeartRate_Module(), // 91-95: 主动测量-心率测量
            MeasurementBloodPressure_Module(), // 96-100: 主动测量-血压测量
            MeasurementBloodGlucose_Module(), // 101-105: 主动测量-血糖测量
            MeasurementECG_Module(), // 106-110: 主动测量-心电测量
            StepCount_Module(), // 111-115: 计步功能
            DataSync_Module(), // 116-120: 数据同步
            HIDFunction_Module(), // 121-130: HID功能
            NetworkAPI_Module(), // 201-300: 网络API
            SixAxisProtocol_Module(), // 301-320: 六轴协议功能
            TenMeterSixAxisThreeAxisProtocol_Module(), // 321-325: 十米游戏-六轴三轴协议功能
            AlarmSettings_Module(), // 326-330: 闹钟配置
            VibrationMotor_Module(), // 331-340: 震动马达控制
            FirmwareUpgrade_Module(), // 341-350: 固件升级
            SportMode_Module(), // 351-360: 运动模式
            AudioTransmission_Module(), // 361-380: 音频数据传输
            FileSystem_Module(), // 381-400: 文件系统
            SleepData_Module(), // 401-420: 睡眠数据
            GoMoreFunction_Module(), // 421-450: GoMore功能
            CustomCommand_Module(), // 1001-1100: 自定义命令
            
        ]
    }

    /// 配置全局通知和回调
    private func setupNotifications() {
        // 配置电量推送
        BCLRingManager.shared.batteryNotifyBlock = { batteryLevel in
            BDLogger.info("电量推送: \(batteryLevel)%")
            QMUITips.show(withText: "电量推送: \(batteryLevel)%")
        }
    }

    // MARK: - 功能执行入口

    /// 根据功能ID执行对应功能
    /// - Parameter id: 功能ID
    func executeFunction(id: Int) {
        // 查找能处理该功能的模块
        guard let module = modules.first(where: { $0.canHandle(functionId: id) }) else {
            BDLogger.warning("未找到能处理功能ID \(id) 的模块")
            showError("功能ID \(id) 尚未实现,请添加对应的模块")
            return
        }
        module.executeFunction(id: id)
    }

    // MARK: - 辅助方法

    /// 显示错误提示
    private func showError(_ message: String) {
        guard let view = currentViewController?.view else { return }
        QMUITips.showError(message, in: view)
    }
}
