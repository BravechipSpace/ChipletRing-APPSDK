//
//  OtherCommands_Module.swift
//  BCLRingSDKDemo
//
//  Created by Codex on 2026/01/29.
//  其他相关指令功能模块（2000-3000）
//

import BCLRingSDK
import QMUIKit
import UIKit

class OtherCommands_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 2000 ... 3000)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 2001: // 2001 - 设置SN码
            presentSetSNCodeDialog()
        case 2002: // 2002 - 获取SN码
            getSNCode()
        case 2003: // 2003 - LED状态指示灯校验
            presentLEDStatusIndicatorCheckDialog()
        case 2004: // 2004 - 读取Touch Button ID
            readTouchButtonID()
        case 2005: // 2005 - 读取电池AD采样值
            readBatteryADSampleValue()
        case 2006: // 2006 - 设置Shipmode（运输模式）
            setShipmode()
        case 2007: // 2007 - 复位测试
            resetTest()
        case 2008: // 2008 - 设置自定义灯光特效
            setCustomLightEffects()
        case 2009: // 2009 - 获取自定义灯光特效
            getCustomLightEffects()
        case 2010: // 2010 - 设置自定义震动特效
            setCustomVibrationEffects()
        case 2011: // 2011 - 获取自定义震动特效
            getCustomVibrationEffects()
        case 2012: // 2012 - 启动查找戒指
            startFindRing()
        case 2013: // 2013 - 结束查找戒指
            stopFindRing()
        case 2014: // 2014 - 启动戒指勿扰模式
            startDoNotDisturbMode()
        case 2015: // 2015 - 结束戒指勿扰模式
            stopDoNotDisturbMode()
        case 2016: // 2016 - 启动戒指常亮模式
            startAlwaysOnMode()
        case 2017: // 2017 - 结束戒指常亮模式
            stopAlwaysOnMode()
        case 2018: // 2018 - APP启动灯光震动特效
            startLightAndVibrationEffect()
        case 2019: // 2019 - APP结束灯光震动特效
            stopLightAndVibrationEffect()
        case 2020: // 2020 - 设置心率压力报警参数
            setHeartRateStressAlarmConfig()
        case 2021: // 2021 - 读取心率压力报警参数
            getHeartRateStressAlarmConfig()
        case 2022: // 2022 - 监听/取消监听戒指报警信息
            toggleHeartRateStressAlarmPush()
        case 2023: // 2023 - 读取戒指勿扰模式
            readDoNotDisturbMode()
        case 2024: // 2024 - 设置戒指LED模式亮度
            setRingLEDMode()
        case 2025: // 2025 - 查询戒指LED模式
            getRingLEDMode()
        case 2026: // 2026 - 设置戒指马达模式
            setRingMotorMode()
        case 2027: // 2027 - 查询戒指马达模式
            getRingMotorMode()
        case 2028: // 2028 - 马达振动测试
            motorVibrationTest()
        case 2029: // 2029 - 设置闹钟马达模式
            setAlarmMotorMode()
        case 2030: // 2030 - 查询闹钟马达模式
            getAlarmMotorMode()
        case 2031: // 2031 - 设置压力报警冻结延时
            showStressAlarmFreezeDelayDialog()
        case 2032: // 2032 - 获取压力报警冻结延时
            getStressAlarmFreezeDelay()
        case 2033: // 2033 - 设备密钥鉴权（独立于GoMore授权）
            presentDeviceKeyAuthenticationDialog()
        case 2034: // 2034 - 查询设备授权状态
            queryDeviceAuthorizationStatus()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - 设备密钥鉴权

    /// 只在本次输入中使用密钥，不打印原始字节或回传密钥。
    private func presentDeviceKeyAuthenticationDialog() {
        let contentView = DeviceKeyAuthenticationConfig_Dialog(x: 0, y: 0, width: 340, height: 320)
        contentView.confirmButtonCallback = { [weak self] key in
            self?.authenticateDevice(key: key)
        }
        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func authenticateDevice(key: Data) {
        let keyByteCount = key.count // 回调只捕获长度，不额外捕获密钥。
        BDLogger.info("开始设备密钥鉴权，密钥长度：\(keyByteCount)字节")
        showLoading("设备鉴权中...", userInteractionEnabled: false)
        BCLRingManager.shared.authenticateDevice(key: key) { [weak self] result in
            self?.hideLoading()
            switch result {
            case let .success(response):
                let message: String
                switch response.status {
                case .success?: message = "鉴权成功，回传密钥校验一致"
                case .failure?: message = "设备鉴权失败"
                case nil: message = "未知鉴权状态：\(response.statusRawValue.map { String($0) } ?? "未提供")"
                }
                BDLogger.info("\(message)，密钥长度：\(keyByteCount)字节")
                self?.showInfoAlert(title: "设备密钥鉴权", message: message)
            case let .failure(error):
                BDLogger.error("设备密钥鉴权通信或解析失败：\(error.localizedDescription)")
                self?.showError("鉴权失败：\(error.localizedDescription)")
            }
        }
    }

    private func queryDeviceAuthorizationStatus() {
        showLoading("查询设备授权状态...", userInteractionEnabled: false)
        BCLRingManager.shared.queryDeviceAuthorizationStatus { [weak self] result in
            self?.hideLoading()
            switch result {
            case let .success(response):
                let message: String
                switch response.isAuthorized {
                case true?: message = "已授权"
                case false?: message = "未授权"
                case nil: message = "未知授权状态：\(response.statusRawValue.map { String($0) } ?? "未提供")"
                }
                BDLogger.info("设备授权状态：\(message)")
                self?.showInfoAlert(title: "设备授权状态", message: message)
            case let .failure(error):
                BDLogger.error("设备授权查询失败：\(error.localizedDescription)")
                self?.showError("查询失败：\(error.localizedDescription)")
            }
        }
    }

    // MARK: - SN Code

    private func presentSetSNCodeDialog() {
        let contentView = SNCodeConfig_Dialog(x: 0, y: 0, width: 320, height: 230)
        contentView.confirmButtonCallback = { [weak self] snCode in
            self?.setSNCode(snCode: snCode)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func setSNCode(snCode: String) {
        BDLogger.info("📤 开始设置SN码: \(snCode)")
        showLoading("设置SN码中...", userInteractionEnabled: false)

        BCLRingManager.shared.setSNCode(snCode: snCode) { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()

            switch result {
            case let .success(response):
                BDLogger.info("✅ 设置SN码完成, status: \(response.status)")
                if response.isSuccess {
                    self.showSuccess("设置SN码成功 (status: \(response.status))")
                } else {
                    self.showError("设置SN码失败 (status: \(response.status))")
                }
            case let .failure(error):
                BDLogger.error("❌ 设置SN码失败: \(error)")
                self.showError("设置SN码失败: \(error.localizedDescription)")
            }
        }
    }

    private func getSNCode() {
        BDLogger.info("📥 开始获取SN码")
        showLoading("获取SN码中...", userInteractionEnabled: false)

        BCLRingManager.shared.getSNCode { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()

            switch result {
            case let .success(response):
                BDLogger.info("✅ 获取SN码成功: \(response.snCode)")
                self.showInfoAlert(title: "SN码", message: "SN码: \(response.snCode)")
            case let .failure(error):
                BDLogger.error("❌ 获取SN码失败: \(error)")
                self.showError("获取SN码失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - LED Status Indicator Check

    private func presentLEDStatusIndicatorCheckDialog() {
        guard let viewController = viewController else { return }

        let alert = UIAlertController(title: "LED状态指示灯校验", message: "请选择要下发的状态", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "打开", style: .default) { [weak self] _ in
            self?.setLEDStatusIndicatorCheck(isOn: true)
        })
        alert.addAction(UIAlertAction(title: "关闭", style: .default) { [weak self] _ in
            self?.setLEDStatusIndicatorCheck(isOn: false)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))

        viewController.present(alert, animated: true)
    }

    private func setLEDStatusIndicatorCheck(isOn: Bool) {
        let actionText = isOn ? "打开" : "关闭"
        BDLogger.info("💡 开始LED状态指示灯校验: \(actionText)")
        showLoading("LED状态指示灯校验中...", userInteractionEnabled: false)

        BCLRingManager.shared.setLEDStatusIndicatorCheck(isOn: isOn) { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()

            switch result {
            case .success:
                BDLogger.info("✅ LED状态指示灯校验指令发送成功: \(actionText)")
                self.showSuccess("LED状态指示灯已\(actionText)")
            case let .failure(error):
                BDLogger.error("❌ LED状态指示灯校验失败: \(error)")
                self.showError("LED状态指示灯校验失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Touch Button ID

    private func readTouchButtonID() {
        BDLogger.info("🔘 开始读取Touch Button ID")
        showLoading("读取Touch Button ID中...", userInteractionEnabled: false)

        BCLRingManager.shared.touchButtonIDRead { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()

            switch result {
            case let .success(response):
                let touchButtonID = response.touchButtonID ?? -1
                BDLogger.info("✅ 读取Touch Button ID成功: \(touchButtonID)")
                self.showInfoAlert(title: "Touch Button ID", message: "Touch Button ID: \(touchButtonID)")
            case let .failure(error):
                BDLogger.error("❌ 读取Touch Button ID失败: \(error)")
                self.showError("读取Touch Button ID失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Battery AD Sample Value

    private func readBatteryADSampleValue() {
        BDLogger.info("🔋 开始读取电池AD采样值")
        showLoading("读取电池AD采样值中...", userInteractionEnabled: false)

        BCLRingManager.shared.readBatteryADSampleValue { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()

            switch result {
            case let .success(response):
                let adSampleValue = response.adSampleValue ?? -1
                BDLogger.info("✅ 读取电池AD采样值成功: \(adSampleValue)")
                self.showInfoAlert(title: "电池AD采样值", message: "AD采样值: \(adSampleValue)")
            case let .failure(error):
                BDLogger.error("❌ 读取电池AD采样值失败: \(error)")
                self.showError("读取电池AD采样值失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Shipmode

    private func setShipmode() {
        BDLogger.info("📦 开始设置Shipmode")
        showLoading("设置Shipmode中...", userInteractionEnabled: false)

        BCLRingManager.shared.setShipmode { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()

            switch result {
            case .success:
                BDLogger.info("✅ 设置Shipmode成功")
                self.showSuccess("设置Shipmode成功")
            case let .failure(error):
                BDLogger.error("❌ 设置Shipmode失败: \(error)")
                self.showError("设置Shipmode失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Reset Test

    private func resetTest() {
        BDLogger.info("开始复位测试")
        showLoading("复位测试中...", userInteractionEnabled: false)

        BCLRingManager.shared.reset { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()

            switch result {
            case .success:
                BDLogger.info("复位测试成功，等待设备重启")
                self.showSuccess("复位测试成功")
            case let .failure(error):
                BDLogger.error("复位测试失败: \(error)")
                self.showError("复位测试失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Motor Vibration Test

    /// 马达振动测试示例：协议无参数、无设备响应，实际振动需人工观察。
    private func motorVibrationTest() {
        BDLogger.info("开始发送马达振动测试指令（0xF2/0x24）")
        showLoading("正在发送马达振动测试指令...", userInteractionEnabled: false)

        BCLRingManager.shared.motorVibrationTest { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()

                switch result {
                case .success:
                    // SDK 本地完成仅表示指令已发送，不代表设备确认或硬件测试通过。
                    BDLogger.info("马达振动测试指令已发送，请观察戒指振动")
                    self.showSuccess("马达振动测试指令已发送，请观察戒指振动")
                case let .failure(error):
                    BDLogger.error("马达振动测试指令发送失败: \(error)")
                    self.showError("马达振动测试指令发送失败: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Custom Light Effects

    /// 设置自定义灯光特效示例
    private func setCustomLightEffects() {
        let flashingStage = BCLCustomLightEffectStage(mode: .flashing,
                                                      loopCount: 3,
                                                      startBrightness: 10,
                                                      middleBrightness: 100,
                                                      endBrightness: 10,
                                                      riseStepDelay: 100,
                                                      fallStepDelay: 100)
        let breathingStage = BCLCustomLightEffectStage(mode: .breathing,
                                                       loopCount: 2,
                                                       startBrightness: 0,
                                                       middleBrightness: 100,
                                                       endBrightness: 0,
                                                       riseStepDelay: 20,
                                                       fallStepDelay: 20)
        let effect = BCLCustomLightEffect(effectId: 1,
                                          firstStage: flashingStage,
                                          secondStage: breathingStage)

        BDLogger.info("开始设置自定义灯光特效")
        showLoading("设置自定义灯光特效中...", userInteractionEnabled: false)
        BCLRingManager.shared.setCustomLightEffects([effect]) { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()
            switch result {
            case let .success(response):
                if response.isSuccess {
                    BDLogger.info("设置自定义灯光特效成功")
                    self.showSuccess("设置自定义灯光特效成功")
                } else {
                    BDLogger.error("设置自定义灯光特效失败，状态码: \(response.statusRawValue)")
                    self.showError("设置失败，状态码: \(response.statusRawValue)")
                }
            case let .failure(error):
                BDLogger.error("设置自定义灯光特效失败: \(error)")
                self.showError("设置自定义灯光特效失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取自定义灯光特效示例
    private func getCustomLightEffects() {
        BDLogger.info("开始获取自定义灯光特效")
        showLoading("获取自定义灯光特效中...", userInteractionEnabled: false)
        BCLRingManager.shared.getCustomLightEffects { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()
            switch result {
            case let .success(response):
                let descriptions = response.effects.map(self.customLightEffectDescription)
                let message = descriptions.isEmpty ? "当前没有自定义灯光特效" : descriptions.joined(separator: "\n\n")
                BDLogger.info("获取自定义灯光特效成功，共\(response.effectCount)条")
                self.showInfoAlert(title: "自定义灯光特效（\(response.effectCount)条）", message: message)
            case let .failure(error):
                BDLogger.error("获取自定义灯光特效失败: \(error)")
                self.showError("获取自定义灯光特效失败: \(error.localizedDescription)")
            }
        }
    }

    /// 自定义灯光特效描述
    private func customLightEffectDescription(_ effect: BCLCustomLightEffect) -> String {
        return """
        序号：\(effect.effectId)
        第一段：\(customLightEffectStageDescription(effect.firstStage))
        第二段：\(customLightEffectStageDescription(effect.secondStage))
        """
    }

    /// 自定义灯光特效阶段描述
    private func customLightEffectStageDescription(_ stage: BCLCustomLightEffectStage) -> String {
        let mode: String
        switch stage.mode {
        case .none:
            mode = "无"
        case .flashing:
            mode = "闪烁"
        case .breathing:
            mode = "呼吸"
        }
        let loop = stage.loopCount == 0 ? "无限" : "\(stage.loopCount)"
        return "\(mode)，循环\(loop)次，亮度\(stage.startBrightness)/\(stage.middleBrightness)/\(stage.endBrightness)，延时\(stage.riseStepDelay)/\(stage.fallStepDelay)ms"
    }

    // MARK: - Custom Vibration Effects

    /// 设置自定义震动特效示例
    private func setCustomVibrationEffects() {
        let limitedEffect = BCLCustomVibrationEffect(effectId: 1,
                                                     loopCount: 3,
                                                     intensity: 100,
                                                     vibrationDelay: 200,
                                                     pauseDelay: 100)
        let infiniteEffect = BCLCustomVibrationEffect(effectId: 2,
                                                      loopCount: 0,
                                                      intensity: 60,
                                                      vibrationDelay: 500,
                                                      pauseDelay: 1000)

        BDLogger.info("开始设置自定义震动特效")
        showLoading("设置自定义震动特效中...", userInteractionEnabled: false)
        BCLRingManager.shared.setCustomVibrationEffects([limitedEffect, infiniteEffect]) { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()
            switch result {
            case let .success(response):
                if response.isSuccess {
                    BDLogger.info("设置自定义震动特效成功")
                    self.showSuccess("设置自定义震动特效成功")
                } else {
                    BDLogger.error("设置自定义震动特效失败，状态码: \(response.statusRawValue)")
                    self.showError("设置失败，状态码: \(response.statusRawValue)")
                }
            case let .failure(error):
                BDLogger.error("设置自定义震动特效失败: \(error)")
                self.showError("设置自定义震动特效失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取自定义震动特效示例
    private func getCustomVibrationEffects() {
        BDLogger.info("开始获取自定义震动特效")
        showLoading("获取自定义震动特效中...", userInteractionEnabled: false)
        BCLRingManager.shared.getCustomVibrationEffects { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()
            switch result {
            case let .success(response):
                let descriptions = response.effects.map(self.customVibrationEffectDescription)
                let message = descriptions.isEmpty ? "当前没有自定义震动特效" : descriptions.joined(separator: "\n\n")
                BDLogger.info("获取自定义震动特效成功，共\(response.effectCount)条")
                self.showInfoAlert(title: "自定义震动特效（\(response.effectCount)条）", message: message)
            case let .failure(error):
                BDLogger.error("获取自定义震动特效失败: \(error)")
                self.showError("获取自定义震动特效失败: \(error.localizedDescription)")
            }
        }
    }

    /// 自定义震动特效描述
    private func customVibrationEffectDescription(_ effect: BCLCustomVibrationEffect) -> String {
        let loop = effect.loopCount == 0 ? "无限" : "\(effect.loopCount)"
        return """
        序号：\(effect.effectId)
        循环次数：\(loop)
        震动强度：\(effect.intensity)
        震动延时：\(effect.vibrationDelay)ms
        暂停延时：\(effect.pauseDelay)ms
        """
    }

    // MARK: - Ring Mode Control

    /// 启动查找戒指示例
    private func startFindRing() {
        let actionName = "启动查找戒指"
        BDLogger.info("开始\(actionName)")
        showLoading("\(actionName)中...", userInteractionEnabled: false)
        BCLRingManager.shared.startFindRing { [weak self] result in
            self?.handleRingModeControlResult(result, actionName: actionName)
        }
    }

    /// 结束查找戒指示例
    private func stopFindRing() {
        let actionName = "结束查找戒指"
        BDLogger.info("开始\(actionName)")
        showLoading("\(actionName)中...", userInteractionEnabled: false)
        BCLRingManager.shared.stopFindRing { [weak self] result in
            self?.handleRingModeControlResult(result, actionName: actionName)
        }
    }

    /// 启动戒指勿扰模式示例
    private func startDoNotDisturbMode() {
        let actionName = "启动戒指勿扰模式"
        BDLogger.info("开始\(actionName)")
        showLoading("\(actionName)中...", userInteractionEnabled: false)
        BCLRingManager.shared.startDoNotDisturbMode { [weak self] result in
            self?.handleRingModeControlResult(result, actionName: actionName)
        }
    }

    /// 结束戒指勿扰模式示例
    private func stopDoNotDisturbMode() {
        let actionName = "结束戒指勿扰模式"
        BDLogger.info("开始\(actionName)")
        showLoading("\(actionName)中...", userInteractionEnabled: false)
        BCLRingManager.shared.stopDoNotDisturbMode { [weak self] result in
            self?.handleRingModeControlResult(result, actionName: actionName)
        }
    }

    /// 读取戒指勿扰模式示例
    private func readDoNotDisturbMode() {
        let actionName = "读取戒指勿扰模式"
        BDLogger.info("开始\(actionName)")
        showLoading("\(actionName)中...", userInteractionEnabled: false)
        BCLRingManager.shared.readDoNotDisturbMode { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()
            switch result {
            case let .success(response):
                let modeDescription = response.isDoNotDisturbMode ? "勿扰模式" : "非勿扰模式"
                BDLogger.info("\(actionName)成功：\(modeDescription)")
                self.showInfoAlert(title: actionName, message: modeDescription)
            case let .failure(error):
                BDLogger.error("\(actionName)失败: \(error)")
                self.showError("\(actionName)失败: \(error.localizedDescription)")
            }
        }
    }

    /// 启动戒指常亮模式示例
    private func startAlwaysOnMode() {
        let actionName = "启动戒指常亮模式"
        BDLogger.info("开始\(actionName)")
        showLoading("\(actionName)中...", userInteractionEnabled: false)
        BCLRingManager.shared.startAlwaysOnMode { [weak self] result in
            self?.handleRingModeControlResult(result, actionName: actionName)
        }
    }

    /// 结束戒指常亮模式示例
    private func stopAlwaysOnMode() {
        let actionName = "结束戒指常亮模式"
        BDLogger.info("开始\(actionName)")
        showLoading("\(actionName)中...", userInteractionEnabled: false)
        BCLRingManager.shared.stopAlwaysOnMode { [weak self] result in
            self?.handleRingModeControlResult(result, actionName: actionName)
        }
    }

    /// APP启动灯光震动特效示例
    private func startLightAndVibrationEffect() {
        let actionName = "APP启动灯光震动特效"
        let vibrationEffectId: UInt8 = 1
        let lightEffectId: UInt8 = 1
        BDLogger.info("开始\(actionName)，震动特效序号: \(vibrationEffectId)，灯光特效序号: \(lightEffectId)")
        showLoading("\(actionName)中...", userInteractionEnabled: false)
        BCLRingManager.shared.startLightAndVibrationEffect(vibrationEffectId: vibrationEffectId,
                                                           lightEffectId: lightEffectId) { [weak self] result in
            self?.handleRingModeControlResult(result, actionName: actionName)
        }
    }

    /// APP结束灯光震动特效示例
    private func stopLightAndVibrationEffect() {
        let actionName = "APP结束灯光震动特效"
        BDLogger.info("开始\(actionName)")
        showLoading("\(actionName)中...", userInteractionEnabled: false)
        BCLRingManager.shared.stopLightAndVibrationEffect { [weak self] result in
            self?.handleRingModeControlResult(result, actionName: actionName)
        }
    }

    /// 处理戒指模式控制结果
    private func handleRingModeControlResult(_ result: Result<BCLRingModeControlResponse, BCLError>,
                                             actionName: String) {
        hideLoading()
        switch result {
        case .success:
            BDLogger.info("\(actionName)成功")
            showSuccess("\(actionName)成功")
        case let .failure(error):
            BDLogger.error("\(actionName)失败: \(error)")
            showError("\(actionName)失败: \(error.localizedDescription)")
        }
    }

    // MARK: - Heart Rate Stress Alarm

    /// 设置心率压力报警参数示例
    private func setHeartRateStressAlarmConfig() {
        let config = BCLHeartRateStressAlarmConfig(mode: .heartRateAndStress,
                                                   heartRateThreshold: 120,
                                                   stressThreshold: 80,
                                                   walkingDelayMinutes: 5,
                                                   runningDelayMinutes: 10)
        BDLogger.info("""
        开始设置心率压力报警参数，
        报警模式: \(heartRateStressAlarmModeDescription(config.mode))，
        心率阈值: \(config.heartRateThreshold)，
        压力阈值: \(config.stressThreshold)，
        走路后延时: \(config.walkingDelayMinutes)分钟，
        跑步后延时: \(config.runningDelayMinutes)分钟
        """)
        showLoading("设置心率压力报警参数中...", userInteractionEnabled: false)
        BCLRingManager.shared.setHeartRateStressAlarmConfig(config) { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()
            switch result {
            case .success:
                BDLogger.info("设置心率压力报警参数成功")
                self.showSuccess("设置心率压力报警参数成功")
            case let .failure(error):
                BDLogger.error("设置心率压力报警参数失败: \(error)")
                self.showError("设置心率压力报警参数失败: \(error.localizedDescription)")
            }
        }
    }

    /// 读取心率压力报警参数示例
    private func getHeartRateStressAlarmConfig() {
        BDLogger.info("开始读取心率压力报警参数")
        showLoading("读取心率压力报警参数中...", userInteractionEnabled: false)
        BCLRingManager.shared.getHeartRateStressAlarmConfig { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()
            switch result {
            case let .success(response):
                guard let config = response.config else {
                    BDLogger.error("读取心率压力报警参数成功，但响应中没有有效参数")
                    self.showError("响应中没有有效的心率压力报警参数")
                    return
                }
                let message = """
                报警模式：\(self.heartRateStressAlarmModeDescription(config.mode))
                心率报警阈值：\(config.heartRateThreshold)
                压力报警阈值：\(config.stressThreshold)
                走路后延时：\(config.walkingDelayMinutes)分钟
                跑步后延时：\(config.runningDelayMinutes)分钟
                """
                BDLogger.info("读取心率压力报警参数成功\n\(message)")
                self.showInfoAlert(title: "心率压力报警参数", message: message)
            case let .failure(error):
                BDLogger.error("读取心率压力报警参数失败: \(error)")
                self.showError("读取心率压力报警参数失败: \(error.localizedDescription)")
            }
        }
    }

    /// 监听或取消监听戒指主动上传报警信息示例
    private func toggleHeartRateStressAlarmPush() {
        if BCLRingManager.shared.heartRateStressAlarmPushBlock == nil {
            BCLRingManager.shared.heartRateStressAlarmPushBlock = { [weak self] response in
                guard let self = self, let alarmType = response.alarmType else { return }
                let message = """
                报警类型：\(self.heartRateStressAlarmTypeDescription(alarmType))
                心率值：\(response.heartRate)
                压力指数：\(response.stressIndex)
                """
                BDLogger.info("收到戒指主动上传报警信息\n\(message)")
                DispatchQueue.main.async {
                    self.showInfoAlert(title: "戒指报警信息", message: message)
                }
            }
            BDLogger.info("已开始监听戒指主动上传报警信息")
            showSuccess("已开始监听戒指报警信息")
        } else {
            BCLRingManager.shared.heartRateStressAlarmPushBlock = nil
            BDLogger.info("已取消监听戒指主动上传报警信息")
            showSuccess("已取消监听戒指报警信息")
        }
    }

    /// 心率压力报警模式描述
    private func heartRateStressAlarmModeDescription(_ mode: BCLHeartRateStressAlarmMode) -> String {
        switch mode {
        case .disabled:
            return "禁止报警"
        case .heartRate:
            return "心率报警"
        case .stress:
            return "压力报警"
        case .heartRateAndStress:
            return "心率和压力报警"
        }
    }

    /// 心率压力报警类型描述
    private func heartRateStressAlarmTypeDescription(_ type: BCLHeartRateStressAlarmType) -> String {
        switch type {
        case .heartRate:
            return "心率报警"
        case .stress:
            return "压力报警"
        case .heartRateAndStress:
            return "心率和压力报警"
        }
    }

    /// 显示压力报警冻结延时时间设置弹窗
    private func showStressAlarmFreezeDelayDialog() {
        let alert = UIAlertController(title: "设置压力报警冻结延时",
                                      message: "请输入冻结延时时间（分钟）\n范围 0...1440，且必须为 10 的整数倍",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "冻结延时时间（分钟）"
            textField.keyboardType = .numberPad
            textField.text = "30"
        }
        let setAction = UIAlertAction(title: "设置", style: .default) { [weak self, weak alert] _ in
            guard let self = self else { return }
            guard let minutesText = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let minutesValue = Int(minutesText),
                  (0 ... 1440).contains(minutesValue),
                  minutesValue % 10 == 0 else {
                self.showError("请输入 0...1440 范围内且为 10 的整数倍")
                return
            }
            self.setStressAlarmFreezeDelay(minutes: UInt16(minutesValue))
        }
        alert.addAction(setAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    /// 设置压力报警冻结延时时间示例
    private func setStressAlarmFreezeDelay(minutes: UInt16) {
        BDLogger.info("开始设置压力报警冻结延时：\(minutes)分钟")
        showLoading("设置压力报警冻结延时中...", userInteractionEnabled: false)
        BCLRingManager.shared.setStressAlarmFreezeDelay(minutes: minutes) { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()
            switch result {
            case let .success(response):
                guard let actualMinutes = response.freezeDelayMinutes else {
                    BDLogger.error("设置压力报警冻结延时成功，但响应中没有有效时间")
                    self.showError("响应中没有有效的压力报警冻结延时")
                    return
                }
                BDLogger.info("设置压力报警冻结延时成功，设备返回：\(actualMinutes)分钟")
                self.showSuccess("设置压力报警冻结延时成功：\(actualMinutes)分钟")
            case let .failure(error):
                BDLogger.error("设置压力报警冻结延时失败: \(error)")
                self.showError("设置压力报警冻结延时失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取压力报警冻结延时时间示例
    private func getStressAlarmFreezeDelay() {
        BDLogger.info("开始获取压力报警冻结延时")
        showLoading("获取压力报警冻结延时中...", userInteractionEnabled: false)
        BCLRingManager.shared.getStressAlarmFreezeDelay { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()
            switch result {
            case let .success(response):
                guard let minutes = response.freezeDelayMinutes else {
                    BDLogger.error("获取压力报警冻结延时成功，但响应中没有有效时间")
                    self.showError("响应中没有有效的压力报警冻结延时")
                    return
                }
                BDLogger.info("获取压力报警冻结延时成功：\(minutes)分钟")
                self.showInfoAlert(title: "压力报警冻结延时", message: "当前冻结延时：\(minutes)分钟")
            case let .failure(error):
                BDLogger.error("获取压力报警冻结延时失败: \(error)")
                self.showError("获取压力报警冻结延时失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - LED、马达模式

    private func setRingLEDMode() {
        let type = BCLRingLEDModeType.bluetoothConnected
        let style: UInt8 = 0x01
        let brightness = BCLRingLEDBrightness.medium
        BCLRingManager.shared.setRingLEDMode(type: type, style: style, brightness: brightness) { [weak self] result in
            switch result {
            case .success:
                BDLogger.info("设置戒指LED模式成功，类型: \(type.rawValue)，样式: \(style)，亮度: \(brightness.rawValue)")
                self?.showSuccess("设置戒指LED模式成功，亮度: \(brightness.rawValue)")
            case let .failure(error):
                BDLogger.error("设置戒指LED模式失败: \(error)")
                self?.showError("设置戒指LED模式失败: \(error.localizedDescription)")
            }
        }
    }

    private func getRingLEDMode() {
        let type = BCLRingLEDModeType.bluetoothConnected
        BCLRingManager.shared.getRingLEDMode(type: type) { [weak self] result in
            switch result {
            case let .success(response):
                BDLogger.info("查询戒指LED模式成功，类型: \(type.rawValue)，样式: \(response.style)")
                self?.showInfoAlert(title: "戒指LED模式", message: "类型: \(type.rawValue)\n样式: \(response.style)")
            case let .failure(error):
                BDLogger.error("查询戒指LED模式失败: \(error)")
                self?.showError("查询戒指LED模式失败: \(error.localizedDescription)")
            }
        }
    }

    private func setRingMotorMode() {
        let type = BCLRingMotorModeType.recordingStarted
        let style: UInt8 = 0x01
        BCLRingManager.shared.setRingMotorMode(type: type, style: style) { [weak self] result in
            switch result {
            case .success:
                BDLogger.info("设置戒指马达模式成功，类型: \(type.rawValue)，样式: \(style)")
                self?.showSuccess("设置戒指马达模式成功，样式: \(style)")
            case let .failure(error):
                BDLogger.error("设置戒指马达模式失败: \(error)")
                self?.showError("设置戒指马达模式失败: \(error.localizedDescription)")
            }
        }
    }

    private func getRingMotorMode() {
        let type = BCLRingMotorModeType.recordingStarted
        BCLRingManager.shared.getRingMotorMode(type: type) { [weak self] result in
            switch result {
            case let .success(response):
                BDLogger.info("查询戒指马达模式成功，类型: \(type.rawValue)，样式: \(response.style)")
                self?.showInfoAlert(title: "戒指马达模式", message: "类型: \(type.rawValue)\n样式: \(response.style)")
            case let .failure(error):
                BDLogger.error("查询戒指马达模式失败: \(error)")
                self?.showError("查询戒指马达模式失败: \(error.localizedDescription)")
            }
        }
    }

    /// 设置闹钟马达模式，示例使用短振1次。
    private func setAlarmMotorMode() {
        let type = BCLRingMotorModeType.alarm
        let style: UInt8 = 0x01
        BCLRingManager.shared.setRingMotorMode(type: type, style: style) { [weak self] result in
            switch result {
            case .success:
                BDLogger.info("设置闹钟马达模式成功，样式: \(style)")
                self?.showSuccess("设置闹钟马达模式成功，样式: \(style)")
            case let .failure(error):
                BDLogger.error("设置闹钟马达模式失败: \(error)")
                self?.showError("设置闹钟马达模式失败: \(error.localizedDescription)")
            }
        }
    }

    /// 查询闹钟马达模式。
    private func getAlarmMotorMode() {
        let type = BCLRingMotorModeType.alarm
        BCLRingManager.shared.getRingMotorMode(type: type) { [weak self] result in
            switch result {
            case let .success(response):
                BDLogger.info("查询闹钟马达模式成功，样式: \(response.style)")
                self?.showInfoAlert(title: "闹钟马达模式", message: "样式: \(response.style)")
            case let .failure(error):
                BDLogger.error("查询闹钟马达模式失败: \(error)")
                self?.showError("查询闹钟马达模式失败: \(error.localizedDescription)")
            }
        }
    }
}
