//
//  SleepData_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/12/8.
//  睡眠数据功能模块 (401-420)
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 睡眠数据功能模块 (401-420) -
class SleepData_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 401 ... 420)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 401: // 401 - 查询睡眠数据（单日）
            presentSleepQueryDialog()
        case 402: // 402 - 查询睡眠数据（时间范围）
            presentSleepRangeQueryDialog()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 查询弹窗（选择时间+时区）
    private func presentSleepQueryDialog() {
        let contentView = SleepDataConfig_Dialog(x: 0, y: 0, width: 320, height: 340)
        contentView.confirmButtonCallback = { date, timeZone in
            // date 已经是选择的时区对应的绝对时间，SDK 查询时区固定使用东8区
            BDLogger.info("睡眠查询参数 -> 时间: \(date), 选择的时区: \(timeZone)")
            self.querySleepData(date: date)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 401 - 查询睡眠数据（单日）
    private func querySleepData(date: Date) {
        // SDK 要求查询时区固定东8区
        BCLRingManager.shared.getSleepData(date: date, timeZone: .East8) { result in
            switch result {
            case let .success(sleepData):
                BDLogger.info("睡眠数据: \(sleepData)")
            case let .failure(error):
                self.handleSleepDataError(error)
            }
        }
    }

    // MARK: - 402 时间范围查询

    /// 时间范围查询弹窗
    private func presentSleepRangeQueryDialog() {
        let contentView = SleepDataRangeConfig_Dialog(x: 0, y: 0, width: 320, height: 340)
        contentView.confirmButtonCallback = { dates in
            BDLogger.info("睡眠时间范围查询参数 -> 日期数组: \(dates)")
            self.querySleepDataByTimeRange(dates: dates)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 402 - 查询睡眠数据（时间范围）
    private func querySleepDataByTimeRange(dates: [String]) {
        BDLogger.info("开始查询时间范围睡眠数据，日期数量: \(dates.count)")
        BCLRingManager.shared.getSleepDataByTimeRange(datas: dates) { result in
            switch result {
            case let .success(sleepDataList):
                BDLogger.info("时间范围睡眠数据查询成功，返回 \(sleepDataList.count) 条记录")
                for (index, sleepData) in sleepDataList.enumerated() {
                    BDLogger.info("[\(index + 1)] 睡眠数据: \(sleepData)")
                }
            case let .failure(error):
                self.handleSleepDataError(error)
            }
        }
    }

    // MARK: - Error Handling

    private func handleSleepDataError(_ error: BCLError) {
        switch error {
        case let .network(.invalidParameters(message)):
            BDLogger.error("❌ 参数无效，请检查API Key和用户ID: \(message)")
        case let .network(.httpError(code)):
            BDLogger.error("❌ HTTP错误：\(code)")
        case let .network(.serverError(code, message)):
            BDLogger.error("❌ 服务器错误[\(code)]: \(message)")
        case .network(.invalidResponse):
            BDLogger.error("❌ 响应数据无效")
        case let .network(.decodingError(error)):
            BDLogger.error("❌ 数据解析失败: \(error)")
        case let .network(.networkError(message)):
            BDLogger.error("❌ 网络错误: \(message)")
        case let .network(.tokenError(message)):
            BDLogger.error("❌ Token异常: \(message)")
        default:
            BDLogger.error("❌ 其他错误: \(error)")
        }
    }
}
