//
//  AlarmSettings_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  闹钟功能模块 (326-330)
//

import BCLRingSDK
import UIKit

/// 闹钟功能模块 - 设置闹钟、读取闹钟配置、智能闹钟配置、智能闹钟配置读取等功能
class AlarmSettings_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 326 ... 330)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 326: // 326 - 设置闹钟
            setAlarm()
        case 327: // 327 - 读取闹钟配置
            readAlarmConfig()
        case 328: // 328 - 智能闹钟配置
            setSmartAlarm()
        case 329: // 329 - 智能闹钟配置读取
            readSmartAlarmConfig()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 326 - 设置闹钟
    private func setAlarm() {
        let alarmClock1 = BCLAlarmClockData(timestamp: "2025-06-24 12:33:00".toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date.timeIntervalSince1970 ?? 0,
                                            repeatType: .once,
                                            vibrationEffect: .strong,
                                            isEnabled: true,
                                            isMonday: true,
                                            isTuesday: true,
                                            isWednesday: true,
                                            isThursday: true,
                                            isFriday: true,
                                            isSaturday: true,
                                            isSunday: true)
        let alarmClock2 = BCLAlarmClockData(timestamp: "2025-06-24 12:34:00".toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date.timeIntervalSince1970 ?? 0,
                                            repeatType: .once,
                                            vibrationEffect: .strong,
                                            isEnabled: true,
                                            isMonday: true,
                                            isTuesday: true,
                                            isWednesday: true,
                                            isThursday: true,
                                            isFriday: true,
                                            isSaturday: true,
                                            isSunday: true)
        let alarmClock3 = BCLAlarmClockData(timestamp: "2025-06-24 12:35:00".toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date.timeIntervalSince1970 ?? 0,
                                            repeatType: .once,
                                            vibrationEffect: .strong,
                                            isEnabled: true,
                                            isMonday: true,
                                            isTuesday: true,
                                            isWednesday: true,
                                            isThursday: true,
                                            isFriday: true,
                                            isSaturday: true,
                                            isSunday: true)
        let alarmClock4 = BCLAlarmClockData(timestamp: "2025-06-24 12:36:00".toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date.timeIntervalSince1970 ?? 0,
                                            repeatType: .once,
                                            vibrationEffect: .strong,
                                            isEnabled: true,
                                            isMonday: true,
                                            isTuesday: true,
                                            isWednesday: true,
                                            isThursday: true,
                                            isFriday: true,
                                            isSaturday: true,
                                            isSunday: true)

        let alarmClock5 = BCLAlarmClockData(timestamp: "2025-06-24 12:37:00".toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date.timeIntervalSince1970 ?? 0,
                                            repeatType: .once,
                                            vibrationEffect: .strong,
                                            isEnabled: true,
                                            isMonday: true,
                                            isTuesday: true,
                                            isWednesday: true,
                                            isThursday: true,
                                            isFriday: true,
                                            isSaturday: true,
                                            isSunday: true)
        BCLRingManager.shared.setAlarmClock(items: [alarmClock1, alarmClock2, alarmClock3, alarmClock4, alarmClock5]) { res in
            switch res {
            case let .success(response):
                if response.status == 1 {
                    BDLogger.info("闹钟设置--成功")
                    self.showSuccess("闹钟设置--成功")
                } else {
                    BDLogger.error("闹钟设置--失败")
                    self.showError("闹钟设置--失败")
                }
            case let .failure(err):
                BDLogger.error("闹钟设置失败：\(err)")
                self.showError("闹钟设置失败：\(err)")
            }
        }
    }

    // 327 - 读取闹钟配置
    private func readAlarmConfig() {
        BCLRingManager.shared.readAlarmClock { res in
            switch res {
            case let .success(response):
                BDLogger.info("读取闹钟配置成功，共有\(response.items.count)个闹钟")
                for alarmClock in response.items {
                    BDLogger.info("闹钟时间: \(alarmClock.timestamp)")
                    BDLogger.info("重复类型: \(alarmClock.repeatType.rawValue)")
                    BDLogger.info("振动效果: \(alarmClock.vibrationEffect.rawValue)")
                    BDLogger.info("是否启用: \(alarmClock.isEnabled)")
                    BDLogger.info("星期一: \(alarmClock.isMonday)")
                    BDLogger.info("星期二: \(alarmClock.isTuesday)")
                    BDLogger.info("星期三: \(alarmClock.isWednesday)")
                    BDLogger.info("星期四: \(alarmClock.isThursday)")
                    BDLogger.info("星期五: \(alarmClock.isFriday)")
                    BDLogger.info("星期六: \(alarmClock.isSaturday)")
                    BDLogger.info("星期日: \(alarmClock.isSunday)")
                }
                self.showSuccess("读取闹钟配置成功，共有\(response.items.count)个闹钟")
            case let .failure(error):
                BDLogger.error("读取闹钟配置失败: \(error)")
                self.showError("读取闹钟配置失败: \(error)")
            }
        }
    }

    // 328 - 设置智能闹钟
    private func setSmartAlarm() {
        // 注意：此处智能节假日配置仅为示例，具体可以配置内容可通过云端接口进行获取
        let holidayData = BCLHolidayData(year: 2025, nonWeekendHolidayCount: 18, nonWeekendHolidayDays: [1, 28, 29, 30, 31, 34, 35, 94, 121, 122, 125, 153, 274, 275, 276, 279, 280, 281], workDaysCount: 5, workDays: [26, 39, 117, 271, 284])
        BCLRingManager.shared.setHoliday(holidayData: holidayData) { res in
            switch res {
            case let .success(response):
                if response.status == 1 {
                    BDLogger.info("智能节假日配置设置成功")
                    self.showSuccess("智能节假日配置设置成功")
                } else {
                    BDLogger.error("智能节假日配置设置失败")
                    self.showError("智能节假日配置设置失败")
                }
            case let .failure(err):
                BDLogger.error("智能节假日配置设置失败: \(err)")
                self.showError("智能节假日配置设置失败: \(err)")
            }
        }
    }

    // 329 - 读取智能闹钟配置
    private func readSmartAlarmConfig() {
        BCLRingManager.shared.readHoliday(year: 2025) { res in
            switch res {
            case let .success(response):
                guard let holidayData = response.holidayData else {
                    BDLogger.info("智能节假日配置读取失败，数据为空")
                    return
                }
                BDLogger.info("智能节假日配置读取成功")
                BDLogger.info("智能节假日数据-年份: \(holidayData.year)")
                BDLogger.info("智能节假日数据-全年非周末的假日天数: \(holidayData.nonWeekendHolidayCount)")
                BDLogger.info("智能节假日数据-非周六日的假日下nonWeekendHolidayCount标的列表（一年中的第几天）: \(holidayData.nonWeekendHolidayDays)")
                BDLogger.info("智能节假日数据-周末中的工作天数: \(holidayData.workDaysCount)")
                BDLogger.info("智能节假日数据-周末中的调休日期（是一年中的第几天): \(holidayData.workDays)")
                self.showSuccess("智能节假日配置读取成功")
            case let .failure(error):
                BDLogger.error("智能节假日配置读取失败: \(error)")
                self.showError("智能节假日配置读取失败: \(error)")
            }
        }
    }
}
