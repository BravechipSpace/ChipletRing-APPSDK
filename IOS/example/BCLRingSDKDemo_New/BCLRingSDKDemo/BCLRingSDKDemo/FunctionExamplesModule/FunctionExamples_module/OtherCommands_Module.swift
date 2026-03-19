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
}
