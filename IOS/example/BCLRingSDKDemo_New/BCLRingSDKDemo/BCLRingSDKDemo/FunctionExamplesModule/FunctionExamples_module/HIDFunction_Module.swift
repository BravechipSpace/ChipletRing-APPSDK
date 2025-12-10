//
//  HIDFunction_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  HID功能模块 (121-130)
//

import BCLRingSDK
import UIKit

/// HID功能模块 - 处理HID功能码、HID模式、
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

    /// 123 -
}
