//
//  TouchControl_Module.swift
//  BCLRingSDKDemo
//
//  Created by OpenAI Codex on 2026/9/29.
//  Touch空置时间、休眠唤醒与触摸键开关模块 (451-456)
//

import BCLRingSDK
import QMUIKit
import UIKit

/// Touch控制模块 - 演示空置时间设置、读取及休眠唤醒接口
final class TouchControl_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 451 ... 456)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 451:
            presentSetIdleTimeoutDialog()
        case 452:
            readIdleTimeout()
        case 453:
            sleepTouch()
        case 454:
            wakeTouch()
        case 455:
            presentTouchKeyDialog(isSetting: true)
        case 456:
            presentTouchKeyDialog(isSetting: false)
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Touch空置时间

    /// 451 - 展示Touch空置时间设置输入框
    private func presentSetIdleTimeoutDialog() {
        guard let viewController = viewController else { return }

        let alert = UIAlertController(
            title: "设置Touch空置时间",
            message: "请输入0至65535的协议原始值。当前协议未定义时间单位。",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "协议原始值"
            textField.keyboardType = .numberPad
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "设置", style: .default) { [weak self, weak alert] _ in
            guard let self = self else { return }
            let input = alert?.textFields?.first?.text ?? ""
            guard let value = UInt16(input) else {
                BDLogger.error("设置Touch空置时间失败：请输入0至65535的十进制协议原始值")
                self.showError("请输入0至65535的整数")
                return
            }
            self.setIdleTimeout(value)
        })
        viewController.present(alert, animated: true)
    }

    /// 设置Touch空置时间协议原始值
    /// - Parameter value: UInt16协议原始值，协议未定义时间单位
    private func setIdleTimeout(_ value: UInt16) {
        BDLogger.info("设置Touch空置时间，协议原始值：\(value) (0x\(String(format: "%04X", value)))")
        showLoading("设置中...")
        BCLRingManager.shared.setTouchIdleTimeout(value) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case let .success(response):
                    self.handleControlResult(action: "设置Touch空置时间", response: response)
                case let .failure(error):
                    BDLogger.error("设置Touch空置时间失败：\(error)")
                    self.showError("设置Touch空置时间失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 452 - 读取Touch空置时间协议原始值
    private func readIdleTimeout() {
        showLoading("读取中...")
        BCLRingManager.shared.readTouchIdleTimeout { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case let .success(response):
                    let hexValue = String(format: "0x%04X", response.idleTimeout)
                    BDLogger.info("读取Touch空置时间成功，协议原始值：\(response.idleTimeout) (\(hexValue))")
                    self.showInfoAlert(
                        title: "Touch空置时间",
                        message: "十进制原始值：\(response.idleTimeout)\n十六进制原始值：\(hexValue)\n协议未定义时间单位"
                    )
                case let .failure(error):
                    BDLogger.error("读取Touch空置时间失败：\(error)")
                    self.showError("读取Touch空置时间失败：\(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Touch休眠唤醒

    /// 453 - 休眠Touch
    private func sleepTouch() {
        showLoading("休眠中...")
        BCLRingManager.shared.sleepTouch { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case let .success(response):
                    self.handleControlResult(action: "休眠Touch", response: response)
                case let .failure(error):
                    BDLogger.error("休眠Touch失败：\(error)")
                    self.showError("休眠Touch失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 454 - 唤醒Touch
    private func wakeTouch() {
        showLoading("唤醒中...")
        BCLRingManager.shared.wakeTouch { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case let .success(response):
                    self.handleControlResult(action: "唤醒Touch", response: response)
                case let .failure(error):
                    BDLogger.error("唤醒Touch失败：\(error)")
                    self.showError("唤醒Touch失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 统一展示Touch控制类响应
    /// - Parameters:
    ///   - action: 操作名称
    ///   - response: Touch控制结果响应
    private func handleControlResult(action: String, response: BCLTouchControlResultResponse) {
        let statusHex = String(format: "0x%02X", response.statusRawValue)
        BDLogger.info("\(action)响应：status=\(statusHex)，isSuccess=\(response.isSuccess)")
        if response.isSuccess {
            showSuccess("\(action)成功")
        } else {
            showError("\(action)失败，状态：\(statusHex)")
        }
    }

    // MARK: - 触摸键开关

    /// 455/456 - 选择需要设置或读取的触摸键
    private func presentTouchKeyDialog(isSetting: Bool) {
        guard let viewController = viewController else { return }
        let title = isSetting ? "设置触摸键开关" : "读取触摸键开关"
        // 使用 alert 避免 iPad 上 actionSheet 未配置 popover 锚点导致运行时崩溃。
        let alert = UIAlertController(title: title, message: "请选择触摸键", preferredStyle: .alert)
        let keys: [(BCLTouchKey, String)] = [
            (.singleTap, "单击"), (.doubleTap, "双击"), (.tripleTap, "三击"),
            (.swipeUp, "上滑"), (.swipeDown, "下滑"), (.swipeLeft, "左滑"),
            (.swipeRight, "右滑"), (.longPress, "长按"), (.all, "全部"),
        ]
        for (key, name) in keys {
            alert.addAction(UIAlertAction(title: "\(name) (0x\(String(format: "%02X", key.rawValue)))", style: .default) { [weak self] _ in
                if isSetting {
                    self?.presentTouchKeyStateDialog(key: key, keyName: name)
                } else {
                    self?.readTouchKeyState(key: key, keyName: name)
                }
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController.present(alert, animated: true)
    }

    /// 选择开启或关闭触摸键
    private func presentTouchKeyStateDialog(key: BCLTouchKey, keyName: String) {
        guard let viewController = viewController else { return }
        let alert = UIAlertController(title: "设置\(keyName)", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "开启", style: .default) { [weak self] _ in
            self?.setTouchKeyState(key: key, keyName: keyName, enabled: true)
        })
        alert.addAction(UIAlertAction(title: "关闭", style: .default) { [weak self] _ in
            self?.setTouchKeyState(key: key, keyName: keyName, enabled: false)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController.present(alert, animated: true)
    }

    /// 设置触摸键开关
    private func setTouchKeyState(key: BCLTouchKey, keyName: String, enabled: Bool) {
        let stateDescription = enabled ? "开启" : "关闭"
        showLoading("设置中...")
        BCLRingManager.shared.setTouchKey(key, enabled: enabled) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case let .success(response):
                    BDLogger.info("设置触摸键：key=\(keyName)(0x\(String(format: "%02X", key.rawValue)))，状态=\(stateDescription)，结果=\(response.statusRawValue)")
                    response.isSuccess
                        ? self.showSuccess("\(keyName)已\(stateDescription)")
                        : self.showError("设置\(keyName)失败，设备状态：\(response.statusRawValue)")
                case let .failure(error):
                    BDLogger.error("设置触摸键开关失败：\(error)")
                    self.showError("设置触摸键开关失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 读取触摸键开关
    private func readTouchKeyState(key: BCLTouchKey, keyName: String) {
        showLoading("读取中...")
        BCLRingManager.shared.readTouchKeyState(key) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case let .success(response):
                    let keyNames = response.knownKeys.map { self.touchKeyDescription($0) }.joined(separator: "、")
                    let message = "返回键值/掩码：0x\(String(format: "%02X", response.keyValue))\n已知键：\(keyNames.isEmpty ? "无" : keyNames)\n开关原始值：\(response.stateRawValue)\n状态：\(response.isEnabled ? "开启" : "关闭")"
                    BDLogger.info("读取触摸键\(keyName)成功：\(message.replacingOccurrences(of: "\n", with: "，"))")
                    self.showInfoAlert(title: "触摸键状态", message: message)
                case let .failure(error):
                    BDLogger.error("读取触摸键开关失败：\(error)")
                    self.showError("读取触摸键开关失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 触摸键中文说明
    private func touchKeyDescription(_ key: BCLTouchKey) -> String {
        switch key {
        case .singleTap: return "单击"
        case .doubleTap: return "双击"
        case .tripleTap: return "三击"
        case .swipeUp: return "上滑"
        case .swipeDown: return "下滑"
        case .swipeLeft: return "左滑"
        case .swipeRight: return "右滑"
        case .longPress: return "长按"
        case .all: return "全部"
        @unknown default: return String(format: "未知(0x%02X)", key.rawValue)
        }
    }
}
