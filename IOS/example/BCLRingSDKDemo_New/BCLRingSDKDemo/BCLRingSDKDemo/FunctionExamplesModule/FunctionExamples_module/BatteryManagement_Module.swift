//
//  BatteryManagement_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  电量管理模块 (51-60)
//

import BCLRingSDK
import RxSwift
import UIKit

/// 电量管理模块
class BatteryManagement_Module: BaseFunction_Module {
    // MARK: properties

    private let disposeBag = DisposeBag()
    /// 是否正在监听电量计详细信息推送
    private var isBatteryGaugeInfoPushMonitoring = false

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 51 ... 60)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 51:
            readBatteryInfo()
        case 52:
            readChargingStatus()
        case 53:
            monitorChargingStatus()
        case 54:
            readBatteryGaugeInfo()
        case 55:
            toggleBatteryGaugeInfoPushMonitoring()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 51 - 电量管理 - 读取电量信息
    private func readBatteryInfo() {
        //  主动查询当前电量信息（注意：电量有效值范围0~100之间，101表示：充电中，102表示：充电完成）
        BCLRingManager.shared.readBattery { res in
            switch res {
            case let .success(response):
                if response.batteryLevel == 101 {
                    BDLogger.info("当前正在充电中")
                    self.showSuccess("当前正在充电中")
                } else if response.batteryLevel == 102 {
                    BDLogger.info("充电完成")
                    self.showSuccess("充电完成")
                } else if response.batteryLevel >= 0 && response.batteryLevel <= 100 {
                    BDLogger.info("当前电量为 \(response.batteryLevel)%")
                    self.showSuccess("当前电量为 \(response.batteryLevel)%")
                } else {
                    BDLogger.info("未知电量状态")
                    self.showError("未知电量状态")
                }
            case let .failure(error):
                BDLogger.error("读取电量失败: \(error)")
                self.showError("读取电量失败: \(error)")
            }
        }
    }

    /// 52 - 电量管理 - 读取充电状态
    private func readChargingStatus() {
        BCLRingManager.shared.readChargingState { res in
            switch res {
            case let .success(response):
                switch response.chargingState {
                case .notCharging:
                    BDLogger.info("当前未充电")
                    self.showSuccess("当前未充电")
                case .charging:
                    BDLogger.info("当前正在充电中")
                    self.showSuccess("当前正在充电中")
                case .charged:
                    BDLogger.info("充电完成")
                    self.showSuccess("充电完成")
                case .unknown:
                    BDLogger.info("未知状态")
                    self.showError("未知状态")
                }
            case let .failure(error):
                BDLogger.error("读取充电状态失败: \(error)")
                self.showError("读取充电状态失败: \(error)")
            }
        }
    }

    /// 53 - 电量管理 - 监听充电状态变化(部分固件可在充电状态发生变化时主动上报电量信息)
    private func monitorChargingStatus() {
        // 注意：两种方式二选一即可

        //  订阅电量变化（注意：电量有效值范围0~100之间，101表示：充电中，102表示：充电完成）
        BCLRingManager.shared.batteryNotifyObservable.subscribe(onNext: { batteryLevel in
            BDLogger.info("电量推送订阅: \(batteryLevel)")
            if batteryLevel == 101 {
                BDLogger.info("当前正在充电中")
                self.showSuccess("当前正在充电中")
            } else if batteryLevel == 102 {
                BDLogger.info("充电已完成")
                self.showSuccess("充电已完成")
            } else if batteryLevel >= 0 && batteryLevel <= 100 {
                BDLogger.info("当前电量为 \(batteryLevel)%")
                self.showSuccess("当前电量为 \(batteryLevel)%")
            } else {
                BDLogger.info("未知电量状态")
                self.showError("未知电量状态")
            }
        }).disposed(by: disposeBag)

        //  Block方式接收电量变化
        BCLRingManager.shared.batteryNotifyBlock = { batteryLevel in
            BDLogger.info("电量推送Block: \(batteryLevel)")
            if batteryLevel == 101 {
                BDLogger.info("当前正在充电中")
                self.showSuccess("当前正在充电中")
            } else if batteryLevel == 102 {
                BDLogger.info("充电已完成")
                self.showSuccess("充电已完成")
            } else if batteryLevel >= 0 && batteryLevel <= 100 {
                BDLogger.info("当前电量为 \(batteryLevel)%")
                self.showSuccess("当前电量为 \(batteryLevel)%")
            } else {
                BDLogger.info("未知电量状态")
                self.showError("未知电量状态")
            }
        }
    }

    /// 54 - 电量管理 - 读取电量计详细信息
    private func readBatteryGaugeInfo() {
        BCLRingManager.shared.readBatteryGaugeInfo { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                let message = self.batteryGaugeInfoDescription(response)
                BDLogger.info("读取电量计详细信息成功: \(message)")
                self.showSuccess("主动读取响应\n\(message)")
            case let .failure(error):
                BDLogger.error("读取电量计详细信息失败: \(error)")
                self.showError("读取电量计详细信息失败: \(error)")
            }
        }
    }

    /// 55 - 电量管理 - 开启或取消监听电量计详细信息推送
    private func toggleBatteryGaugeInfoPushMonitoring() {
        if isBatteryGaugeInfoPushMonitoring {
            BCLRingManager.shared.batteryGaugeInfoPushBlock = nil
            isBatteryGaugeInfoPushMonitoring = false
            BDLogger.info("已取消监听电量计详细信息推送")
            showSuccess("已取消监听电量计详细信息推送")
            return
        }

        BCLRingManager.shared.batteryGaugeInfoPushBlock = { [weak self] response in
            guard let self = self else { return }
            let message = self.batteryGaugeInfoDescription(response)
            BDLogger.info("收到固件主动推送的电量计详细信息: \(message)")
            self.showSuccess("固件主动推送\n\(message)")
        }
        isBatteryGaugeInfoPushMonitoring = true
        BDLogger.info("已开启监听电量计详细信息推送")
        showSuccess("已开启监听电量计详细信息推送")
    }

    /// 格式化电量计详细信息
    private func batteryGaugeInfoDescription(_ response: BCLBatteryGaugeInfoResponse) -> String {
        return """
        电量：\(response.batteryLevel)
        电压：\(response.voltage)
        电流：\(response.current)
        温度：\(response.temperature)
        电池循环次数：\(response.cycleCount)
        电池健康状况：\(response.batteryHealth)
        """
    }
}
