//
//  AppEvent_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  App复合指令功能模块 (21-30)
//

import BCLRingSDK
import SwiftDate
import UIKit

/// App复合指令功能模块 - 处理绑定戒指、连接戒指、刷新戒指等APP事件
class AppEvent_Module: BaseFunction_Module {
    // MARK: - Properties

    /// 历史数据缓存
    private var historyData: [BCLRingDBModel] = []

    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 21 ... 30)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 21:
            appEventBindRing()
        case 22:
            appEventConnectRing()
        case 23:
            appEventRefreshRing()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 21 - App复合指令-绑定戒指(所谓复合指令即将时间同步、版本信息获取、电量信息获取、采集间隔获取、历史数据同步等多个功能集合在一个指令中执行)
    private func appEventBindRing() {
        // 该指令适用于用户首次绑定戒指时使用，提交当前时间和时区信息，以确保戒指与APP的时间同步，同时获取戒指的基本信息和功能支持情况。
        // 注意：该指令执行时，戒指内部会根据情况清除历史数据。适用场景如：用户首次使用App绑定戒指，或用户更换新的戒指时使用。避免戒指初始状态下存在旧数据影响使用体验。

        // 此处提交当前时间和时区信息，以确保戒指与APP的时间同步,功能同时间同步接口一致
        BCLRingManager.shared.appEventBindRing(date: Date(), timeZone: BCLRingTimeZone.getCurrentSystemTimeZone()) { res in
            switch res {
            case let .success(response):
                BDLogger.info("绑定戒指成功: \(response)")
                //  此处可根据业务需求，将数据更新到相关UI中
                BDLogger.info("固件版本: \(response.firmwareVersion)")
                BDLogger.info("硬件版本: \(response.hardwareVersion)")
                BDLogger.info("电量: \(response.batteryLevel)")
                BDLogger.info("充电状态: \(response.chargingState)")
                BDLogger.info("采集间隔: \(response.collectInterval)")
                BDLogger.info("计步: \(response.stepCount)")
                //  自检相关信息如果有错误信息，可以根据信息进行一下提醒处理。
                BDLogger.info("自检标志：\(response.selfInspectionFlag)")
                BDLogger.info("自检是否有错误：\(response.hasSelfInspectionError)")
                BDLogger.info("自检错误描述：\(response.selfInspectionErrorDescription)")

                //  可用于检查蓝牙设备是否支持HID相关功能，并根据支持情况启用相应功能
                BDLogger.info("HID功能支持：\(response.isHIDSupported)")
                if response.isHIDSupported {
                    BDLogger.info("HID模式-触摸功能-拍照：\(response.isTouchPhotoSupported)")
                    BDLogger.info("HID模式-触摸功能-短视频模式：\(response.isTouchShortVideoSupported)")
                    BDLogger.info("HID模式-触摸功能-控制音乐：\(response.isTouchMusicControlSupported)")
                    BDLogger.info("HID模式-触摸功能-控制PPT：\(response.isTouchPPTControlSupported)")
                    BDLogger.info("HID模式-触摸功能-控制上传实时音频：\(response.isTouchAudioUploadSupported)")
                    BDLogger.info("HID模式-手势功能-捏一捏手指拍照：\(response.isPinchPhotoSupported)")
                    BDLogger.info("HID模式-手势功能-手势短视频模式：\(response.isGestureShortVideoSupported)")
                    BDLogger.info("HID模式-手势功能-空中手势音乐控制：\(response.isGestureMusicControlSupported)")
                    BDLogger.info("HID模式-手势功能-空中手势PPT模式：\(response.isGesturePPTControlSupported)")
                    BDLogger.info("HID模式-手势功能-打响指拍照模式：\(response.isSnapPhotoSupported)")
                    BDLogger.info("当前HID模式-触摸模式：\(response.touchHIDMode.description)")
                    BDLogger.info("当前HID模式-手势模式：\(response.gestureHIDMode.description)")
                    BDLogger.info("当前HID模式-系统类型：\(response.systemType.description)")
                }

                //  可用于检查心率、血氧等曲线是否支持，并根据支持情况启用相应功能
                BDLogger.info("血氧曲线支持：\(response.isOxygenCurveSupported)")
                BDLogger.info("变异性曲线支持：\(response.isVariabilityCurveSupported)")
                BDLogger.info("压力曲线支持：\(response.isPressureCurveSupported)")
                BDLogger.info("温度曲线支持：\(response.isTemperatureCurveSupported)")
                BDLogger.info("女性健康支持：\(response.isFemaleHealthSupported)")
                BDLogger.info("震动闹钟支持：\(response.isVibrationAlarmSupported)")
                BDLogger.info("心电图功能支持：\(response.isEcgFunctionSupported)")
                BDLogger.info("麦克风支持：\(response.isMicrophoneSupported)")
                BDLogger.info("运动模式支持：\(response.isSportModeSupported)")
                BDLogger.info("血压测量支持：\(response.isBloodPressureMeasurementSupported)")
                BDLogger.info("血糖测量支持:\(response.isBloodGlucoseMeasurementSupported) ")
                BDLogger.info("文件支持:\(response.isFileSystemSupported) ")
                BDLogger.info("GoMore睡眠算法支持: \(response.isGoMoreSleepAlgorithmSupported)")
                BDLogger.info("GoMore用户年龄: \(String(describing: response.gomoreUserAge))")
                BDLogger.info("GoMore用户性别: \(String(describing: response.gomoreUserGender))")
                BDLogger.info("GoMore用户身高: \(String(describing: response.gomoreUserHeight))")
                BDLogger.info("GoMore用户体重: \(String(describing: response.gomoreUserWeight))")
                BDLogger.info("GoMore最大心率: \(String(describing: response.gomoreMaxHeartRate))")
                BDLogger.info("GoMore常态心率: \(String(describing: response.gomoreRestingHeartRate))")
                BDLogger.info("GoMore最大摄氧量: \(String(describing: response.gomoreMaxOxygenUptake))")
            case let .failure(error):
                switch error {
                case let .responseParsing(reason):
                    BDLogger.error("绑定戒指响应解析失败: \(reason.localizedDescription)")
                default:
                    BDLogger.error("绑定戒指指令执行-失败: \(error)")
                }
            }
        }
    }

    /// 22 - App复合指令-连接戒指(所谓复合指令即将时间同步、版本信息获取、电量信息获取、采集间隔获取、历史数据同步等多个功能集合在一个指令中执行)
    private func appEventConnectRing() {
        historyData.removeAll()
        // 该指令适用于App启动后连接戒指成功后使用，提交当前时间和时区信息，以确保戒指与APP的时间同步，功能同时间同步接口一致，同时获取戒指的基本信息和功能支持情况。且戒指会主动将历史数据同步到APP。
        // App在接收到数据后，可以根据业务需求将数据存储到本地数据库或上传到服务器进行进一步处理和分析。

        // 当前指令默认会将戒指内未上传数据全部同步到APP。(后续会根据FilterTime参数，支持只同步某个时间点之后的数据)
        // 创建回调结构体
        let callbacks = BCLDataSyncCallbacks(
            onProgress: { totalNumber, currentIndex, progress, model in
                BDLogger.info("连接戒指-历史数据同步进度：\(currentIndex)/\(totalNumber) (\(progress)%)")
                BDLogger.info("连接戒指-当前数据：\(model.localizedDescription)")
            },
            onStatusChanged: { status in
                BDLogger.info("连接戒指-历史数据同步状态变化：\(status)")
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
                BDLogger.info("连接戒指-历史数据同步完成，共获取 \(models.count) 条记录")
                BDLogger.info("\(models)")
                // 此处数据同步过程中会通过异步方式将数据存储到SDK的本地数据库中，APP可根据业务需求将数据存储到自己的本地数据库或上传到服务器进行进一步处理和分析。
                // 如果使用了云端睡眠算法，此处可调用数据上传接口将数据提交到云端服务，并获取睡眠分析结果进行展示。
                self.historyData.append(contentsOf: models)
            },
            onError: { error in
                BDLogger.error("连接戒指-历史数据同步出错：\(error.localizedDescription)")
            }
        )

        // 设置过滤时间（可选）(如果不需要过滤时间，可以传nil，表示不过滤) (传入时间则只会同步过滤时间之后的数据)
        // 这里设置为2025-01-01 00:00:00，表示只同步该时间之后的数据
        // 此处注意该过滤时间参数目前仅部分固件支持
        let filterTime = "2025-01-01 00:00:00".toDate("yyyy-MM-dd HH:mm:ss", region: BCLRingTimeZone.getCurrentSystemTimeZone().region)?.date
        BDLogger.info("APP事件-连接戒指-过滤时间: \(String(describing: filterTime))")
        BCLRingManager.shared.appEventConnectRing(date: Date(), timeZone: BCLRingTimeZone.getCurrentSystemTimeZone(), filterTime: filterTime, callbacks: callbacks) { res in
            switch res {
            case let .success(response):
                //  此处可根据业务需求，将数据更新到相关UI中
                BDLogger.info("App复合指令-连接指令执行-成功: \(response)")
                BDLogger.info("固件版本: \(response.firmwareVersion)")
                BDLogger.info("硬件版本: \(response.hardwareVersion)")
                BDLogger.info("电量: \(response.batteryLevel)")
                BDLogger.info("充电状态: \(response.chargingState)")
                BDLogger.info("采集间隔: \(response.collectInterval)")
                BDLogger.info("计步: \(response.stepCount)")

                //  自检相关信息如果有错误信息，可以根据信息进行一下提醒处理。
                BDLogger.info("自检标志：\(response.selfInspectionFlag)")
                BDLogger.info("自检是否有错误：\(response.hasSelfInspectionError)")
                BDLogger.info("自检错误描述：\(response.selfInspectionErrorDescription)")

                //  可用于检查蓝牙设备是否支持HID相关功能，并根据支持情况启用相应功能
                BDLogger.info("HID功能支持：\(response.isHIDSupported)")
                if response.isHIDSupported {
                    BDLogger.info("HID模式-触摸功能-拍照：\(response.isTouchPhotoSupported)")
                    BDLogger.info("HID模式-触摸功能-短视频模式：\(response.isTouchShortVideoSupported)")
                    BDLogger.info("HID模式-触摸功能-控制音乐：\(response.isTouchMusicControlSupported)")
                    BDLogger.info("HID模式-触摸功能-控制PPT：\(response.isTouchPPTControlSupported)")
                    BDLogger.info("HID模式-触摸功能-控制上传实时音频：\(response.isTouchAudioUploadSupported)")
                    BDLogger.info("HID模式-手势功能-捏一捏手指拍照：\(response.isPinchPhotoSupported)")
                    BDLogger.info("HID模式-手势功能-手势短视频模式：\(response.isGestureShortVideoSupported)")
                    BDLogger.info("HID模式-手势功能-空中手势音乐控制：\(response.isGestureMusicControlSupported)")
                    BDLogger.info("HID模式-手势功能-空中手势PPT模式：\(response.isGesturePPTControlSupported)")
                    BDLogger.info("HID模式-手势功能-打响指拍照模式：\(response.isSnapPhotoSupported)")
                    BDLogger.info("当前HID模式-触摸模式：\(response.touchHIDMode.description)")
                    BDLogger.info("当前HID模式-手势模式：\(response.gestureHIDMode.description)")
                    BDLogger.info("当前HID模式-系统类型：\(response.systemType.description)")
                }

                //  可用于检查心率、血氧等曲线是否支持，并根据支持情况启用相应功能
                BDLogger.info("心率曲线支持：\(response.isHeartRateCurveSupported)")
                BDLogger.info("血氧曲线支持：\(response.isOxygenCurveSupported)")
                BDLogger.info("变异性曲线支持：\(response.isVariabilityCurveSupported)")
                BDLogger.info("压力曲线支持：\(response.isPressureCurveSupported)")
                BDLogger.info("温度曲线支持：\(response.isTemperatureCurveSupported)")
                BDLogger.info("女性健康支持：\(response.isFemaleHealthSupported)")
                BDLogger.info("震动闹钟支持：\(response.isVibrationAlarmSupported)")
                BDLogger.info("心电图功能支持：\(response.isEcgFunctionSupported)")
                BDLogger.info("麦克风支持：\(response.isMicrophoneSupported)")
                BDLogger.info("运动模式支持：\(response.isSportModeSupported)")
                BDLogger.info("血压测量支持：\(response.isBloodPressureMeasurementSupported)")
                BDLogger.info("血糖测量支持:\(response.isBloodGlucoseMeasurementSupported) ")
                BDLogger.info("文件支持:\(response.isFileSystemSupported) ")
                BDLogger.info("GoMore睡眠算法支持: \(response.isGoMoreSleepAlgorithmSupported)")
                BDLogger.info("GoMore用户年龄: \(String(describing: response.gomoreUserAge))")
                BDLogger.info("GoMore用户性别: \(String(describing: response.gomoreUserGender))")
                BDLogger.info("GoMore用户身高: \(String(describing: response.gomoreUserHeight))")
                BDLogger.info("GoMore用户体重: \(String(describing: response.gomoreUserWeight))")
                BDLogger.info("GoMore最大心率: \(String(describing: response.gomoreMaxHeartRate))")
                BDLogger.info("GoMore常态心率: \(String(describing: response.gomoreRestingHeartRate))")
                BDLogger.info("GoMore最大摄氧量: \(String(describing: response.gomoreMaxOxygenUptake))")
            case let .failure(error):
                BDLogger.error("连接戒指指令执行-失败: \(error)")
            }
        }
    }

    /// 23 - App复合指令-刷新戒指(所谓复合指令即将时间同步、版本信息获取、电量信息获取、采集间隔获取、历史数据同步等多个功能集合在一个指令中执行)
    private func appEventRefreshRing() {
        historyData.removeAll()
        // 该指令适用于需要刷新页面场景，提交当前时间和时区信息，以确保戒指与APP的时间同步，功能同时间同步接口一致，同时获取戒指的基本信息和功能支持情况。且戒指会主动将历史数据同步到APP。
        // App在接收到数据后，可以根据业务需求将数据存储到本地数据库或上传到服务器进行进一步处理和分析。

        // 当前指令默认会将戒指内未上传数据全部同步到APP。(后续会根据FilterTime参数，支持只同步某个时间点之后的数据)
        // 创建回调结构体
        let callbacks = BCLDataSyncCallbacks(
            onProgress: { totalNumber, currentIndex, progress, model in
                BDLogger.info("刷新戒指-历史数据同步进度：\(currentIndex)/\(totalNumber) (\(progress)%)")
                BDLogger.info("刷新戒指-当前数据：\(model.localizedDescription)")
            },
            onStatusChanged: { status in
                BDLogger.info("刷新戒指-历史数据同步状态变化：\(status)")
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
                BDLogger.info("刷新戒指-历史数据同步完成，共获取 \(models.count) 条记录")
                BDLogger.info("\(models)")
                // 此处数据同步过程中会通过异步方式将数据存储到SDK的本地数据库中，APP可根据业务需求将数据存储到自己的本地数据库或上传到服务器进行进一步处理和分析。
                // 如果使用了云端睡眠算法，此处可调用数据上传接口将数据提交到云端服务，并获取睡眠分析结果进行展示。
                self.historyData.append(contentsOf: models)
            },
            onError: { error in
                BDLogger.error("刷新戒指-历史数据同步出错：\(error.localizedDescription)")
            }
        )

        // 设置过滤时间（可选）(如果不需要过滤时间，可以传nil，表示不过滤) (传入时间则只会同步过滤时间之后的数据)
        // 这里设置为2025-01-01 00:00:00，表示只同步该时间之后的数据
        // 此处注意该过滤时间参数目前仅部分固件支持
        let filterTime = "2025-01-01 00:00:00".toDate("yyyy-MM-dd HH:mm:ss", region: BCLRingTimeZone.getCurrentSystemTimeZone().region)?.date
        BDLogger.info("APP事件-刷新戒指-过滤时间: \(String(describing: filterTime))")
        BCLRingManager.shared.appEventRefreshRing(date: Date(), timeZone: BCLRingTimeZone.getCurrentSystemTimeZone(), filterTime: filterTime, callbacks: callbacks) { res in
            switch res {
            case let .success(response):
                BDLogger.info("刷新戒指指令执行-成功: \(response)")

                //  此处可根据业务需求，将数据更新到相关UI中
                BDLogger.info("固件版本: \(response.firmwareVersion)")
                BDLogger.info("硬件版本: \(response.hardwareVersion)")
                BDLogger.info("电量: \(response.batteryLevel)")
                BDLogger.info("充电状态: \(response.chargingState)")
                BDLogger.info("采集间隔: \(response.collectInterval)")
                BDLogger.info("计步: \(response.stepCount)")

                //  自检相关信息如果有错误信息，可以根据信息进行一下提醒处理。
                BDLogger.info("自检标志：\(response.selfInspectionFlag)")
                BDLogger.info("自检是否有错误：\(response.hasSelfInspectionError)")
                BDLogger.info("自检错误描述：\(response.selfInspectionErrorDescription)")

                //  可用于检查蓝牙设备是否支持HID相关功能，并根据支持情况启用相应功能
                BDLogger.info("HID功能支持：\(response.isHIDSupported)")
                if response.isHIDSupported {
                    BDLogger.info("HID模式-触摸功能-拍照：\(response.isTouchPhotoSupported)")
                    BDLogger.info("HID模式-触摸功能-短视频模式：\(response.isTouchShortVideoSupported)")
                    BDLogger.info("HID模式-触摸功能-控制音乐：\(response.isTouchMusicControlSupported)")
                    BDLogger.info("HID模式-触摸功能-控制PPT：\(response.isTouchPPTControlSupported)")
                    BDLogger.info("HID模式-触摸功能-控制上传实时音频：\(response.isTouchAudioUploadSupported)")
                    BDLogger.info("HID模式-手势功能-捏一捏手指拍照：\(response.isPinchPhotoSupported)")
                    BDLogger.info("HID模式-手势功能-手势短视频模式：\(response.isGestureShortVideoSupported)")
                    BDLogger.info("HID模式-手势功能-空中手势音乐控制：\(response.isGestureMusicControlSupported)")
                    BDLogger.info("HID模式-手势功能-空中手势PPT模式：\(response.isGesturePPTControlSupported)")
                    BDLogger.info("HID模式-手势功能-打响指拍照模式：\(response.isSnapPhotoSupported)")
                    BDLogger.info("当前HID模式-触摸模式：\(response.touchHIDMode.description)")
                    BDLogger.info("当前HID模式-手势模式：\(response.gestureHIDMode.description)")
                    BDLogger.info("当前HID模式-系统类型：\(response.systemType.description)")
                }

                //  可用于检查心率、血氧等曲线是否支持，并根据支持情况启用相应功能
                BDLogger.info("心率曲线支持：\(response.isHeartRateCurveSupported)")
                BDLogger.info("血氧曲线支持：\(response.isOxygenCurveSupported)")
                BDLogger.info("变异性曲线支持：\(response.isVariabilityCurveSupported)")
                BDLogger.info("压力曲线支持：\(response.isPressureCurveSupported)")
                BDLogger.info("温度曲线支持：\(response.isTemperatureCurveSupported)")
                BDLogger.info("女性健康支持：\(response.isFemaleHealthSupported)")
                BDLogger.info("震动闹钟支持：\(response.isVibrationAlarmSupported)")
                BDLogger.info("心电图功能支持：\(response.isEcgFunctionSupported)")
                BDLogger.info("麦克风支持：\(response.isMicrophoneSupported)")
                BDLogger.info("运动模式支持：\(response.isSportModeSupported)")
                BDLogger.info("血压测量支持：\(response.isBloodPressureMeasurementSupported)")
                BDLogger.info("血糖测量支持:\(response.isBloodGlucoseMeasurementSupported) ")
                BDLogger.info("文件支持:\(response.isFileSystemSupported) ")
                BDLogger.info("GoMore睡眠算法支持: \(response.isGoMoreSleepAlgorithmSupported)")
                BDLogger.info("GoMore用户年龄: \(String(describing: response.gomoreUserAge))")
                BDLogger.info("GoMore用户性别: \(String(describing: response.gomoreUserGender))")
                BDLogger.info("GoMore用户身高: \(String(describing: response.gomoreUserHeight))")
                BDLogger.info("GoMore用户体重: \(String(describing: response.gomoreUserWeight))")
                BDLogger.info("GoMore最大心率: \(String(describing: response.gomoreMaxHeartRate))")
                BDLogger.info("GoMore常态心率: \(String(describing: response.gomoreRestingHeartRate))")
                BDLogger.info("GoMore最大摄氧量: \(String(describing: response.gomoreMaxOxygenUptake))")
            case let .failure(error):
                BDLogger.error("刷新戒指指令执行-失败: \(error)")
            }
        }
    }
}
