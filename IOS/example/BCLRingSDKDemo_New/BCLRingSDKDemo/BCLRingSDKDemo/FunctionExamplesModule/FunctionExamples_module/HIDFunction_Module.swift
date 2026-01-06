//
//  HIDFunction_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  HID功能模块 (121-130)
//

import BCLRingSDK
import QMUIKit
import UIKit

/// HID功能模块 - 处理HID功能码、HID模式、手势功能配置
class HIDFunction_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 121 ... 130)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 121:
            getHIDFunctionCode()
        case 122:
            getCurrentHIDMode()
        case 129:
            setGestureDialog()
        case 130:
            readGestureFunction()
        case 128:
            rediscoverBluetoothServices()
        case 127:
            manualDisconnect()
        case 126:
            toggleHIDServiceSubscription()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 121 - 获取HID功能码
    private func getHIDFunctionCode() {
        BCLRingManager.shared.getHIDFunctionCode { res in
            switch res {
            case let .success(response):
                BDLogger.info("获取HID功能码成功: \(response)")
                BDLogger.info("是否支持HID功能: \(response.isHIDSupported)")
                BDLogger.info("--------------------------------")
                BDLogger.info("触摸功能: \(response.touchFunctionDescription)")
                BDLogger.info("触摸功能原始字节: \(response.touchFunctionByte)")
                BDLogger.info("触摸拍照: \(response.isTouchPhotoSupported)")
                BDLogger.info("触摸短视频模式: \(response.isTouchShortVideoSupported)")
                BDLogger.info("触摸控制音乐: \(response.isTouchMusicControlSupported)")
                BDLogger.info("触摸控制PPT: \(response.isTouchPPTControlSupported)")
                BDLogger.info("触摸控制上传实时音频: \(response.isTouchAudioUploadSupported)")
                BDLogger.info("--------------------------------")
                BDLogger.info("空中手势功能: \(response.gestureFunctionDescription)")
                BDLogger.info("空中手势功能原始字节: \(response.gestureFunctionByte)")
                BDLogger.info("捏一捏手指拍照: \(response.isPinchPhotoSupported)")
                BDLogger.info("手势短视频模式: \(response.isGestureShortVideoSupported)")
                BDLogger.info("空中手势音乐控制: \(response.isGestureMusicControlSupported)")
                BDLogger.info("空中手势PPT模式: \(response.isGesturePPTControlSupported)")
                BDLogger.info("打响指拍照模式: \(response.isSnapPhotoSupported)")
                BDLogger.info("--------------------------------")
            case let .failure(error):
                BDLogger.error("获取HID功能码失败: \(error)")
                self.showError("获取HID功能码失败: \(error.localizedDescription)")
            }
        }
    }

    /// 122 - 获取当前HID模式
    private func getCurrentHIDMode() {
        BCLRingManager.shared.getCurrentHIDMode { res in
            switch res {
            case let .success(response):
                BDLogger.info("获取当前HID模式成功: \(response)")
                BDLogger.info("触摸模式: \(response.touchHIDMode)")
                BDLogger.info("手势模式: \(response.gestureHIDMode)")
                BDLogger.info("系统类型: \(response.systemType)")

            case let .failure(error):
                BDLogger.error("获取当前HID模式失败: \(error)")
                self.showError("获取当前HID模式失败: \(error.localizedDescription)")
            }
        }
    }

    /// 129 - 手势功能配置对话框(Z4I定制)
    private func setGestureDialog() {
        guard let viewController = viewController else { return }
        // 创建手势配置对话框
        let dialogView = GestureFunctionConfig_Dialog(x: 0, y: 0, width: 320, height: 440)
        // 设置presenting view controller用于显示ActionSheet
        dialogView.presentingViewController = viewController
        // 设置确认回调
        dialogView.confirmButtonCallback = { [weak self] swipeUp, swipeDown, snap, pinch in
            guard let self = self else { return }
            // 显示加载提示
            self.showLoading("配置中...")
            self.setGestureFunction(swipeUp: swipeUp, swipeDown: swipeDown, snap: snap, pinch: pinch)
        }

        // 使用QMUIModalPresentationViewController显示对话框
        let modalVC = QMUIModalPresentationViewController()
        modalVC.isModal = true
        modalVC.contentView = dialogView
        modalVC.contentViewMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        modalVC.showWith(animated: true)
    }

    /// 129 - 手势功能开启(Z4I定制)
    private func setGestureFunction(swipeUp: Int, swipeDown: Int, snap: Int, pinch: Int) {
        // 调用SDK接口设置手势功能
        BCLRingManager.shared.setGestureFunction(swipeUpGesture: swipeUp, swipeDownGesture: swipeDown, snapGesture: snap, pinchGesture: pinch) { result in
            self.hideLoading()
            switch result {
            case let .success(response):
                BDLogger.info("设置手势功能成功: \(response)")
                BDLogger.info("上滑手势: \(swipeUp), 下滑手势: \(swipeDown), 打响指: \(snap), 捏一捏: \(pinch)")
                //  关闭手势功能
                if swipeUp == 255 && swipeDown == 255 && snap == 255 && pinch == 255 {
                    self.showInfoAlert(title: "关闭HID服务", message: "请前往系统蓝牙设置中取消设备配对")
                } else { // 开启手势的时候
                    self.showSuccess("手势功能已开启")
                }
            case let .failure(error):
                BDLogger.error("设置手势功能失败: \(error)")
                self.showError("设置手势功能失败: \(error.localizedDescription)")
            }
        }
    }

    /// 128 - 手势功能配置读取(Z4I定制)
    private func readGestureFunction() {
        showLoading("读取中...")
        BCLRingManager.shared.readGestureFunction { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()

            switch result {
            case let .success(response):
                BDLogger.info("读取手势功能成功: \(response)")
                BDLogger.info("--------------------------------")
                BDLogger.info("上滑手势: \(response.swipeUpGesture ?? 0) - \(self.getGestureFunctionName(response.swipeUpGesture ?? 0))")
                BDLogger.info("下滑手势: \(response.swipeDownGesture ?? 0) - \(self.getGestureFunctionName(response.swipeDownGesture ?? 0))")
                BDLogger.info("打响指手势: \(response.snapGesture ?? 0) - \(self.getGestureFunctionName(response.snapGesture ?? 0))")
                BDLogger.info("捏一捏手势: \(response.pinchGesture ?? 0) - \(self.getGestureFunctionName(response.pinchGesture ?? 0))")
                BDLogger.info("--------------------------------")

                let message = """
                上滑: \(self.getGestureFunctionName(response.swipeUpGesture ?? 0))
                下滑: \(self.getGestureFunctionName(response.swipeDownGesture ?? 0))
                打响指: \(self.getGestureFunctionName(response.snapGesture ?? 0))
                捏一捏: \(self.getGestureFunctionName(response.pinchGesture ?? 0))
                """
                self.showInfoAlert(title: "手势功能配置", message: message)

            case let .failure(error):
                BDLogger.error("读取手势功能失败: \(error)")
                self.showError("读取手势功能失败: \(error.localizedDescription)")
            }
        }
    }

    /// 131 - 刷新蓝牙服务相关信息(Z4I定制)
    private func rediscoverBluetoothServices() {
        showLoading("刷新服务中...")
        BCLRingManager.shared.rediscoverServices(
            completion: { [weak self] result in
                // 立即回调：服务发现流程已触发
                switch result {
                case let .success(isTriggered):
                    BDLogger.info("蓝牙服务发现已触发: \(isTriggered)")
                case let .failure(error):
                    BDLogger.error("触发蓝牙服务发现失败: \(error)")
                    self?.hideLoading()
                    self?.showError("触发服务发现失败: \(error.localizedDescription)")
                }
            },
            serviceProcessingCompletion: { [weak self] result in
                // 服务处理完成后的回调
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case let .success(isCompleted):
                    BDLogger.info("蓝牙服务处理完成: \(isCompleted)")
                    BDLogger.info("所有服务和特征值已重新发现并处理完成")
                    self.showSuccess("蓝牙服务刷新完成")
                // 可以进行蓝牙通讯了
                case let .failure(error):
                    BDLogger.error("蓝牙服务处理失败: \(error)")
                    self.showError("服务处理失败: \(error.localizedDescription)")
                }
            }
        )
    }

    /// 127 - 手动临时断开连接(Z4I定制)
    private func manualDisconnect() {
        // 开启手势功能，断开当前蓝牙连接，进行重连触发配对
        BCLRingManager.shared.isAutoReconnectEnabled = true
        /// 手动临时断开连接避免系统蓝牙缓存问题导致通信失败问题，会触发重连操作，从而进行配对
        BCLRingManager.shared.disconnect(peripheral: BCLRingManager.shared.currentConnectedDevice?.peripheral)
    }

    /// 126 - 切换HID服务订阅状态(Z4I定制)
    private func toggleHIDServiceSubscription() {
        let currentBlock = BCLRingManager.shared.gesturePairingPushBlock

        if currentBlock == nil {
            // 当前未订阅，开启订阅
            BCLRingManager.shared.gesturePairingPushBlock = { [weak self] response in
                guard let self = self else { return }
                BDLogger.info("收到HID配对推送: \(response)")
                BDLogger.info("配对状态: \(response.pairingStatus)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.rediscoverBluetoothServices()
                }
                // 配对状态处理
                if response.pairingStatus {
                    // 开启手势的话需要刷新服务，才可以继续蓝牙通信，否则会报错蓝牙通讯连接加密失效
                } else {
                    self.showInfoAlert(title: "关闭HID服务", message: "请前往系统蓝牙设置中取消设备配对")
                }
            }
            BDLogger.info("HID服务订阅已开启")
            showSuccess("HID服务订阅已开启")
        } else {
            // 当前已订阅，关闭订阅
            BCLRingManager.shared.gesturePairingPushBlock = nil
            BDLogger.info("HID服务订阅已关闭")
            showSuccess("HID服务订阅已关闭")
        }

        // 通知UI刷新标题
        NotificationCenter.default.post(name: NSNotification.Name("RefreshFunctionList"), object: nil)
    }

    // MARK: - Helper Methods

    /// 根据手势功能码获取功能名称
    private func getGestureFunctionName(_ code: Int) -> String {
        switch code {
        case 1:
            return "音乐暂停/开始"
        case 2:
            return "音乐下一首"
        case 3:
            return "音乐上一首"
        case 4:
            return "音量+"
        case 5:
            return "音量-"
        case 6:
            return "拍照"
        case 255:
            return "关闭"
        default:
            return "未知(\(code))"
        }
    }
}
