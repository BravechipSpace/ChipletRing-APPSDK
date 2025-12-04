//
//  VibrationMotor_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/25.
//  马达震动功能模块 (331-340)
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 马达震动功能模块 (331-335) - 马达震动-即时震动反馈、延迟震动反馈
class VibrationMotor_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 331 ... 340)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 331:
            vibrateImmediate()
        case 332:
            vibrateDelayedConfigDialog()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 331 - 马达即时震动反馈
    private func vibrateImmediate() {
        BCLRingManager.shared.linearMotorImmediateVibration(type: .continuousVibration) { res in
            switch res {
            case let .success(response):
                if response.setStatus == 1 {
                    BDLogger.info("马达立刻震动指令设置-成功")
                    self.showSuccess("马达立刻震动指令设置-成功")
                } else {
                    BDLogger.info("马达立刻震动指令设置-失败")
                    self.showError("马达立刻震动指令设置-失败")
                }
            case let .failure(error):
                BDLogger.error("马达立刻震动指令设置失败: \(error)")
                self.showError("马达立刻震动指令设置失败: \(error)")
            }
        }
    }

    // 马达延迟震动反馈参数配置弹窗
    private func vibrateDelayedConfigDialog() {
        let contentView = VibrationMotorConfig_Dialog(x: 0, y: 0, width: 300, height: 280)
        contentView.confirmButtonCallback = { delaySeconds, vibrationType in
            BDLogger.info("开始延迟震动 - 延迟时间:\(delaySeconds)秒, 震动类型:\(vibrationType)")
            self.vibrateDelayed(seconds: delaySeconds, type: vibrationType)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 332 - 马达延迟震动反馈
    private func vibrateDelayed(seconds: Int, type: BCLVibrationMotorType) {
        BCLRingManager.shared.linearMotorTimerVibration(seconds: seconds, type: type) { res in
            switch res {
            case let .success(response):
                if response.setStatus == 1 {
                    BDLogger.info("震动马达-倒计时震动指令设置-成功")
                    switch type {
                    case .strongVibration:
                        self.showSuccess("已设置延迟 \(seconds) 秒后,模式-强力震动")
                    case .continuousVibration:
                        self.showSuccess("已设置延迟 \(seconds) 秒后,模式-持续震动")
                    case .gradientVibration:
                        self.showSuccess("已设置延迟 \(seconds) 秒后,模式-渐变震动")
                    }
                } else {
                    BDLogger.info("震动马达-倒计时震动指令设置-失败")
                    self.showError("震动马达-倒计时震动指令设置-失败")
                }
            case let .failure(error):
                BDLogger.error("震动马达-倒计时震动指令设置失败: \(error)")
                self.showError("震动马达-倒计时震动指令设置失败: \(error)")
            }
        }
    }
}
