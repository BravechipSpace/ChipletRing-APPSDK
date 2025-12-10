//
//  Time_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  时间同步功能模块 (31-40)
//

import BCLRingSDK
import UIKit

/// 时间同步功能模块 - 处理时间同步和读取功能
class Time_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 31 ... 40)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 31: // 31 - 同步时间
            syncTime()
        case 32: // 32 - 读取时间
            readTime()
        case 33: // 33 - 时区列表
            fetchTimeZoneList()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 31 - 同步时间
    private func syncTime() {
        //  此处BCLRingTimeZone.getCurrentSystemTimeZone() 可获取当前系统时区
        BCLRingManager.shared.syncTime(date: Date(), timeZone: BCLRingTimeZone.getCurrentSystemTimeZone()) { result in
            switch result {
            case .success:
                BDLogger.info("同步时间成功")
                self.showSuccess("同步时间成功")
            case let .failure(error):
                BDLogger.error("同步时间失败: \(error)")
                self.showError("同步时间失败")
            }
        }
    }

    // 32 - 读取时间
    private func readTime() {
        BCLRingManager.shared.readTime { result in
            switch result {
            case let .success(response):
                BDLogger.info("timeStamp: \(response.timestamp)")
                BDLogger.info("timeZone: \(response.ringTimeZone)")
                BDLogger.info("utcDate: \(response.utcDate)")
                BDLogger.info("localDate: \(response.localDate)")
                self.showSuccess("读取时间成功 - 本地时间:\n \(response.localDate)")
            case let .failure(error):
                BDLogger.error("读取时间失败: \(error)")
                self.showError("读取时间失败")
            }
        }
    }

    /// 33 - 时区列表
    private func fetchTimeZoneList() {
        viewController?.navigationController?.pushViewController(TimeZoneList_VC(), animated: true)
    }
}
