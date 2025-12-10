//
//  StepCount_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  记步功能模块 (111-115)
//

import BCLRingSDK
import RxSwift
import UIKit

/// 记步功能模块 - 获取实时记步、清除记步等功能
class StepCount_Module: BaseFunction_Module {
    // MARK: - Properties

    let disposeBag = DisposeBag()

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 111 ... 115)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 111: // 111 - 获取实时记步
            getRealTimeStepCount()
        case 112: // 112 - 清除当前记步数据
            clearRealTimeStepCount()
        case 113: // 113 - 订阅步数变化通知
            subscribeStepCountUpdates()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 111 - 获取实时记步
    private func getRealTimeStepCount() {
        showLoading("正在获取实时记步...")
        BCLRingManager.shared.readStepCount { result in
            self.hideLoading()
            switch result {
            case let .success(response):
                BDLogger.info("实时步数: \(response.stepCount)")
                self.showSuccess("实时步数: \(response.stepCount)")
            case let .failure(error):
                BDLogger.error("读取实时步数失败: \(error)")
                self.showError("读取实时步数失败: \(error)")
            }
        }
    }

    // 112 - 清除当前记步数据
    private func clearRealTimeStepCount() {
        showLoading("正在清除当前记步数据...")
        BCLRingManager.shared.clearStepCount { result in
            self.hideLoading()
            switch result {
            case .success:
                BDLogger.info("清除步数成功")
                self.showSuccess("清除步数成功")
            case let .failure(error):
                BDLogger.error("清除步数失败: \(error)")
                self.showError("清除步数失败: \(error)")
            }
        }
    }

    // 113 - 订阅步数变化通知
    private func subscribeStepCountUpdates() {
        // 方式一：使用回调闭包
        BCLRingManager.shared.stepNotifyBlock = { stepCount in
            BDLogger.info("收到步数推送：\(stepCount)")
            self.showSuccess("收到步数推送：\(stepCount)")
        }

//        // 方式二：使用 RxSwift 订阅
//        BCLRingManager.shared.stepNotifyObservable
//            .subscribe(onNext: { stepCount in
//                BDLogger.info("收到步数推送：\(stepCount)")
//                self.showSuccess("收到步数推送：\(stepCount)")
//            })
//            .disposed(by: disposeBag)
    }
}
