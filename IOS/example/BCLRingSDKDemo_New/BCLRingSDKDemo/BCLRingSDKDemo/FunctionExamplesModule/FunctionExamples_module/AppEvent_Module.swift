//
//  AppEvent_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  App复合指令功能模块 (21-30)
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 将可选能力位转换为便于客户 App 展示的语义；nil 表示旧固件未返回该字段。
private func abnormalLogSupportDescription(_ isSupported: Bool?) -> String {
    guard let isSupported else { return "未知" }
    return isSupported ? "支持" : "不支持"
}

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
            showAppEventConfigDialog(commandType: .bind)
        case 22:
            showAppEventConfigDialog(commandType: .connect)
        case 23:
            showAppEventConfigDialog(commandType: .refresh)
        case 24:
            readCompositeInformation()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 24 - 读取录音、触摸键、存储模式和充电停一切复合配置信息
    private func readCompositeInformation() {
        showLoading("读取中...")
        BCLRingManager.shared.readCompositeInformation { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case let .success(response):
                    let touchKeys = response.enabledTouchKeys
                        .map { String(format: "0x%02X", $0.rawValue) }
                        .joined(separator: "、")
                    let storageMode: String
                    switch response.recordingStorageMode {
                    case .loopOverwrite?: storageMode = "循环覆盖"
                    case .stopWhenFull?: storageMode = "录满停止"
                    case nil: storageMode = String(format: "未知(0x%02X)", response.recordingStorageModeRawValue)
                    }
                    // 旧固件不返回Data[26]时必须显示未知，不能将nil当作禁止。
                    // 此处展示的是设备配置使能状态，并非当前充电或功能停止状态。
                    let chargingState: String
                    switch response.isStopAllWhileChargingEnabled {
                    case true?: chargingState = "使能"
                    case false?: chargingState = "禁止"
                    case nil: chargingState = "未知（设备未返回）"
                    }
                    let chargingRawValue = response.stopAllWhileChargingStatus.map { String($0) } ?? "nil（设备未返回）"
                    BDLogger.info("充电停一切开关原始值(Data[26]，1使能、0禁止)：\(chargingRawValue)")
                    let startTime = self.beijingTimeDescription(response.automaticRecordingDisabledStartTime)
                    let endTime = self.beijingTimeDescription(response.automaticRecordingDisabledEndTime)
                    let crossesMidnight = response.automaticRecordingDisabledStartTime > response.automaticRecordingDisabledEndTime
                    let message = "定时录音：\(response.isTimedRecordingEnabled ? "开启" : "关闭")\n间隔：\(response.timedRecordingInterval)秒\n录音时长：\(response.timedRecordingDuration)秒\n关闭时段：\(response.isAutomaticRecordingDisabledPeriodEnabled ? "开启" : "关闭")\n开始时间：\(startTime)（北京时间）\n结束时间：\(endTime)（北京时间）\n跨越零点：\(crossesMidnight ? "是" : "否")\n触摸键掩码：0x\(String(format: "%02X", response.enabledTouchKeyMask))\n已知触摸键：\(touchKeys.isEmpty ? "无" : touchKeys)\n单次录音时长：\(response.singleRecordingDuration)秒\n存储模式：\(storageMode)\n充电停一切：\(chargingState)"
                    BDLogger.info("读取复合配置信息成功：\(message.replacingOccurrences(of: "\n", with: "，"))")
                    self.showInfoAlert(title: "复合配置信息", message: message)
                case let .failure(error):
                    BDLogger.error("读取复合配置信息失败：\(error)")
                    self.showError("读取复合配置信息失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 将北京时间当天秒数格式化为HH:mm:ss。
    private func beijingTimeDescription(_ seconds: UInt32) -> String {
        let hour = seconds / 3_600
        let minute = seconds % 3_600 / 60
        let second = seconds % 60
        return String(format: "%02u:%02u:%02u", hour, minute, second)
    }

    /// App复合指令参数配置弹窗
    private func showAppEventConfigDialog(commandType: AppEventConfig_Dialog.CommandType) {
        let height: CGFloat = commandType.supportsFilterTime ? 470 : 350
        let contentView = AppEventConfig_Dialog(x: 0, y: 0, width: 320, height: height, commandType: commandType)
        contentView.confirmButtonCallback = { [weak self] date, timeZone, filterTime in
            switch commandType {
            case .bind:
                self?.appEventBindRing(date: date, timeZone: timeZone)
            case .connect:
                self?.appEventConnectRing(date: date, timeZone: timeZone, filterTime: filterTime)
            case .refresh:
                self?.appEventRefreshRing(date: date, timeZone: timeZone, filterTime: filterTime)
            }
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    /// 21 - App复合指令-绑定戒指(所谓复合指令即将时间同步、版本信息获取、电量信息获取、采集间隔获取、历史数据同步等多个功能集合在一个指令中执行)
    private func appEventBindRing(date: Date, timeZone: BCLRingTimeZone) {
        // 该指令适用于用户首次绑定戒指时使用，提交当前时间和时区信息，以确保戒指与APP的时间同步，同时获取戒指的基本信息和功能支持情况。
        // 注意：该指令执行时，戒指内部会根据情况清除历史数据。适用场景如：用户首次使用App绑定戒指，或用户更换新的戒指时使用。避免戒指初始状态下存在旧数据影响使用体验。

        // 此处提交当前时间和时区信息，以确保戒指与APP的时间同步,功能同时间同步接口一致
        BDLogger.info("APP事件-绑定戒指-同步时间: \(date), 时区: \(timeZone.rawValue)")
        BCLRingManager.shared.appEventBindRing(date: date, timeZone: timeZone) { res in
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
                BDLogger.info("PPG血压曲线测量支持:\(response.isBloodPressureCurveSupported) ")
                BDLogger.info("文件支持:\(response.isFileSystemSupported) ")
                BDLogger.info("GoMore睡眠算法支持: \(response.isGoMoreSleepAlgorithmSupported)")
                BDLogger.info("GoMore用户年龄: \(String(describing: response.gomoreUserAge))")
                BDLogger.info("GoMore用户性别: \(String(describing: response.gomoreUserGender))")
                BDLogger.info("GoMore用户身高: \(String(describing: response.gomoreUserHeight))")
                BDLogger.info("GoMore用户体重: \(String(describing: response.gomoreUserWeight))")
                BDLogger.info("GoMore最大心率: \(String(describing: response.gomoreMaxHeartRate))")
                BDLogger.info("GoMore常态心率: \(String(describing: response.gomoreRestingHeartRate))")
                BDLogger.info("GoMore最大摄氧量: \(String(describing: response.gomoreMaxOxygenUptake))")
                BDLogger.info("GoMore授权状态值(0已授权,1未授权): \(String(describing: response.gomoreAuthorizationStatus))")
                BDLogger.info("GoMore是否已授权: \(String(describing: response.isGoMoreAuthorized))")
                BDLogger.info("HID服务开启状态值(iOS定制,1开启,0关闭): \(String(describing: response.hidServiceEnabledStatus))")
                BDLogger.info("HID服务是否开启(iOS定制): \(String(describing: response.isHIDServiceEnabled))")
                BDLogger.info("异常日志读取支持状态值(1支持,0不支持): \(String(describing: response.abnormalLogSupportedStatus))")
                BDLogger.info("异常日志读取能力: \(abnormalLogSupportDescription(response.isAbnormalLogSupported))")
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
    private func appEventConnectRing(date: Date, timeZone: BCLRingTimeZone, filterTime: Date?) {
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
        // 此处注意该过滤时间参数目前仅部分固件支持
        BDLogger.info("APP事件-连接戒指-同步时间: \(date), 时区: \(timeZone.rawValue)")
        BDLogger.info("APP事件-连接戒指-过滤时间: \(String(describing: filterTime))")
        BCLRingManager.shared.appEventConnectRing(date: date, timeZone: timeZone, filterTime: filterTime, callbacks: callbacks) { res in
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
                BDLogger.info("PPG血压曲线测量支持:\(response.isBloodPressureCurveSupported) ")
                BDLogger.info("文件支持:\(response.isFileSystemSupported) ")
                BDLogger.info("GoMore睡眠算法支持: \(response.isGoMoreSleepAlgorithmSupported)")
                BDLogger.info("GoMore用户年龄: \(String(describing: response.gomoreUserAge))")
                BDLogger.info("GoMore用户性别: \(String(describing: response.gomoreUserGender))")
                BDLogger.info("GoMore用户身高: \(String(describing: response.gomoreUserHeight))")
                BDLogger.info("GoMore用户体重: \(String(describing: response.gomoreUserWeight))")
                BDLogger.info("GoMore最大心率: \(String(describing: response.gomoreMaxHeartRate))")
                BDLogger.info("GoMore常态心率: \(String(describing: response.gomoreRestingHeartRate))")
                BDLogger.info("GoMore最大摄氧量: \(String(describing: response.gomoreMaxOxygenUptake))")
                BDLogger.info("GoMore授权状态值(0已授权,1未授权): \(String(describing: response.gomoreAuthorizationStatus))")
                BDLogger.info("GoMore是否已授权: \(String(describing: response.isGoMoreAuthorized))")
                BDLogger.info("HID服务开启状态值(iOS定制,1开启,0关闭): \(String(describing: response.hidServiceEnabledStatus))")
                BDLogger.info("HID服务是否开启(iOS定制): \(String(describing: response.isHIDServiceEnabled))")
                BDLogger.info("异常日志读取支持状态值(1支持,0不支持): \(String(describing: response.abnormalLogSupportedStatus))")
                BDLogger.info("异常日志读取能力: \(abnormalLogSupportDescription(response.isAbnormalLogSupported))")
            case let .failure(error):
                BDLogger.error("连接戒指指令执行-失败: \(error)")
            }
        }
    }

    /// 23 - App复合指令-刷新戒指(所谓复合指令即将时间同步、版本信息获取、电量信息获取、采集间隔获取、历史数据同步等多个功能集合在一个指令中执行)
    private func appEventRefreshRing(date: Date, timeZone: BCLRingTimeZone, filterTime: Date?) {
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
        // 此处注意该过滤时间参数目前仅部分固件支持
        BDLogger.info("APP事件-刷新戒指-同步时间: \(date), 时区: \(timeZone.rawValue)")
        BDLogger.info("APP事件-刷新戒指-过滤时间: \(String(describing: filterTime))")
        BCLRingManager.shared.appEventRefreshRing(date: date, timeZone: timeZone, filterTime: filterTime, callbacks: callbacks) { res in
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
                BDLogger.info("PPG血压曲线测量支持:\(response.isBloodPressureCurveSupported) ")
                BDLogger.info("文件支持:\(response.isFileSystemSupported) ")
                BDLogger.info("GoMore睡眠算法支持: \(response.isGoMoreSleepAlgorithmSupported)")
                BDLogger.info("GoMore用户年龄: \(String(describing: response.gomoreUserAge))")
                BDLogger.info("GoMore用户性别: \(String(describing: response.gomoreUserGender))")
                BDLogger.info("GoMore用户身高: \(String(describing: response.gomoreUserHeight))")
                BDLogger.info("GoMore用户体重: \(String(describing: response.gomoreUserWeight))")
                BDLogger.info("GoMore最大心率: \(String(describing: response.gomoreMaxHeartRate))")
                BDLogger.info("GoMore常态心率: \(String(describing: response.gomoreRestingHeartRate))")
                BDLogger.info("GoMore最大摄氧量: \(String(describing: response.gomoreMaxOxygenUptake))")
                BDLogger.info("GoMore授权状态值(0已授权,1未授权): \(String(describing: response.gomoreAuthorizationStatus))")
                BDLogger.info("GoMore是否已授权: \(String(describing: response.isGoMoreAuthorized))")
                BDLogger.info("HID服务开启状态值(iOS定制,1开启,0关闭): \(String(describing: response.hidServiceEnabledStatus))")
                BDLogger.info("HID服务是否开启(iOS定制): \(String(describing: response.isHIDServiceEnabled))")
                BDLogger.info("异常日志读取支持状态值(1支持,0不支持): \(String(describing: response.abnormalLogSupportedStatus))")
                BDLogger.info("异常日志读取能力: \(abnormalLogSupportDescription(response.isAbnormalLogSupported))")
            case let .failure(error):
                BDLogger.error("刷新戒指指令执行-失败: \(error)")
            }
        }
    }
}
