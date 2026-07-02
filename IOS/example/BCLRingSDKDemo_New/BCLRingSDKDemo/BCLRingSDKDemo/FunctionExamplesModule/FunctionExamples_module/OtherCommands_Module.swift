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
        default:
            showError("未知功能ID: \(id)")
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
}
