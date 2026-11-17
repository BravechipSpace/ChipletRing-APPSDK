//
//  AudioTransmission_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/27.
//  音频功能功能模块 （361-380，1000，10001-10006）
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 音频功能功能模块 （361-380，1000，10001-10006）- pcm格式、adpcm格式、音频数据获取
class AudioTransmission_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 361 ... 380, extraFunctionIds: [1000, 10001, 10002, 10003, 10004, 10005, 10006])
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 361: // 361 - 开始音频传输-pcm格式
            startAudioTransmissionPCM()
        case 362: // 362 - 停止音频传输-pcm格式
            stopAudioTransmissionPCM()
        case 363: // 363 - 开始音频传输-adpcm格式
            startAudioTransmissionADPCM()
        case 364: // 364 - 停止音频传输-adpcm格式
            stopAudioTransmissionADPCM()
        case 365: // 365 - 配置主动推送音频格式
            showConfigureActiveAudioPushFormatDialog()
        case 366: // 366 - 获取主动推送音频数据
            getActiveAudioPushData()
        case 367: // 367 - 开始录音（Z5J定制）
            startRecording()
        case 368: // 368 - 结束录音（Z5J定制）
            stopRecording()
        case 369: // 369 - 立体双声道解码-adpcm格式
            openStereoAdpcmDecodePage()
        case 370: // 370 - 单声道解码-adpcm格式（Z5J定制）
            openMonoAdpcmDecodePage()
        case 371: // 371 - 开始音频传输-adpcm_1单声道
            startAudioTransmissionADPCM1Mono()
        case 372: // 372 - 停止音频传输-adpcm_1单声道
            stopAudioTransmissionADPCM1Mono()
        case 373: // 373 - 开始音频传输-adpcm_1双声道
            startAudioTransmissionADPCM1Stereo()
        case 374: // 374 - 停止音频传输-adpcm_1双声道
            stopAudioTransmissionADPCM1Stereo()
        case 375: // 375 - HID触摸音频获取、保存与播放
            openHIDTouchAudioPage()
        case 376: // 376 - 获取离线录音状态
            getOfflineRecordingStatus()
        case 377: // 377 - 开启离线录音状态推送监听
            startOfflineRecordingStatusPushListening()
        case 378: // 378 - 取消离线录音状态推送监听
            stopOfflineRecordingStatusPushListening()
        case 379: // 379 - 打开定时录音
            showTimedRecordingDialog()
        case 380: // 380 - 关闭定时录音
            stopTimedRecording()
        case 1000: // 1000 - 读取定时录音配置
            readTimedRecording()
        case 10001: // 10001 - 设置单次录音时长
            showSingleRecordingDurationDialog()
        case 10002: // 10002 - 读取单次录音时长
            readSingleRecordingDuration()
        case 10003: // 10003 - 开启在线录音本地文件ID推送监听
            startOnlineRecordingLocalFileIDPushListening()
        case 10004: // 10004 - 取消在线录音本地文件ID推送监听
            stopOnlineRecordingLocalFileIDPushListening()
        case 10005: // 10005 - 设置自动录音关闭时段
            showAutomaticRecordingDisabledPeriodDialog()
        case 10006: // 10006 - 读取自动录音关闭时段
            readAutomaticRecordingDisabledPeriod()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    /// 10005 - 设置自动录音关闭时段
    ///
    /// 开始和结束时间为北京时间当天的秒数，示例使用HH:mm:ss输入并换算。
    private func showAutomaticRecordingDisabledPeriodDialog() {
        guard let viewController = viewController else { return }
        let alert = UIAlertController(
            title: "设置自动录音关闭时段",
            message: "时间按北京时间当天计算，请输入HH:mm:ss。开始时间晚于结束时间表示跨日，例如22:00:00至07:00:00。",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "使能：1开启，0关闭"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "开始时间，例如22:00:00"
            textField.keyboardType = .numbersAndPunctuation
        }
        alert.addTextField { textField in
            textField.placeholder = "结束时间，例如07:00:00"
            textField.keyboardType = .numbersAndPunctuation
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "设置", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let fields = alert?.textFields,
                  fields.count == 3,
                  let enabledRawValue = UInt8(fields[0].text ?? ""),
                  enabledRawValue == 0 || enabledRawValue == 1,
                  let startTime = self.secondsFromBeijingTime(fields[1].text ?? ""),
                  let endTime = self.secondsFromBeijingTime(fields[2].text ?? "") else {
                self?.showError("请输入有效的使能值及HH:mm:ss时间")
                return
            }
            self.setAutomaticRecordingDisabledPeriod(
                isEnabled: enabledRawValue == 1,
                startTime: startTime,
                endTime: endTime
            )
        })
        viewController.present(alert, animated: true)
    }

    /// 下发自动录音关闭时段配置
    private func setAutomaticRecordingDisabledPeriod(isEnabled: Bool, startTime: UInt32, endTime: UInt32) {
        showLoading("设置中...")
        BCLRingManager.shared.setAutomaticRecordingDisabledPeriod(
            isEnabled: isEnabled,
            startTime: startTime,
            endTime: endTime
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case let .success(response):
                    let startDescription = self.beijingTimeDescription(startTime)
                    let endDescription = self.beijingTimeDescription(endTime)
                    let crossesMidnight = startTime > endTime
                    BDLogger.info("设置自动录音关闭时段：enabled=\(isEnabled)，start=\(startDescription)(\(startTime)秒)，end=\(endDescription)(\(endTime)秒)，crossesMidnight=\(crossesMidnight)，status=\(response.statusRawValue)")
                    response.isSuccess
                        ? self.showSuccess("自动录音关闭时段设置成功")
                        : self.showError("自动录音关闭时段设置失败，设备状态：\(response.statusRawValue)")
                case let .failure(error):
                    BDLogger.error("设置自动录音关闭时段失败：\(error)")
                    self.showError("设置自动录音关闭时段失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 10006 - 读取自动录音关闭时段
    private func readAutomaticRecordingDisabledPeriod() {
        showLoading("读取中...")
        BCLRingManager.shared.readAutomaticRecordingDisabledPeriod { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case let .success(response):
                    let startDescription = self.beijingTimeDescription(response.startTime)
                    let endDescription = self.beijingTimeDescription(response.endTime)
                    let crossesMidnight = response.startTime > response.endTime
                    let message = "状态：\(response.isEnabled ? "开启" : "关闭")\n开始时间：\(startDescription)（\(response.startTime)秒）\n结束时间：\(endDescription)（\(response.endTime)秒）\n跨越零点：\(crossesMidnight ? "是" : "否")\n时基：北京时间"
                    BDLogger.info("读取自动录音关闭时段成功：enabled=\(response.isEnabled)，start=\(startDescription)(\(response.startTime)秒)，end=\(endDescription)(\(response.endTime)秒)，crossesMidnight=\(crossesMidnight)")
                    self.showInfoAlert(title: "自动录音关闭时段", message: message)
                case let .failure(error):
                    BDLogger.error("读取自动录音关闭时段失败：\(error)")
                    self.showError("读取自动录音关闭时段失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 将北京时间HH:mm:ss转换为当天秒数。
    private func secondsFromBeijingTime(_ text: String) -> UInt32? {
        let components = text.split(separator: ":", omittingEmptySubsequences: false)
        guard components.count == 3,
              let hour = UInt32(components[0]), hour < 24,
              let minute = UInt32(components[1]), minute < 60,
              let second = UInt32(components[2]), second < 60 else {
            return nil
        }
        return hour * 3_600 + minute * 60 + second
    }

    /// 将北京时间当天秒数格式化为HH:mm:ss。
    private func beijingTimeDescription(_ seconds: UInt32) -> String {
        let hour = seconds / 3_600
        let minute = seconds % 3_600 / 60
        let second = seconds % 60
        return String(format: "%02u:%02u:%02u", hour, minute, second)
    }

    // 361 - 开始音频传输-pcm格式
    private func startAudioTransmissionPCM() {
        BCLRingManager.shared.controlPCMFormatAudio(isOpen: true) { res in
            switch res {
            case let .success(response):
                BDLogger.info("PCM格式音频传输-音频数据长度: \(response.audioDataLength ?? 0)")
                BDLogger.info("PCM格式音频传输-音频数据序号: \(response.seq ?? 0)")
                BDLogger.info("PCM格式音频传输-音频数据: \(response.audioData)")
                self.showLoading("PCM格式音频传输-\n音频数据长度: \(response.audioDataLength ?? 0)\n音频数据序号: \(response.seq ?? 0)\n音频数据: \(response.audioData)", userInteractionEnabled: false)
            case let .failure(error):
                BDLogger.error("开启PCM格式音频传输失败: \(error)")
                self.showError("开启PCM格式音频传输失败: \(error)")
            }
        }
    }

    // 362 - 停止音频传输-pcm格式
    private func stopAudioTransmissionPCM() {
        BCLRingManager.shared.controlPCMFormatAudio(isOpen: false) { res in
            switch res {
            case .success:
                BDLogger.info("关闭PCM格式音频传输-成功")
                self.hideLoading()
                self.showSuccess("关闭PCM格式音频传输-成功")
            case let .failure(error):
                BDLogger.error("关闭PCM格式音频传输失败: \(error)")
                self.showError("关闭PCM格式音频传输失败: \(error)")
            }
        }
    }

    // 363 - 开始音频传输-adpcm格式
    private func startAudioTransmissionADPCM() {
        BCLRingManager.shared.controlADPCMFormatAudio(mode: .adpcm, isOpen: true) { res in
            switch res {
            case let .success(response):
                BDLogger.info("ADPCM格式音频传输-音频数据长度: \(response.audioDataLength)")
                BDLogger.info("ADPCM格式音频传输-音频数据序号: \(response.seq)")
                BDLogger.info("ADPCM格式音频传输-音频数据: \(response.audioData)")
                self.showLoading("ADPCM格式音频传输-\n音频数据长度: \(response.audioDataLength)\n音频数据序号: \(response.seq)\n音频数据: \(response.audioData)", userInteractionEnabled: false)
            case let .failure(error):
                BDLogger.error("开启ADPCM格式音频传输失败: \(error)")
                self.showError("开启ADPCM格式音频传输失败: \(error)")
            }
        }
    }

    // 364 - 停止音频传输-adpcm格式
    private func stopAudioTransmissionADPCM() {
        BCLRingManager.shared.controlADPCMFormatAudio(mode: .adpcm, isOpen: false) { res in
            switch res {
            case .success:
                BDLogger.info("关闭ADPCM格式音频传输-成功")
                self.hideLoading()
                self.showSuccess("关闭ADPCM格式音频传输-成功")
            case let .failure(error):
                BDLogger.error("关闭ADPCM格式音频传输-失败: \(error)")
                self.showError("关闭ADPCM格式音频传输-失败: \(error)")
            }
        }
    }

    // 371 - 开始音频传输-adpcm_1单声道
    private func startAudioTransmissionADPCM1Mono() {
        BCLRingManager.shared.controlADPCMFormatAudio(mode: .adpcm1Mono, isOpen: true) { res in
            switch res {
            case let .success(response):
                BDLogger.info("ADPCM_1单声道音频传输-音频数据长度: \(response.audioDataLength)")
                BDLogger.info("ADPCM_1单声道音频传输-音频数据序号: \(response.seq)")
                BDLogger.info("ADPCM_1单声道音频传输-音频数据: \(response.audioData)")
                self.showLoading("ADPCM_1单声道音频传输-\n音频数据长度: \(response.audioDataLength)\n音频数据序号: \(response.seq)\n音频数据: \(response.audioData)", userInteractionEnabled: false)
            case let .failure(error):
                BDLogger.error("开启ADPCM_1单声道音频传输失败: \(error)")
                self.showError("开启ADPCM_1单声道音频传输失败: \(error)")
            }
        }
    }

    // 372 - 停止音频传输-adpcm_1单声道
    private func stopAudioTransmissionADPCM1Mono() {
        BCLRingManager.shared.controlADPCMFormatAudio(mode: .adpcm1Mono, isOpen: false) { res in
            switch res {
            case .success:
                BDLogger.info("关闭ADPCM_1单声道音频传输-成功")
                self.hideLoading()
                self.showSuccess("关闭ADPCM_1单声道音频传输-成功")
            case let .failure(error):
                BDLogger.error("关闭ADPCM_1单声道音频传输-失败: \(error)")
                self.showError("关闭ADPCM_1单声道音频传输-失败: \(error)")
            }
        }
    }

    // 373 - 开始音频传输-adpcm_1双声道
    private func startAudioTransmissionADPCM1Stereo() {
        BCLRingManager.shared.controlADPCMFormatAudio(mode: .adpcm1Stereo, isOpen: true) { res in
            switch res {
            case let .success(response):
                BDLogger.info("ADPCM_1双声道音频传输-音频数据长度: \(response.audioDataLength)")
                BDLogger.info("ADPCM_1双声道音频传输-音频数据序号: \(response.seq)")
                BDLogger.info("ADPCM_1双声道音频传输-音频数据: \(response.audioData)")
                self.showLoading("ADPCM_1双声道音频传输-\n音频数据长度: \(response.audioDataLength)\n音频数据序号: \(response.seq)\n音频数据: \(response.audioData)", userInteractionEnabled: false)
            case let .failure(error):
                BDLogger.error("开启ADPCM_1双声道音频传输失败: \(error)")
                self.showError("开启ADPCM_1双声道音频传输失败: \(error)")
            }
        }
    }

    // 374 - 停止音频传输-adpcm_1双声道
    private func stopAudioTransmissionADPCM1Stereo() {
        BCLRingManager.shared.controlADPCMFormatAudio(mode: .adpcm1Stereo, isOpen: false) { res in
            switch res {
            case .success:
                BDLogger.info("关闭ADPCM_1双声道音频传输-成功")
                self.hideLoading()
                self.showSuccess("关闭ADPCM_1双声道音频传输-成功")
            case let .failure(error):
                BDLogger.error("关闭ADPCM_1双声道音频传输-失败: \(error)")
                self.showError("关闭ADPCM_1双声道音频传输-失败: \(error)")
            }
        }
    }

    // 配置主动推送音频格式参数配置弹窗
    private func showConfigureActiveAudioPushFormatDialog() {
        let contentView = AudioFormatConfig_Dialog(x: 15, y: UIScreen.main.bounds.height / 2 - 125, width: UIScreen.main.bounds.width - 30, height: 250)
        contentView.confirmButtonCallback = { [weak self] audioType in
            self?.configureActiveAudioPushFormat(audioType: audioType)
        }
        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    // 365 - 配置主动推送音频格式
    private func configureActiveAudioPushFormat(audioType: BCLAudioType) {
        BCLRingManager.shared.setActivePushAudioInfo(audioType: audioType) { res in
            switch res {
            case let .success(response):
                if response.status == 0 {
                    if audioType == .pcm {
                        BDLogger.info("主动推送音频信息已开启，格式为PCM")
                        self.showSuccess("主动推送音频信息已开启，格式为-PCM")
                    } else {
                        BDLogger.info("主动推送音频信息已开启，格式为ADPCM")
                        self.showSuccess("主动推送音频信息已开启，格式为-ADPCM")
                    }
                } else {
                    BDLogger.info("主动推送音频信息设置失败")
                    self.showError("主动推送音频信息设置失败")
                }
            case let .failure(error):
                BDLogger.error("设置主动推送音频信息失败: \(error)")
                self.showError("设置主动推送音频信息失败: \(error)")
            }
        }
    }

    // 366 - 获取主动推送音频数据
    private func getActiveAudioPushData() {
        BCLRingManager.shared.getActivePushAudioInfo { res in
            switch res {
            case let .success(response):
                if response.audioType == .pcm {
                    BDLogger.info("主动推送音频信息已开启，格式为PCM")
                    self.showSuccess("主动推送音频信息已开启，格式为-PCM")
                } else if response.audioType == .adpcm {
                    BDLogger.info("主动推送音频信息已开启，格式为ADPCM")
                    self.showSuccess("主动推送音频信息已开启，格式为-ADPCM")
                }
            case let .failure(error):
                BDLogger.error("获取主动推送音频信息失败: \(error)")
                self.showError("获取主动推送音频信息失败: \(error)")
            }
        }
    }

    // 367 - 开始录音（Z5J定制）
    private func startRecording() {
        BCLRingManager.shared.ringStartRecording(isOpen: true, totalDuration: 1200, sliceDuration: 600) { result in
            switch result {
            case .success:
                BDLogger.info("开始录音成功")
                self.showSuccess("开始录音成功")
            case let .failure(error):
                BDLogger.error("开始录音失败: \(error)")
                self.showError("开始录音失败: \(error)")
            }
        }
    }

    // 368 - 结束录音（Z5J定制）
    private func stopRecording() {
        BCLRingManager.shared.ringStartRecording(isOpen: false, totalDuration: 0, sliceDuration: 0) { result in
            switch result {
            case .success:
                BDLogger.info("结束录音成功")
                self.showSuccess("结束录音成功")
            case let .failure(error):
                BDLogger.error("结束录音失败: \(error)")
                self.showError("结束录音失败: \(error)")
            }
        }
    }

    // 369 - 立体双声道解码-adpcm格式
    private func openStereoAdpcmDecodePage() {
        guard let vc = viewController else {
            BDLogger.error("当前ViewController为空")
            return
        }
        let stereoAdpcmDecodeVC = StereoAdpcmDecode_VC()
        vc.navigationController?.pushViewController(stereoAdpcmDecodeVC, animated: true)
    }

    // 370 - 单声道解码-adpcm格式
    private func openMonoAdpcmDecodePage() {
        guard let vc = viewController else {
            BDLogger.error("当前ViewController为空")
            return
        }
        let monoAdpcmDecodeVC = VoiceRecord_VC()
        vc.navigationController?.pushViewController(monoAdpcmDecodeVC, animated: true)
    }

    // 375 - HID触摸音频获取、保存与播放
    // 与单声道解码示例复用页面，但提供语义明确的入口，便于开发者直接找到完整链路示例。
    private func openHIDTouchAudioPage() {
        guard let vc = viewController else {
            BDLogger.error("当前ViewController为空")
            return
        }
        let hidTouchAudioVC = VoiceRecord_VC()
        vc.navigationController?.pushViewController(hidTouchAudioVC, animated: true)
    }

    // 376 - 获取离线录音状态
    private func getOfflineRecordingStatus() {
        BCLRingManager.shared.getOfflineRecordingStatus { result in
            switch result {
            case let .success(response):
                guard let status = response.status else {
                    BDLogger.error("获取离线录音状态失败: 响应状态为空")
                    self.showError("获取离线录音状态失败: 响应状态为空")
                    return
                }
                let statusDescription = self.offlineRecordingStatusDescription(status)
                BDLogger.info("当前离线录音状态: \(statusDescription)")
                self.showSuccess("当前离线录音状态: \(statusDescription)")
            case let .failure(error):
                BDLogger.error("获取离线录音状态失败: \(error)")
                self.showError("获取离线录音状态失败: \(error)")
            }
        }
    }

    // 377 - 开启离线录音状态推送监听
    private func startOfflineRecordingStatusPushListening() {
        BCLRingManager.shared.offlineRecordingStatusPushBlock = { [weak self] response in
            guard let self = self, let status = response.status else {
                return
            }
            let statusDescription = self.offlineRecordingStatusDescription(status)
            BDLogger.info("固件主动推送离线录音状态: \(statusDescription)")
            self.showSuccess("固件主动推送离线录音状态: \(statusDescription)")
        }
        BDLogger.info("已开启离线录音状态推送监听")
        showSuccess("已开启离线录音状态推送监听")
    }

    // 378 - 取消离线录音状态推送监听
    private func stopOfflineRecordingStatusPushListening() {
        BCLRingManager.shared.offlineRecordingStatusPushBlock = nil
        BDLogger.info("已取消离线录音状态推送监听")
        showSuccess("已取消离线录音状态推送监听")
    }

    // 379 - 打开定时录音
    private func showTimedRecordingDialog() {
        let alert = UIAlertController(title: "打开定时录音",
                                      message: "请输入间隔时间和录音时间（单位：秒）",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "间隔时间（秒）"
            textField.keyboardType = .numberPad
            textField.text = "60"
        }
        alert.addTextField { textField in
            textField.placeholder = "录音时间（秒）"
            textField.keyboardType = .numberPad
            textField.text = "10"
        }
        let confirmAction = UIAlertAction(title: "打开", style: .default) { _ in
            guard let intervalText = alert.textFields?[0].text,
                  let durationText = alert.textFields?[1].text,
                  let interval = UInt32(intervalText),
                  let duration = UInt32(durationText) else {
                self.showError("请输入有效的间隔时间和录音时间")
                return
            }
            self.startTimedRecording(interval: interval, duration: duration)
        }
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    /// 开启定时录音
    private func startTimedRecording(interval: UInt32, duration: UInt32) {
        BCLRingManager.shared.timedRecording(isOpen: true, interval: interval, duration: duration) { result in
            self.handleTimedRecordingResult(result, operation: "打开", interval: interval, duration: duration)
        }
    }

    // 380 - 关闭定时录音
    private func stopTimedRecording() {
        BCLRingManager.shared.timedRecording(isOpen: false, interval: 0, duration: 0) { result in
            self.handleTimedRecordingResult(result, operation: "关闭", interval: 0, duration: 0)
        }
    }

    // 1000 - 读取定时录音配置
    private func readTimedRecording() {
        BCLRingManager.shared.readTimedRecording { result in
            switch result {
            case let .success(response):
                guard response.parseSuccess else {
                    BDLogger.error("读取定时录音配置失败: 响应解析失败")
                    self.showError("读取定时录音配置失败: 响应解析失败")
                    return
                }

                let statusDescription = response.isOpen ? "打开" : "关闭"
                BDLogger.info("定时录音配置-状态: \(statusDescription)")
                BDLogger.info("定时录音配置-间隔时间: \(response.interval)秒")
                BDLogger.info("定时录音配置-录音时间: \(response.duration)秒")
                self.showSuccess("定时录音配置\n状态: \(statusDescription)\n间隔时间: \(response.interval)秒\n录音时间: \(response.duration)秒")
            case let .failure(error):
                BDLogger.error("读取定时录音配置失败: \(error)")
                self.showError("读取定时录音配置失败: \(error)")
            }
        }
    }

    // 10001 - 设置单次录音时长
    private func showSingleRecordingDurationDialog() {
        let alert = UIAlertController(title: "设置单次录音时长",
                                      message: "请输入单次录音时长（单位：秒），0表示关闭该功能",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "单次录音时长（秒）"
            textField.keyboardType = .numberPad
            textField.text = "60"
        }
        let confirmAction = UIAlertAction(title: "设置", style: .default) { _ in
            guard let durationText = alert.textFields?.first?.text,
                  let duration = UInt32(durationText) else {
                self.showError("请输入有效的单次录音时长")
                return
            }
            self.setSingleRecordingDuration(duration: duration)
        }
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    /// 设置单次录音时长
    private func setSingleRecordingDuration(duration: UInt32) {
        BCLRingManager.shared.setSingleRecordingDuration(duration: duration) { result in
            switch result {
            case let .success(response):
                if response.status == 1 {
                    if duration == 0 {
                        BDLogger.info("关闭单次录音时长功能成功")
                        self.showSuccess("关闭单次录音时长功能成功")
                    } else {
                        BDLogger.info("设置单次录音时长成功: \(duration)秒")
                        self.showSuccess("设置单次录音时长成功\n时长: \(duration)秒")
                    }
                } else {
                    BDLogger.error("设置单次录音时长失败")
                    self.showError("设置单次录音时长失败")
                }
            case let .failure(error):
                BDLogger.error("设置单次录音时长失败: \(error)")
                self.showError("设置单次录音时长失败: \(error)")
            }
        }
    }

    // 10002 - 读取单次录音时长
    private func readSingleRecordingDuration() {
        BCLRingManager.shared.readSingleRecordingDuration { result in
            switch result {
            case let .success(response):
                guard response.parseSuccess else {
                    BDLogger.error("读取单次录音时长失败: 响应解析失败")
                    self.showError("读取单次录音时长失败: 响应解析失败")
                    return
                }

                if response.duration == 0 {
                    BDLogger.info("单次录音时长功能已关闭")
                    self.showSuccess("单次录音时长功能已关闭")
                } else {
                    BDLogger.info("单次录音时长: \(response.duration)秒")
                    self.showSuccess("单次录音时长\n时长: \(response.duration)秒")
                }
            case let .failure(error):
                BDLogger.error("读取单次录音时长失败: \(error)")
                self.showError("读取单次录音时长失败: \(error)")
            }
        }
    }

    // 10003 - 开启在线录音本地文件ID推送监听
    private func startOnlineRecordingLocalFileIDPushListening() {
        BCLRingManager.shared.onlineRecordingLocalFileIDPushBlock = { [weak self] response in
            guard let self = self, let localFileID = response.localFileID else {
                return
            }
            BDLogger.info("固件主动推送在线录音本地文件ID: \(localFileID)")
            DispatchQueue.main.async {
                self.showSuccess("固件主动推送在线录音本地文件ID: \(localFileID)")
            }
        }
        BDLogger.info("已开启在线录音本地文件ID推送监听，请通过现有在线录音流程触发推送")
        showSuccess("已开启在线录音本地文件ID推送监听\n请通过现有在线录音流程触发推送")
    }

    // 10004 - 取消在线录音本地文件ID推送监听
    private func stopOnlineRecordingLocalFileIDPushListening() {
        BCLRingManager.shared.onlineRecordingLocalFileIDPushBlock = nil
        BDLogger.info("已取消在线录音本地文件ID推送监听")
        showSuccess("已取消在线录音本地文件ID推送监听")
    }

    /// 处理定时录音结果
    private func handleTimedRecordingResult(_ result: Result<BCLTimedRecordingResponse, BCLError>,
                                            operation: String,
                                            interval: UInt32,
                                            duration: UInt32) {
        switch result {
        case let .success(response):
            if response.status == 1 {
                if operation == "打开" {
                    BDLogger.info("打开定时录音成功，间隔时间: \(interval)秒，录音时间: \(duration)秒")
                    showSuccess("打开定时录音成功\n间隔时间: \(interval)秒\n录音时间: \(duration)秒")
                } else {
                    BDLogger.info("关闭定时录音成功")
                    showSuccess("关闭定时录音成功")
                }
            } else {
                BDLogger.error("\(operation)定时录音失败")
                showError("\(operation)定时录音失败")
            }
        case let .failure(error):
            BDLogger.error("\(operation)定时录音失败: \(error)")
            showError("\(operation)定时录音失败: \(error)")
        }
    }

    /// 获取离线录音状态描述
    private func offlineRecordingStatusDescription(_ status: BCLOfflineRecordingStatus) -> String {
        switch status {
        case .idle:
            return "空闲"
        case .recording:
            return "录音"
        }
    }
}
