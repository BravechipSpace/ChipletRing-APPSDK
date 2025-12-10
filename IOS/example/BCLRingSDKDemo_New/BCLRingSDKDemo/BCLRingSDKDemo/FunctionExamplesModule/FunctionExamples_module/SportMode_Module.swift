//
//  SportMode_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/25.
//  运动模式功能模块（351-360）
//

import BCLRingSDK
import UIKit

/// 运动模式功能模块（351-360） - 运动模式开始、停止、数据漏点续传等功能
class SportMode_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 351 ... 360)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 351: // 351 - 运动模式-开始
            startSportMode()
        case 352: // 352 - 运动模式-停止
            stopSportMode()
        case 353: // 353 - 运动模式-数据漏点续传
            resumeSportModeData()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 351 - 运动模式-开始
    private func startSportMode() {
        /// 运动数据监听
        BCLRingManager.shared.sportDataBlock = { sportDataResponse in
            BDLogger.info("运动数据-时间戳: \(sportDataResponse.timestamp ?? 0)")
            BDLogger.info("运动数据-步数: \(sportDataResponse.totalSteps ?? 0)")
            BDLogger.info("运动数据-心率: \(sportDataResponse.heartRate ?? 0)次/分")
            BDLogger.info("运动数据-能量消耗: \(sportDataResponse.energyConsumption ?? 0)")
            self.showSuccess("运动数据-\n时间戳: \(sportDataResponse.timestamp ?? 0)\n运动数据-步数: \(sportDataResponse.totalSteps ?? 0)\n运动数据-心率: \(sportDataResponse.heartRate ?? 0)次/分\n运动数据-能量消耗: \(sportDataResponse.energyConsumption ?? 0)")
        }

        BCLRingManager.shared.startSportMode(sportType: 1, recordDuration: 600, sliceDuration: 60) { res in
            switch res {
            case let .success(response):
                if response.status == 1 {
                    BDLogger.info("运动模式启动-成功")
                    self.showSuccess("运动模式启动-成功")
                } else {
                    BDLogger.info("运动模式启动-失败")
                    self.showError("运动模式启动-失败")
                }
            case let .failure(error):
                BDLogger.error("运动模式启动-失败: \(error)")
                self.showError("运动模式启动-失败: \(error.localizedDescription)")
            }
        }
    }

    // 352 - 运动模式-停止
    private func stopSportMode() {
        BCLRingManager.shared.stopSportMode { res in
            switch res {
            case let .success(response):
                if response.status == 1 {
                    BDLogger.info("运动模式停止-成功")
                    self.showSuccess("运动模式停止-成功")
                } else {
                    BDLogger.info("运动模式停止-失败")
                    self.showError("运动模式停止-失败")
                }
            case let .failure(error):
                BDLogger.error("运动模式停止-失败: \(error)")
                self.showError("运动模式停止-失败: \(error.localizedDescription)")
            }
        }
    }

    // 353 - 运动模式-数据漏点续传
    private func resumeSportModeData() {
        /// 漏传运动数据监听
        BCLRingManager.shared.sportDataMissingPointsBlock = { missingPointsDtatRes in
            BDLogger.info("漏传-运动数据-时间戳: \(missingPointsDtatRes.timestamp ?? 0)")
            BDLogger.info("漏传-运动数据-步数: \(missingPointsDtatRes.totalSteps ?? 0)")
            BDLogger.info("漏传-运动数据-心率: \(missingPointsDtatRes.heartRate ?? 0)次/分")
            BDLogger.info("漏传-运动数据-能量消耗: \(missingPointsDtatRes.energyConsumption ?? 0)")
            self.showSuccess("漏传-运动数据-\n时间戳: \(missingPointsDtatRes.timestamp ?? 0)\n运动数据-步数: \(missingPointsDtatRes.totalSteps ?? 0)\n运动数据-心率: \(missingPointsDtatRes.heartRate ?? 0)次/分\n运动数据-能量消耗: \(missingPointsDtatRes.energyConsumption ?? 0)")
        }
        /// 请求获取漏传运动数据
        BCLRingManager.shared.requestMissingPointsSportMode()
    }
}
