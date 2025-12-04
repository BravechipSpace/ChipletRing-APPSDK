//
//  DataSync_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  数据同步功能模块 (116-120)
//

import BCLRingSDK
import UIKit

/// 数据同步功能模块 - 处理历史数据读取和未上传记录同步
class DataSync_Module: BaseFunction_Module {
    // MARK: - Properties

    /// 历史数据缓存
    private var historyData: [BCLRingDBModel] = []

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 116 ... 120)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 116:
            readAllHistoryData()
        case 117:
            readUnUploadData()
        case 118:
            deleteAllHistoryData()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 116 - 读取全部历史数据
    private func readAllHistoryData() {
        historyData = []
        // 创建回调结构体
        let callbacks = BCLDataSyncCallbacks(
            onProgress: { totalNumber, currentIndex, progress, model in
                BDLogger.info("全部历史同步进度：\(currentIndex)/\(totalNumber) (\(progress)%)")
                BDLogger.info("当前数据：\(model.localizedDescription)")
                self.showLoading("同步进度：\(currentIndex)/\(totalNumber) (\(progress)%)")
            },
            onStatusChanged: { status in
                BDLogger.info("全部历史同步状态变化：\(status)")
                switch status {
                case .syncing:
                    BDLogger.info("同步中...")
                case .noData:
                    BDLogger.info("没有历史数据")
                case .completed:
                    BDLogger.info("同步完成")
                case .error:
                    BDLogger.error("同步出错")
                }
            },
            onCompleted: { models in
                BDLogger.info("全部历史同步完成，共获取 \(models.count) 条记录")
                BDLogger.info("\(models)")
                self.hideLoading()
                self.historyData = models
                // 注意：如果需要使用云端睡眠算法，可在此处将当前同步完成的历史数据同步上传到云端进而获取睡眠相关数据
                self.showSuccess("同步完成，共获取 \(models.count) 条记录")
            },
            onError: { error in
                BDLogger.error("全部历史同步出错：\(error.localizedDescription)")
                self.showError("全部历史同步出错：\(error.localizedDescription)")
            }
        )

        // 调用读取方法
        BCLRingManager.shared.readAllHistoryData(callbacks: callbacks) { result in
            switch result {
            case .success:
                BDLogger.info("开始全部历史数据同步")
            case let .failure(error):
                BDLogger.error("启动全部历史同步失败：\(error.localizedDescription)")
                self.showError("启动全部历史同步失败：\(error.localizedDescription)")
            }
        }
    }

    /// 117 - 读取未上传记录
    private func readUnUploadData() {
        historyData = []
        let callbacks = BCLDataSyncCallbacks(
            onProgress: { totalNumber, currentIndex, progress, model in
                BDLogger.info("同步进度：\(currentIndex)/\(totalNumber) (\(progress)%)")
                BDLogger.info("当前数据：\(model.localizedDescription)")
                self.showLoading("同步进度：\(currentIndex)/\(totalNumber) (\(progress)%)")
            },
            onStatusChanged: { status in
                BDLogger.info("同步状态变化：\(status)")
                switch status {
                case .syncing:
                    BDLogger.info("同步中...")
                case .noData:
                    BDLogger.info("无数据")
                case .completed:
                    BDLogger.info("同步完成")
                case .error:
                    BDLogger.error("同步出错")
                }
            },
            onCompleted: { models in
                BDLogger.info("同步完成，共获取 \(models.count) 条记录")
                BDLogger.info("\(models)")
                self.hideLoading()
                self.historyData = models
                // 注意：如果需要使用云端睡眠算法，可在此处将当前同步完成的历史数据同步上传到云端进而获取睡眠相关数据
                self.showSuccess("同步完成，共获取 \(models.count) 条记录")

            },
            onError: { error in
                BDLogger.error("同步出错：\(error.localizedDescription)")
                self.hideLoading()
                self.showError("同步出错：\(error.localizedDescription)")
            }
        )

        // 调用读取方法
        //  - timestamp: 获取指定时间戳之后的数据（默认为0,仅获取未上传的数据）注意：部分固件可能不支持该过滤参数。
        BCLRingManager.shared.readUnUploadData(timestamp: 0, callbacks: callbacks) { result in
            switch result {
            case .success:
                BDLogger.info("开始数据同步")
            case let .failure(error):
                BDLogger.error("启动同步失败：\(error.localizedDescription)")
                self.showError("启动同步失败：\(error.localizedDescription)")
            }
        }
    }

    /// 118 - 删除戒指内全部历史数据
    private func deleteAllHistoryData() {
        BCLRingManager.shared.deleteRingAllHistoryData { res in
            switch res {
            case .success:
                BDLogger.info("清除戒指内历史数据成功")
                self.showSuccess("清除戒指内历史数据成功")
            case let .failure(error):
                BDLogger.error("清除戒指内历史数据失败: \(error)")
                self.showError("清除戒指内历史数据失败: \(error)")
            }
        }
    }
}
