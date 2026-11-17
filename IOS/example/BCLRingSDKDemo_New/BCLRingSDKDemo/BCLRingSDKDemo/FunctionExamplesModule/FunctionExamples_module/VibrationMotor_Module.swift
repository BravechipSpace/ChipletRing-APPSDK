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

/// 马达震动功能模块 (331-340) - 立即/停止振动、倒计时、振动配置和计数管理
class VibrationMotor_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 331 ... 340)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 331:
            showImmediateVibrationTypeDialog()
        case 332:
            vibrateDelayedConfigDialog()
        case 333:
            readVibrationConfig()
        case 334:
            setVibrationConfig()
        case 335:
            readTargetValue()
        case 336:
            setTargetValue()
        case 337:
            readCountValue()
        case 338:
            clearCountValue()
        case 339:
            stopVibration()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 331 - 选择立即振动模式，取消时不发送命令
    private func showImmediateVibrationTypeDialog() {
        guard let viewController = viewController else { return }
        let alert = UIAlertController(title: "线性马达-立即振动", message: "请选择振动模式", preferredStyle: .alert)
        let modes: [(String, BCLVibrationMotorType)] = [
            ("强力振动", .strongVibration),
            ("持续振动", .continuousVibration),
            ("渐变振动", .gradientVibration),
        ]
        for (title, type) in modes {
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.vibrateImmediate(type: type, modeName: title)
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController.present(alert, animated: true)
    }

    /// 立即振动：有效响应不代表设备执行成功，需检查 isSuccess（0=成功、1=失败）
    private func vibrateImmediate(type: BCLVibrationMotorType, modeName: String) {
        BCLRingManager.shared.linearMotorImmediateVibration(type: type) { [weak self] res in
            switch res {
            case let .success(response):
                self?.showVibrationExecutionResult(response.isSuccess, actionName: "线性马达立即振动（\(modeName)）")
            case let .failure(error):
                BDLogger.error("线性马达立即振动失败: \(error)")
                self?.showError("线性马达立即振动失败: \(error)")
            }
        }
    }

    /// 339 - 停止振动，无需先通过本示例启动振动
    private func stopVibration() {
        BCLRingManager.shared.linearMotorStopVibration { [weak self] res in
            switch res {
            case let .success(response):
                self?.showVibrationExecutionResult(response.isSuccess, actionName: "线性马达停止振动")
            case let .failure(error):
                BDLogger.error("线性马达停止振动失败: \(error)")
                self?.showError("线性马达停止振动失败: \(error)")
            }
        }
    }

    /// 展示立即/停止振动的设备执行结果，通信及解析错误在各接口回调中处理
    private func showVibrationExecutionResult(_ isSuccess: Bool, actionName: String) {
        if isSuccess {
            BDLogger.info("\(actionName)-成功")
            showSuccess("\(actionName)-成功")
        } else {
            BDLogger.info("\(actionName)-设备执行失败")
            showError("\(actionName)-设备执行失败")
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

    // 333 - 线性马达读取振动配置
    private func readVibrationConfig() {
        BCLRingManager.shared.linearMotorReadVibrationConfigs { [weak self] res in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch res {
                case let .success(response):
                    let configText: String
                    if response.configurations.isEmpty {
                        configText = "无振动配置"
                    } else {
                        configText = response.configurations.enumerated().map { index, config in
                            return "配置\(index + 1)：强度 \(config.intensity)，时长 \(config.duration) × 5ms = \(config.durationMilliseconds)ms"
                        }.joined(separator: "\n")
                    }
                    let message = "线性马达读取振动配置成功，共\(response.configurations.count)项\n\(configText)"
                    BDLogger.info(message)
                    self.showSuccess(message)
                case let .failure(error):
                    BDLogger.error("线性马达读取振动配置失败: \(error)")
                    self.showError("线性马达读取振动配置失败: \(error.localizedDescription)")
                }
            }
        }
    }

    // 334 - 线性马达设置振动配置
    private func setVibrationConfig() {
        let configurations = [
            BCLLinearMotorVibrationConfigEntry(intensity: 80, duration: 10),
            BCLLinearMotorVibrationConfigEntry(intensity: 140, duration: 20),
            BCLLinearMotorVibrationConfigEntry(intensity: 220, duration: 30),
        ]
        let configText = configurations.enumerated().map { index, config in
            return "配置\(index + 1)：强度 \(config.intensity)，时长 \(config.duration) × 5ms = \(config.durationMilliseconds)ms"
        }.joined(separator: "；")
        BDLogger.info("开始设置线性马达振动配置，共\(configurations.count)项：\(configText)")

        BCLRingManager.shared.linearMotorSetVibrationConfigs(configurations) { [weak self] res in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch res {
                case let .success(response):
                    if response.isSuccess {
                        BDLogger.info("线性马达设置振动配置成功：\(configText)")
                        self.showSuccess("线性马达设置振动配置成功\n\(configText)")
                    } else {
                        BDLogger.error("线性马达设置振动配置失败：设备拒绝执行")
                        self.showError("线性马达设置振动配置失败：设备拒绝执行")
                    }
                case let .failure(error):
                    BDLogger.error("线性马达设置振动配置失败：\(error)")
                    self.showError("线性马达设置振动配置失败：\(error.localizedDescription)")
                }
            }
        }
    }

    // 335 - 线性马达读取目标值
    private func readTargetValue() {
        BCLRingManager.shared.linearMotorReadTargetValue { res in
            switch res {
            case let .success(response):
                let message = "线性马达读取目标值成功：\(response.targetValue)"
                BDLogger.info(message)
                self.showSuccess(message)
            case let .failure(error):
                BDLogger.error("线性马达读取目标值失败: \(error)")
                self.showError("线性马达读取目标值失败: \(error)")
            }
        }
    }

    // 336 - 线性马达设置目标值
    private func setTargetValue() {
        let targetValue: UInt32 = 100
        BDLogger.info("开始设置线性马达目标值: \(targetValue)")

        BCLRingManager.shared.linearMotorSetTargetValue(targetValue) { res in
            self.handleLinearMotorStatusResult(res, actionName: "线性马达设置目标值")
        }
    }

    // 337 - 线性马达读取计数值
    private func readCountValue() {
        BCLRingManager.shared.linearMotorReadCountValue { res in
            switch res {
            case let .success(response):
                let message = "线性马达读取计数值成功：\(response.countValue)"
                BDLogger.info(message)
                self.showSuccess(message)
            case let .failure(error):
                BDLogger.error("线性马达读取计数值失败: \(error)")
                self.showError("线性马达读取计数值失败: \(error)")
            }
        }
    }

    // 338 - 线性马达清空计数值
    private func clearCountValue() {
        BCLRingManager.shared.linearMotorClearCountValue { res in
            self.handleLinearMotorStatusResult(res, actionName: "线性马达清空计数值")
        }
    }

    private func handleLinearMotorStatusResult(_ result: Result<BCLLinearMotorSetVibrationConfigResponse, BCLError>,
                                               actionName: String) {
        switch result {
        case let .success(response):
            handleLinearMotorStatus(response.status, actionName: actionName)
        case let .failure(error):
            BDLogger.error("\(actionName)失败: \(error)")
            showError("\(actionName)失败: \(error)")
        }
    }

    private func handleLinearMotorStatusResult(_ result: Result<BCLLinearMotorSetTargetValueResponse, BCLError>,
                                               actionName: String) {
        switch result {
        case let .success(response):
            handleLinearMotorStatus(response.status, actionName: actionName)
        case let .failure(error):
            BDLogger.error("\(actionName)失败: \(error)")
            showError("\(actionName)失败: \(error)")
        }
    }

    private func handleLinearMotorStatusResult(_ result: Result<BCLLinearMotorClearCountValueResponse, BCLError>,
                                               actionName: String) {
        switch result {
        case let .success(response):
            handleLinearMotorStatus(response.status, actionName: actionName)
        case let .failure(error):
            BDLogger.error("\(actionName)失败: \(error)")
            showError("\(actionName)失败: \(error)")
        }
    }

    private func handleLinearMotorStatus(_ status: BCLLinearMotorResultStatus?,
                                         actionName: String) {
        if status == .success {
            BDLogger.info("\(actionName)-成功")
            showSuccess("\(actionName)-成功")
        } else {
            BDLogger.info("\(actionName)-失败")
            showError("\(actionName)-失败")
        }
    }
}
