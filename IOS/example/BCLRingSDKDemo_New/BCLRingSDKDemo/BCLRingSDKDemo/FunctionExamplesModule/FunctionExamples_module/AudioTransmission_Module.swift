//
//  AudioTransmission_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/27.
//  音频功能功能模块 （361-380）
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 音频功能功能模块 （361-380）- pcm格式、adpcm格式、音频数据获取
class AudioTransmission_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 361 ... 380)
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
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

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
        BCLRingManager.shared.controlADPCMFormatAudio(isOpen: true) { res in
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
        BCLRingManager.shared.controlADPCMFormatAudio(isOpen: false) { res in
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
    
    // 370 - 单声道解码-adpcm格式（Z5J定制）
    private func openMonoAdpcmDecodePage() {
        guard let vc = viewController else {
            BDLogger.error("当前ViewController为空")
            return
        }
        let monoAdpcmDecodeVC = VoiceRecord_VC()
        vc.navigationController?.pushViewController(monoAdpcmDecodeVC, animated: true)
    }
}
