//
//  Main_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/3/18.
//

import BCLRingSDK
import QMUIKit
import RxSwift
import SwiftDate
import UIKit

//class Main_VC: UIViewController {
//    // MARK: - IBAction
//
//    @IBAction func logAction(_ sender: UIButton) {
//        navigationController?.pushViewController(logVC, animated: true)
//    }
//
//    @IBAction func btnAction(_ sender: UIButton) {

//        case 124: //    固件文件下载
////            let fileName = "7.1.7.0Z3R.bin"
////            let downloadUrl = "https://image.lmyiot.com/FiaeMmw7OwXNwtKWoaQM2HsNhi4z"
//
////            let fileName = "7.1.9.2Z3R.bin"
////            let downloadUrl = "http://221.226.159.58:22222/profile/upload/2025/04/15/7.1.9.2Z3R.bin"
//
////            let fileName = "6.0.2.7Z2W.zip"
////            let downloadUrl = "http://221.226.159.58:22222/profile/upload/2025/04/01/6.0.3.9Z2W.zip"
//
////            let fileName = "2.7.4.8Z27.hex16"
////            let downloadUrl = "http://221.226.159.58:22222/profile/upload/2025/04/01/2.7.4.8Z27.hex16"
//
//            let fileName = "2.7.4.8Z27.hex16"
//            let downloadUrl = "http://221.226.159.58:22222/profile/upload/2025/04/01/2.7.4.8Z27.hex16"
//
//            let destinationPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//            BCLRingManager.shared.downloadFirmware(url: downloadUrl, fileName: fileName, destinationPath: destinationPath, progress: { progress in
//                BDLogger.info("固件下载进度：\(progress)")
//            }, completion: { result in
//                switch result {
//                case let .success(filePath):
//                    BDLogger.info("固件下载成功：\(filePath)")
//                case let .failure(error):
//                    BDLogger.error("固件下载失败：\(error)")
//                }
//            })
//            break


//        case 137: // 通讯回环测试
//            // 设置测试时长为2分钟
//            let duration = 2 * 60
//            // 设置测试间隔为1秒
//            let interval = 1.0
//            // 记录开始时间
//            let startTime = Date()
//            // 计算结束时间
//            let endTime = startTime.addingTimeInterval(TimeInterval(duration))
//            // 创建计时器，每秒执行一次测试
//            var timer: Timer?
//            // 计算剩余时间
//            var remainingSeconds = duration
//            // 创建并启动定时器
//            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] t in
//                guard let self = self else {
//                    t.invalidate()
//                    return
//                }
//                // 执行通讯回环测试
//                BCLRingManager.shared.communicationLoopRateTest(dataLength: 2) { res in
//                    switch res {
//                    case let .success(response):
//                        BDLogger.info("通讯回环测试成功: \(response)")
//                    case let .failure(error):
//                        BDLogger.error("通讯回环测试失败: \(error)")
//                    }
//                }
//                // 更新剩余时间
//                remainingSeconds -= Int(interval)
//                // 更新UI
//                DispatchQueue.main.async {
//                    if let button = self.view.viewWithTag(137) as? UIButton {
//                        button.setTitle("通讯回环测试中... 剩余\(remainingSeconds)秒", for: .normal)
//                        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
//                    }
//                }
//                // 检查是否达到结束时间
//                if Date() >= endTime {
//                    t.invalidate()
//                    timer = nil
//                    // 测试完成后更新UI
//                    DispatchQueue.main.async {
//                        if let button = self.view.viewWithTag(137) as? UIButton {
//                            button.setTitle("通讯回环测试", for: .normal)
//                            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//                        }
//                    }
//                    BDLogger.info("通讯回环测试完成")
//                }
//            }
//            break
//        case 148: // SDK本地计算睡眠数据
//            BDLogger.info("使用SDK内置计算睡眠数据方法获取睡眠数据")
//            let date = Date("2025-08-08", format: "yyyy-MM-dd")
//            // BCLRingLocalSleepModel
//            let sleepModel = BCLRingManager.shared.calculateSleepLocally(targetDate: date!, macString: nil)
//            BDLogger.info("睡眠数据\(sleepModel.description)")
//            break
//        case 150: // PPG波形透传输
//            BDLogger.info("开始-PPG波形透传输")
//            let waveSetting = 0
//            BCLRingManager.shared.ppgWaveFormMeasurement(collectTime: 30, waveConfig: 0, progressConfig: 0, waveSetting: waveSetting) { res in
//                switch res {
//                case let .success(response):
//                    BDLogger.info("PPG波形透传输成功: \(response)")
//                    BDLogger.info("PPG波形透传输进度: \(String(describing: response.progressData))")
//                    BDLogger.info("PPG波形透传输-心率: \(String(describing: response.heartRate))")
//                    BDLogger.info("PPG波形透传输-血氧: \(String(describing: response.oxygen))")
//                    if waveSetting == 0 {
//                        if let waveData = response.waveform0 {
//                            BDLogger.info("波形数据: 序号\(waveData.0), 数量\(waveData.1)")
//                            BDLogger.info("波形数据-绿色: \(waveData.2)")
//                        }
//                    } else if waveSetting == 1 {
//                        if let waveData = response.waveform1 {
//                            BDLogger.info("波形数据: 序号\(waveData.0), 数量\(waveData.1)")
//                            BDLogger.info("波形数据-(绿色+红外): \(waveData.2)")
//                        }
//                    } else if waveSetting == 2 {
//                        BDLogger.info("PPG波形透传输-佩戴检测")
//                    }
//                    break
//                case let .failure(error):
//                    BDLogger.error("PPG波形透传输失败: \(error)")
//                    break
//                }
//            }
//            break
//        case 151: // PPG波形透传输停止
//            BDLogger.info("停止-PPG波形透传输")
//            BCLRingManager.shared.ppgWaveFormStop { res in
//                switch res {
//                case .success:
//                    BDLogger.info("停止PPG波形透传输成功")
//                case let .failure(error):
//                    BDLogger.error("停止PPG波形透传输失败: \(error)")
//                }
//            }
//            break
//        case 165: // 删除文件
//            BDLogger.info("删除文件")
//            // 临时测试文件名
//            let fileName = "010203040506_2025_09_02_14_43_19_9.bin"
//            BCLRingManager.shared.deleteFile(fileName: fileName) { res in
//                switch res {
//                case let .success(response):
//                    if let result = response.deleteResult, result == 1 {
//                        BDLogger.info("删除文件成功: \(response)")
//                    } else {
//                        BDLogger.info("删除文件失败: \(response)")
//                    }
//                case let .failure(error):
//                    BDLogger.error("删除文件失败: \(error)")
//                }
//            }
//            break
//        case 167: // 获取文件系统空间信息
//            BDLogger.info("获取文件系统空间信息")
//            BCLRingManager.shared.getFileSystemInfo { res in
//                switch res {
//                case let .success(response):
//                    BDLogger.info("获取文件系统空间信息成功: \(response)")
//                    BDLogger.info("文件系统空间信息-总空间: \(response.totalSize ?? 0)")
//                    BDLogger.info("文件系统空间信息-可用空间: \(response.freeSize ?? 0)")
//                    BDLogger.info("文件系统空间信息-已用空间: \(response.usedSize ?? 0)")
//                case let .failure(error):
//                    BDLogger.error("获取文件系统空间信息失败: \(error)")
//                }
//            }
//            break
//        case 168: // 设置自动记录采集数据模式
//            BDLogger.info("设置自动记录采集数据模式")
//            BCLRingManager.shared.setAutoRecordDataMode(type: 1) { res in
//                switch res {
//                case let .success(response):
//                    if let result = response.result, result == 1 {
//                        BDLogger.info("设置自动记录采集数据模式成功")
//                    } else {
//                        BDLogger.info("设置自动记录采集数据模式失败")
//                    }
//                case let .failure(error):
//                    BDLogger.error("设置自动记录采集数据模式失败: \(error)")
//                }
//            }
//
//            break
//        case 169: // 获取自动记录采集数据模式
//            BDLogger.info("获取自动记录采集数据模式")
//            BCLRingManager.shared.getAutoRecordDataMode { res in
//                switch res {
//                case let .success(response):
//                    BDLogger.info("获取自动记录采集数据模式成功: \(response)")
//                    // 0：停止自动记录采集信息、1：开启自动记录三轴信息、2：开启自动记录六轴信息、3：开启自动记录spo2信息、4：开启自动记录hr信息、5：开启自动记录红外信息、6：开启自动记温度信息
//                    if let mode = response.status {
//                        switch mode {
//                        case 0:
//                            BDLogger.info("停止自动记录采集信息")
//                        case 1:
//                            BDLogger.info("开启自动记录三轴信息")
//                        case 2:
//                            BDLogger.info("开启自动记录六轴信息")
//                        case 3:
//                            BDLogger.info("开启自动记录spo2信息")
//                        case 4:
//                            BDLogger.info("开启自动记录hr信息")
//                        case 5:
//                            BDLogger.info("开启自动记录红外信息")
//                        case 6:
//                            BDLogger.info("开启自动记温度信息")
//                        default:
//                            BDLogger.info("未知的自动记录采集数据模式")
//                        }
//                    }
//                case let .failure(error):
//                    BDLogger.error("获取自动记录采集数据模式失败: \(error)")
//                }
//            }
//
//            break
//        case 189: //  设置HID触摸-上传实时音频模式
//            BDLogger.info("设置HID触摸-上传实时音频模式")
//
//            BCLRingManager.shared.hidTouchAudioDataBlock = { dataLenght, seq, audioData, isEnd in
//                BDLogger.info("HID触摸-上传实时音频数据-数据长度: \(dataLenght)")
//                BDLogger.info("HID触摸-上传实时音频数据-包序号: \(seq)")
//                BDLogger.info("HID触摸-上传实时音频数据-音频数据: \(audioData)")
//                BDLogger.info("HID触摸-上传实时音频数据-是否结束: \(isEnd)")
//            }
//
//            BCLRingManager.shared.setHIDMode(touchMode: 4,
//                                             gestureMode: 255,
//                                             systemType: 1,
//                                             deviceModelName: BCLRingManager.shared.getMobileDeviceModelName(),
//                                             screenHeightPixel: BCLRingManager.shared.getMobileDeviceScreenWidthPixel(),
//                                             screenWidthPixel: BCLRingManager.shared.getMobileDeviceScreenHeightPixel()) { res in
//                switch res {
//                case let .success(response):
//                    if response.status == 1 {
//                        BDLogger.info("设置HID触摸-上传实时音频模式成功")
//                    } else {
//                        BDLogger.info("设置HID触摸-上传实时音频模式失败")
//                    }
//                case let .failure(error):
//                    BDLogger.error("设置HID触摸-上传实时音频模式失败: \(error)")
//                }
//            }
//            break
//        case 200:
//            let swipeUpGesture = 255
//            let swipeDownGesture = 255
//            let snapGesture = 255
//            let pinchGesture = 255
//            BCLRingManager.shared.setGestureFunction(swipeUpGesture: swipeUpGesture, swipeDownGesture: swipeDownGesture, snapGesture: snapGesture, pinchGesture: pinchGesture) { res in
//                switch res {
//                case let .success(response):
//                    if response.setStatus == 1 {
//                        BDLogger.info("设置当前HID手势2模式成功")
//                        if swipeUpGesture == 255 && swipeDownGesture == 255 && snapGesture == 255 && pinchGesture == 255 {
//                            BDLogger.info("当前HID手势2模式已关闭")
//                            QMUITips.show(withText: "提醒用户需要手动去系统蓝牙设置页面忽略蓝牙设备，重新连接的时候需要取消配对模式")
//                        } else {
//                            QMUITips.show(withText: "手势功能已开启，需要选择配对模式")
//                            /// 此处断开蓝牙连接，如果有开启自动重连，则会进行自动重连并触发系统弹窗（是否配对）
//                            BCLRingManager.shared.disconnect(peripheral: BCLRingManager.shared.currentConnectedDevice?.peripheral)
//                        }
//                    } else {
//                        BDLogger.info("设置当前HID手势2模式失败")
//                    }
//                case let .failure(error):
//                    BDLogger.error("设置当前HID手势2模式失败: \(error)")
//                }
//            }
//
//            break

//        case 204: // 特定固件步数获取
//            BDLogger.info("特定固件步数获取")
//            BCLRingManager.shared.queryStepInfo(mac: "42:4A:2D:2C:E1:6E") { res in
//                switch res {
//                case let .success(response):
//                    BDLogger.info("特定固件步数获取-成功")
//                    BDLogger.info("步数信息-总步数: \(response)")
//                case let .failure(error):
//                    BDLogger.error("特定固件步数获取-失败: \(error)")
//                }
//            }
//            break
//        case 206: // 请求文件数据断点续传
//            BDLogger.info("请求文件数据断点续传")
//            // 示例：从偏移量1000开始续传文件 "example.bin"
////            let fileOffset: Int32 = 1000
////            let fileName = "example.bin"
////            BCLRingManager.shared.requestFileDataResume(fileOffset: fileOffset, fileName: fileName) { result in
////                switch result {
////                case let .success(response):
////                    BDLogger.info("请求文件数据断点续传成功: \(response)")
////                    if let fileIndex = response.fileIndex, let progress = response.progress {
////                        BDLogger.info("文件序号: \(fileIndex), 进度: \(progress)")
////                    }
////                case let .failure(error):
////                    BDLogger.error("请求文件数据断点续传失败: \(error)")
////                }
////            }
//            break
//        case 207: // 请求文件的数据（一键上传）
//            BDLogger.info("请求文件的数据（一键上传）")
//            // 示例：一键上传索引为1的文件
//            let fileIndex = 1
//            BCLRingManager.shared.requestFileDataOneKey(fileIndex: fileIndex) { result in
//                switch result {
//                case let .success(response):
//                    // 根据响应类型处理不同的数据
//                    if let responseType = response.responseType {
//                        switch responseType {
//                        case let .fileDataOneKey(status, startTimestamp, endTimestamp):
//                            BDLogger.info("一键上传状态: \(status), 开始时间: \(startTimestamp), 结束时间: \(endTimestamp)")
//                            switch status {
//                            case 0: // 设备忙
//                                BDLogger.info("设备忙")
//                            case 1: // 开始一键上传、数据上传中
//                                BDLogger.info("开始一键上传")
//                            case 2: // 一键上传完成
//                                BDLogger.info("一键上传完成")
//                            case 3: // 文件序号不符合错误
//                                BDLogger.info("文件序号不符合")
//                            default:
//                                BDLogger.info("未知状态: \(status)")
//                            }
//                        case let .fileResponse(fileIndex, uploadStatus, startTimestamp, endTimestamp, fileName):
//                            var uploadStatusDesc = ""
//                            switch uploadStatus {
//                            case 0:
//                                uploadStatusDesc = "开始上传"
//                            case 1:
//                                uploadStatusDesc = "上传完成"
//                            default:
//                                uploadStatusDesc = "未知状态"
//                            }
//                            BDLogger.info("文件响应 - 序号: \(fileIndex), 上传状态: \(uploadStatusDesc), 文件名: \(fileName)")
//                            BDLogger.info("开始时间: \(startTimestamp), 结束时间: \(endTimestamp)")
//                        case let .fileProgress(fileIndex, progress):
//                            BDLogger.info("文件上传进度 - 序号: \(fileIndex), 进度: \(progress)%")
//                        case let .fileDataOneKeyProgress(progress):
//                            BDLogger.info("一键上传进度: \(progress)%")
//                        case let .fileContentData(fileContent: fileContent):
//                            // 处理fileContent为空的情况
//                            // 根据文件内容类型进行处理
//                            if let content = fileContent {
//                                switch content {
//                                case let .unknown(data):
//                                    BDLogger.info("未知文件类型 - 数据：\(String(describing: data))")
//                                case let .fileContentType1(data):
//                                    BDLogger.info("文件类型1（三轴数据） - 数据：\(String(describing: data))")
//                                case let .fileContentType2(data):
//                                    BDLogger.info("文件类型2（六轴数据） - 数据：\(String(describing: data))")
//                                case let .fileContentType3(data):
//                                    BDLogger.info("文件类型3（PPG红外+红色+三轴spo2） - 数据：\(String(describing: data))")
//                                case let .fileContentType4(data):
//                                    BDLogger.info("文件类型4（PPG绿色） - 数据：\(String(describing: data))")
//                                case let .fileContentType5(data):
//                                    BDLogger.info("文件类型5（PPG红外） - 数据：\(String(describing: data))")
//                                case let .fileContentType6(data):
//                                    BDLogger.info("文件类型6（温度数据红外） - 数据：\(String(describing: data))")
//                                case let .fileContentType7(data):
//                                    // (时间戳,[(绿色+红色+红外+加速度X+加速度Y+加速度Z+陀螺仪X+陀螺仪Y+陀螺仪Z+温度0+温度1+温度2)])
//                                    BDLogger.info("文件内容----时间戳：\(data.0)")
//                                    BDLogger.info("文件内容----数据：\(data.1)")
//                                case let .fileContentType8(data):
//                                    if let data = data {
//                                        let preview = data.map { String(format: "%02x", $0) }
//                                        BDLogger.info("文件数据:adpcm音频，大小:\(data.count)字节，字节内容:\(preview)")
//                                        // 需要注意这里是未经过解析处理的原始蓝牙数据
//                                    } else {
//                                        BDLogger.info("文件数据:adpcm音频：无数据")
//                                    }
//                                case let .fileContentType9(data):
//                                    if let data = data {
//                                        let preview = data.map { String(format: "%02x", $0) }
//                                        BDLogger.info("文件数据:opus音频，大小:\(data.count)字节，字节内容:\(preview)")
//                                    } else {
//                                        BDLogger.info("文件数据:opus音频：无数据")
//                                    }
//                                case let .fileContentType10(data):
//                                    if let data = data {
//                                        let preview = data.map { String(format: "%02x", $0) }
//                                        BDLogger.info("文件数据:攀岩项目数据，大小:\(data.count)字节，字节内容:\(preview)")
//                                    } else {
//                                        BDLogger.info("文件数据:攀岩项目数据：无数据")
//                                    }
//                                }
//                            } else {
//                                BDLogger.error("文件内容为空")
//                            }
//                        }
//                    }
//                case let .failure(error):
//                    BDLogger.error("请求文件的数据（一键上传）失败: \(error)")
//                }
//            }
//            break
//        case 208: // fdKey校验
//            BCLRingManager.shared.fdKeyVerification(parameter_1: 1,
//                                                    parameter_2: 1,
//                                                    parameter_3: 1,
//                                                    parameter_4: 1,
//                                                    parameter_5: 1,
//                                                    parameter_6: 1,
//                                                    parameter_7: 1,
//                                                    parameter_8: 1) { result in
//                switch result {
//                case let .success(response):
//                    if response.status == 0 {
//                        BDLogger.info("fdKey校验成功")
//                    } else {
//                        BDLogger.error("fdKey校验失败")
//                    }
//                case let .failure(error):
//                    BDLogger.error("fdKey校验失败: \(error)")
//                }
//            }
//            break
//        case 210: // 获取用户最新一条历史数据，可以取time字段
//            BCLRingManager.shared.loadUserLatestHistory { result in
//                switch result {
//                case let .success(latestHistory):
//                    // 处理最新历史数据
//                    BDLogger.info("最新历史数据：\(latestHistory.localizedDescription)")
//                case let .failure(error):
//                    // 处理错误
//                    BDLogger.error("获取失败：\(error)")
//                }
//            }
//            break
//        case 211: // 录音Demo
//            navigationController?.pushViewController(VoiceRecord_VC(), animated: true)
//            break
//        case 212: // 设置用户信息
//            BCLRingManager.shared.setPersonalInformation(sex: 1, age: 360, height: 177, weight: 88) { result in
//                switch result {
//                case let .success(res):
//                    if res.status == 0 {
//                        BDLogger.info("用户信息设置成功")
//                    } else {
//                        BDLogger.info("用户信息设置失败")
//                    }
//                case let .failure(error):
//                    // 处理错误
//                    BDLogger.error("设置失败：\(error)")
//                }
//            }
//            break
//        case 213: // 读取用户信息
//            BCLRingManager.shared.getPersonalInformation { result in
//                switch result {
//                case let .success(userInfo):
//                    BDLogger.info("用户性别为：\(userInfo.sex == 0 ? "女" : "男")")
//                    BDLogger.info("用户年龄为：\(userInfo.sex)月")
//                    BDLogger.info("用户身高为：\(userInfo.sex)cm")
//                    BDLogger.info("用户体重为：\(userInfo.weight)kg")
//                case let .failure(error):
//                    // 处理错误
//                    BDLogger.error("获取失败：\(error)")
//                }
//            }
//            break
//        case 214: // GoMores睡眠算法
//            readGoMoreSleepDataExample()
//            break
//        default:
//            break
//        }
//    }

//// MARK: - 版本号处理工具方法
//
//extension Main_VC {
//    /// 从文件名中提取版本号
//    /// - Parameter fileName: 文件名，例如 "2.7.5.0Z3N.hex16"
//    /// - Returns: 版本号字符串，例如 "2.7.5.0"
//    private func extractVersionNumber(from fileName: String) -> String {
//        // 使用正则表达式匹配版本号格式
//        let pattern = #"^(\d+\.\d+\.\d+\.\d+)"#
//
//        if let regex = try? NSRegularExpression(pattern: pattern),
//           let match = regex.firstMatch(in: fileName, range: NSRange(fileName.startIndex..., in: fileName)) {
//            let versionRange = Range(match.range(at: 1), in: fileName)!
//            return String(fileName[versionRange])
//        }
//
//        // 如果正则匹配失败，使用简单的字符串分割
//        let components = fileName.components(separatedBy: "Z")
//        if let firstComponent = components.first {
//            return firstComponent
//        }
//
//        return ""
//    }
//
//    /// 比较两个版本号
//    /// - Parameters:
//    ///   - version1: 第一个版本号
//    ///   - version2: 第二个版本号
//    /// - Returns: 比较结果：-1表示version1更旧，0表示相等，1表示version1更新
//    private func compareVersions(_ version1: String, _ version2: String) -> Int {
//        let components1 = version1.components(separatedBy: ".").compactMap { Int($0) }
//        let components2 = version2.components(separatedBy: ".").compactMap { Int($0) }
//
//        let maxLength = max(components1.count, components2.count)
//
//        for i in 0 ..< maxLength {
//            let num1 = i < components1.count ? components1[i] : 0
//            let num2 = i < components2.count ? components2[i] : 0
//
//            if num1 < num2 {
//                return -1
//            } else if num1 > num2 {
//                return 1
//            }
//        }
//
//        return 0
//    }
//
//    /// 从固件版本列表中找出最新版本
//    /// - Parameter versions: 固件版本列表
//    /// - Returns: 最新版本的固件信息
//    private func findLatestVersion(from versions: [Any]) -> Any? {
//        var latestVersion: Any?
//        var latestVersionNumber = ""
//
//        for version in versions {
//            // 使用 Mirror 反射来获取 fileName 属性
//            let mirror = Mirror(reflecting: version)
//            var fileName: String?
//
//            for child in mirror.children {
//                if child.label == "fileName" {
//                    fileName = child.value as? String
//                    break
//                }
//            }
//
//            if let fileName = fileName {
//                let versionNumber = extractVersionNumber(from: fileName)
//
//                if versionNumber.isEmpty {
//                    continue
//                }
//
//                if latestVersion == nil {
//                    latestVersion = version
//                    latestVersionNumber = versionNumber
//                } else {
//                    let comparison = compareVersions(versionNumber, latestVersionNumber)
//                    if comparison > 0 {
//                        latestVersion = version
//                        latestVersionNumber = versionNumber
//                    }
//                }
//            }
//        }
//
//        return latestVersion
//    }
//
//    /// 从固件版本对象中获取文件名
//    /// - Parameter version: 固件版本对象
//    /// - Returns: 文件名
//    private func getFileName(from version: Any) -> String {
//        let mirror = Mirror(reflecting: version)
//        for child in mirror.children {
//            if child.label == "fileName" {
//                return child.value as? String ?? ""
//            }
//        }
//        return ""
//    }
//
//    /// 从固件版本对象中获取文件URL
//    /// - Parameter version: 固件版本对象
//    /// - Returns: 文件URL
//    private func getFileUrl(from version: Any) -> String {
//        let mirror = Mirror(reflecting: version)
//        for child in mirror.children {
//            if child.label == "fileUrl" {
//                return child.value as? String ?? ""
//            }
//        }
//        return ""
//    }
//
//    /// 递增MAC地址(当前Mac地址+1)
//    /// - Parameter macAddress: MAC地址
//    /// - Returns: 递增后的MAC地址
//    func incrementMac(macAddress: String) -> String? {
//        let components = macAddress.components(separatedBy: ":")
//        var bytes = [UInt8]()
//
//        for component in components {
//            if let byte = UInt8(component, radix: 16) {
//                bytes.append(byte)
//            } else {
//                return nil // 非法的MAC地址格式
//            }
//        }
//
//        for i in (0 ..< 6).reversed() {
//            if bytes[i] < 255 {
//                bytes[i] += 1
//                break
//            } else {
//                bytes[i] = 0
//            }
//        }
//
//        let incrementedMacAddress = bytes.map { String(format: "%02X", $0) }.joined(separator: ":")
//        return incrementedMacAddress
//    }
//
//    /// 递减MAC地址(当前Mac地址-1)
//    /// - Parameter macAddress: MAC地址
//    /// - Returns: 递减后的MAC地址
//    func decrementMac(macAddress: String) -> String? {
//        let components = macAddress.components(separatedBy: ":")
//        var bytes = [UInt8]()
//
//        for component in components {
//            if let byte = UInt8(component, radix: 16) {
//                bytes.append(byte)
//            } else {
//                return nil // 非法的MAC地址格式
//            }
//        }
//
//        for i in (0 ..< 6).reversed() {
//            if bytes[i] > 0 {
//                bytes[i] -= 1
//                break
//            } else {
//                bytes[i] = 255
//            }
//        }
//
//        let decrementedMacAddress = bytes.map { String(format: "%02X", $0) }.joined(separator: ":")
//        return decrementedMacAddress
//    }
//}
//
//// MARK: 待整理方法
//
//extension Main_VC {
//    // MARK: - 设置定时启动运动采集示例 0x3805
//
//    /// 设置定时启动运动采集
//    func setTimeStartSportModeExample() {
//        // 设置定时启动运动采集
//        let startTime = Date().addingTimeInterval(10).timeIntervalSince1970
//        let endTime = Date().addingTimeInterval(70).timeIntervalSince1970
//        BCLRingManager.shared.setTimedStartSportMode(collectionMode: 0, startTime: startTime, endTime: endTime) { result in
//            switch result {
//            case let .success(response):
//                if response.status == 1 {
//                    BDLogger.info("设置成功")
//                } else {
//                    BDLogger.info("设置失败")
//                }
//            case let .failure(error):
//                BDLogger.error("错误: \(error)")
//            }
//        }
//    }
//
//    // MARK: - 获取定时启动运动采集配置示例 0x3806
//
//    /// 获取定时启动运动采集配置
//    func getTimeStartSportModeExample() {
//        // 获取定时启动运动采集配置
//        BCLRingManager.shared.getTimedStartSportMode { result in
//            switch result {
//            case let .success(response):
//                BDLogger.info("采集模式: \(response.collectionMode ?? -1)")
//                BDLogger.info("开始时间: \(response.startTime ?? 0)")
//                BDLogger.info("结束时间: \(response.endTime ?? 0)")
//            case let .failure(error):
//                BDLogger.error("错误: \(error)")
//            }
//        }
//    }
//
//    // MARK: - 设置 PPG 频率示例 0x3715
//
//    /// 设置 PPG 频率
//    func setPPGFrequencyExample() {
//        // 调用设置接口
//        BCLRingManager.shared.setPPGFrequency(hrFrequency: 25, spo2Frequency: 25, rawdataFrequency: 50) { result in
//            switch result {
//            case let .success(response):
//                if response.success {
//                    BDLogger.info("✅ PPG频率设置成功")
//                    BDLogger.info("   心率频率: \(25) Hz")
//                    BDLogger.info("   血氧频率: \(25) Hz")
//                    BDLogger.info("   原始数据频率: \(50) Hz")
//                } else {
//                    BDLogger.error("❌ PPG频率设置失败")
//                }
//
//            case let .failure(error):
//                BDLogger.error("❌ 设置PPG频率出错: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    // MARK: - 读取 PPG 频率示例 0x3716
//
//    /// 读取 PPG 频率
//    func readPPGFrequencyExample() {
//        // 调用读取接口
//        BCLRingManager.shared.readPPGFrequency { result in
//            switch result {
//            case let .success(response):
//                BDLogger.info("✅ PPG频率读取成功")
//                BDLogger.info("   心率频率: \(response.hrFrequency) Hz")
//                BDLogger.info("   血氧频率: \(response.spo2Frequency) Hz")
//                BDLogger.info("   原始数据频率: \(response.rawdataFrequency) Hz")
//            case let .failure(error):
//                BDLogger.error("❌ 读取PPG频率出错: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    // MARK: - 设置陀螺仪状态示例 0x3717
//
//    /// 设置陀螺仪状态
//    func setGyroscopeStatusExample() {
//        BCLRingManager.shared.setGyroscopeStatus(status: 1) { result in
//            switch result {
//            case let .success(response):
//                if response.success {
//                    BDLogger.info("陀螺仪开启成功")
//                } else {
//                    BDLogger.info("陀螺仪开启失败")
//                }
//            case let .failure(error):
//                BDLogger.error("设置陀螺仪状态失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 读取陀螺仪状态示例 0x3718
//
//    /// 读取陀螺仪状态
//    func readGyroscopeStatusExample() {
//        BCLRingManager.shared.readGyroscopeStatus { result in
//            switch result {
//            case let .success(response):
//                BDLogger.info("陀螺仪状态：\(response.status == 1 ? "开启" : "关闭")")
//            case let .failure(error):
//                BDLogger.error("读取陀螺仪状态失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 加速度状态控制示例 0x3719
//
//    /// 加速度状态控制
//    func setAccelerometerStatusExample() {
//        BCLRingManager.shared.setAccelerometerStatus(status: 1) { result in
//            switch result {
//            case let .success(response):
//                if response.success {
//                    BDLogger.info("加速度开启成功")
//                } else {
//                    BDLogger.info("加速度开启失败")
//                }
//            case let .failure(error):
//                BDLogger.error("设置加速度状态失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 读取加速度状态控制示例 0x371A
//
//    /// 读取加速度状态控制
//    func readAccelerometerStatusExample() {
//        BCLRingManager.shared.readAccelerometerStatus { result in
//            switch result {
//            case let .success(response):
//                BDLogger.info("加速度状态：\(response.status == 1 ? "开启" : "关闭")")
//            case let .failure(error):
//                BDLogger.error("读取加速度状态失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 设置温度状态控制示例 0x371B
//
//    /// 设置温度状态控制
//    func setTemperatureStatusExample() {
//        BCLRingManager.shared.setTemperatureStatus(status: 1) { result in
//            switch result {
//            case let .success(response):
//                if response.success {
//                    BDLogger.info("温度采集开启成功")
//                } else {
//                    BDLogger.info("温度采集开启失败")
//                }
//            case let .failure(error):
//                BDLogger.error("设置温度状态失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 读取温度状态控制示例 0x371C
//
//    /// 读取温度状态控制
//    func readTemperatureStatusExample() {
//        BCLRingManager.shared.readTemperatureStatus { result in
//            switch result {
//            case let .success(response):
//                BDLogger.info("温度采集状态：\(response.status == 1 ? "开启" : "关闭")")
//            case let .failure(error):
//                BDLogger.error("读取温度状态失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 设置PPG状态控制示例 0x371D
//
//    /// 设置PPG状态控制
//    func setPPGStatusExample() {
//        BCLRingManager.shared.setPPGStatus(status: 1) { result in
//            switch result {
//            case let .success(response):
//                if response.success {
//                    BDLogger.info("PPG开启成功")
//                } else {
//                    BDLogger.info("PPG开启失败")
//                }
//            case let .failure(error):
//                BDLogger.error("设置PPG状态失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 读取PPG状态控制示例 0x371E
//
//    /// 读取PPG状态控制
//    func readPPGStatusExample() {
//        BCLRingManager.shared.readPPGStatus { result in
//            switch result {
//            case let .success(response):
//                BDLogger.info("PPG状态：\(response.status == 1 ? "开启" : "关闭")")
//            case let .failure(error):
//                BDLogger.error("读取PPG状态失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 设置PPG RAWdata采集时长示例 0x371F
//
//    /// 设置 PPG RAWdata采集时长
//    func setPPGRawDataDurationExample() {
//        BCLRingManager.shared.setPPGRawDataDuration(duration: 60) { result in
//            switch result {
//            case let .success(response):
//                if response.success {
//                    BDLogger.info("设置PPG RAWdata采集时长成功")
//                } else {
//                    BDLogger.info("设置PPG RAWdata采集时长失败")
//                }
//            case let .failure(error):
//                BDLogger.error("设置PPG RAWdata采集时长失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 读取PPG RAWdata采集时长示例 0x3720
//
//    /// 读取PPG RAWdata采集时长
//    func readPPGRawDataDurationExample() {
//        BCLRingManager.shared.readPPGRawDataDuration { result in
//            switch result {
//            case let .success(response):
//                BDLogger.info("PPG RAWdata采集时长：\(response.duration)秒")
//            case let .failure(error):
//                BDLogger.error("读取PPG RAWdata采集时长失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 设置自动采集状态控制示例 0x3721
//
//    /// 设置自动采集状态控制
//    func setAutoCollectionStatusExample() {
//        BCLRingManager.shared.setAutoCollectionStatus(status: 1) { result in
//            switch result {
//            case let .success(response):
//                if response.success {
//                    BDLogger.info("自动采集开启成功")
//                } else {
//                    BDLogger.info("自动采集开启失败")
//                }
//            case let .failure(error):
//                BDLogger.error("设置自动采集状态失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 读取自动采集状态控制示例 0x3722
//
//    /// 读取自动采集状态控制
//    func readAutoCollectionStatusExample() {
//        BCLRingManager.shared.readAutoCollectionStatus { result in
//            switch result {
//            case let .success(response):
//                BDLogger.info("自动采集状态：\(response.status == 1 ? "开启" : "关闭")")
//            case let .failure(error):
//                BDLogger.error("读取自动采集状态失败：\(error)")
//            }
//        }
//    }
//
//    // MARK: - 复位指令示例 0xF209
//
//    /// 复位指令测试
//    func performResetAndRetry() {
//        BCLRingManager.shared.reset { result in
//            switch result {
//            case .success:
//                BDLogger.info("复位成功，等待设备重启...")
//            case let .failure(error):
//                BDLogger.error("复位指令执行失败: \(error.localizedDescription)")
//                // 处理不同的错误类型
//                switch error {
//                case .commandSending(.timeout):
//                    BDLogger.error("指令超时")
//                default:
//                    BDLogger.error("其他错误: \(error)")
//                }
//            }
//        }
//    }
//
//    // MARK: - GoMore睡眠数据示例 0x3605
//
//    /// 读取GoMore睡眠数据示例
//    func readGoMoreSleepDataExample() {
//        BDLogger.info("========== 开始读取GoMore睡眠数据 ==========")
//
//        // 用于收集完整的睡眠数据
//        var sleepOverviewData: BCLGoMoreSleepDataResponse.SleepOverview?
//        var allSleepStages: [Int8] = []
//        var receivedPackageCount = 0
//        var totalPackageCount = 0
//
//        BCLRingManager.shared.readGoMoreSleepData { result in
//            switch result {
//            case let .success(response):
//                // 根据响应类型处理数据
//                guard let responseType = response.responseType else {
//                    BDLogger.warning("GoMore睡眠数据响应类型为空")
//                    return
//                }
//
//                switch responseType {
//                case let .sleepOverview(overview):
//                    // 处理睡眠总览数据
//                    sleepOverviewData = overview
//                    self.displaySleepOverview(overview)
//
//                case let .sleepStages(stages):
//                    // 处理睡眠分期数据
//                    receivedPackageCount += 1
//                    totalPackageCount = Int(stages.totalPackages)
//                    allSleepStages.append(contentsOf: stages.stages)
//
//                    BDLogger.info("📦 收到睡眠分期数据包 \(stages.packageNumber)/\(stages.totalPackages)")
//                    BDLogger.info("   当前包含 \(stages.stageCount) 个分期数据")
//
//                    // 显示进度
//                    let progress = Double(receivedPackageCount) / Double(totalPackageCount) * 100
//                    BDLogger.info("   接收进度: \(String(format: "%.1f", progress))%")
//
//                    // 如果所有包接收完成，进行数据分析
//                    if receivedPackageCount >= totalPackageCount {
//                        BDLogger.info("✅ 所有睡眠分期数据接收完成")
//                        self.analyzeSleepData(overview: sleepOverviewData, stages: allSleepStages)
//                    }
//
//                case .noData:
//                    BDLogger.info("ℹ️ 设备中没有GoMore睡眠数据")
//                    QMUITips.show(withText: "设备中没有睡眠数据")
//                }
//
//            case let .failure(error):
//                BDLogger.error("❌ 读取GoMore睡眠数据失败: \(error.localizedDescription)")
//
//                // 根据错误类型提供详细信息
//                switch error {
//                case .commandSending(.timeout):
//                    QMUITips.show(withText: "命令超时，请检查设备连接")
//                case .commandSending(.sendFailed):
//                    QMUITips.show(withText: "命令发送失败，请重试")
//                default:
//                    QMUITips.show(withText: "读取失败: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    /// 显示睡眠总览信息
//    private func displaySleepOverview(_ overview: BCLGoMoreSleepDataResponse.SleepOverview) {
//        BDLogger.info("\n========== GoMore睡眠总览 ==========")
//
//        // 时间信息
//        let startDate = Date(timeIntervalSince1970: TimeInterval(overview.startTimestamp))
//        let endDate = Date(timeIntervalSince1970: TimeInterval(overview.endTimestamp))
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeZone = TimeZone.current
//
//        BDLogger.info("📅 睡眠时间: \(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))")
//        BDLogger.info("⏱ 睡眠时长: \(overview.sleepPeriod) 分钟")
//        BDLogger.info("💤 睡眠类型: \(overview.type == 1 ? "长睡" : "短睡")")
//
//        // 睡眠质量
//        BDLogger.info("\n--- 睡眠质量 ---")
//        BDLogger.info("⭐️ 睡眠评分: \(overview.score) / 100")
//        BDLogger.info("📊 睡眠效率: \(String(format: "%.1f", Double(overview.efficiency) / 100))%")
//        BDLogger.info("⏰ 睡眠潜伏期: \(overview.latency) 分钟")
//        BDLogger.info("🔄 入睡后清醒时间(WASO): \(overview.waso) 分钟")
//        BDLogger.info("⏱ 总睡眠时间: \(overview.totalSleepTime) 分钟")
//
//        // 各阶段时长和比例
//        BDLogger.info("\n--- 各睡眠阶段 ---")
//        BDLogger.info("😴 深睡: \(overview.deepNumMinutes) 分钟 (\(String(format: "%.1f", Double(overview.deepRatio) / 100))%)")
//        BDLogger.info("💤 浅睡: \(overview.lightNumMinutes) 分钟 (\(String(format: "%.1f", Double(overview.lightRatio) / 100))%)")
//        BDLogger.info("👁 眼动(REM): \(overview.remNumMinutes) 分钟 (\(String(format: "%.1f", Double(overview.remRatio) / 100))%)")
//        BDLogger.info("⏰ 清醒: \(overview.wakeNumMinutes) 分钟 (\(String(format: "%.1f", Double(overview.wakeRatio) / 100))%)")
//
//        BDLogger.info("\n📊 有效数据点数: \(overview.numEpochs) 个")
//        BDLogger.info("===============================\n")
//
//        // 显示提示
//        let message = """
//        睡眠评分: \(overview.score)分
//        睡眠效率: \(String(format: "%.1f", Double(overview.efficiency) / 100))%
//        深睡: \(overview.deepNumMinutes)分钟
//        浅睡: \(overview.lightNumMinutes)分钟
//        """
//        QMUITips.show(withText: message, in: view, hideAfterDelay: 3.0)
//    }
//
//    /// 分析完整的睡眠数据
//    private func analyzeSleepData(overview: BCLGoMoreSleepDataResponse.SleepOverview?, stages: [Int8]) {
//        guard let overview = overview else {
//            BDLogger.warning("缺少睡眠总览数据，无法进行完整分析")
//            return
//        }
//
//        BDLogger.info("\n========== GoMore睡眠分析报告 ==========")
//
//        // 分期数据统计
//        let wakeCount = stages.filter { $0 == 0 }.count
//        let remCount = stages.filter { $0 == 1 }.count
//        let lightCount = stages.filter { $0 == 2 }.count
//        let deepCount = stages.filter { $0 == 3 }.count
//
//        BDLogger.info("📈 睡眠分期统计（每个分期30秒）：")
//        BDLogger.info("   总分期数: \(stages.count)")
//        BDLogger.info("   清醒: \(wakeCount) 个 (\(wakeCount / 2) 分钟)")
//        BDLogger.info("   眼动: \(remCount) 个 (\(remCount / 2) 分钟)")
//        BDLogger.info("   浅睡: \(lightCount) 个 (\(lightCount / 2) 分钟)")
//        BDLogger.info("   深睡: \(deepCount) 个 (\(deepCount / 2) 分钟)")
//
//        // 分析睡眠结构
//        BDLogger.info("\n🔍 睡眠结构分析：")
//
//        // 计算睡眠周期（简化算法）
//        var cycles = 0
//        var inDeepSleep = false
//        for stage in stages {
//            if stage == 3 { // 深睡
//                if !inDeepSleep {
//                    cycles += 1
//                    inDeepSleep = true
//                }
//            } else if stage == 1 { // REM
//                inDeepSleep = false
//            }
//        }
//        BDLogger.info("   估计睡眠周期数: \(cycles)")
//
//        // 计算最长连续深睡
//        var maxDeepSleep = 0
//        var currentDeepSleep = 0
//        for stage in stages {
//            if stage == 3 {
//                currentDeepSleep += 1
//                maxDeepSleep = max(maxDeepSleep, currentDeepSleep)
//            } else {
//                currentDeepSleep = 0
//            }
//        }
//        BDLogger.info("   最长连续深睡: \(maxDeepSleep / 2) 分钟")
//
//        // 生成简化的睡眠图表（控制台版）
//        BDLogger.info("\n📊 睡眠阶段变化图（每个符号代表30分钟）：")
//        var chart = "   "
//        for i in stride(from: 0, to: stages.count, by: 60) { // 每60个分期（30分钟）显示一个符号
//            let endIndex = min(i + 60, stages.count)
//            let segment = stages[i ..< endIndex]
//
//            // 统计这30分钟内的主要状态
//            var stageCounts = [0, 0, 0, 0]
//            for stage in segment {
//                if stage >= 0 && stage < 4 {
//                    stageCounts[Int(stage)] += 1
//                }
//            }
//
//            // 找出占比最多的状态
//            if let maxCount = stageCounts.max(),
//               let dominantStage = stageCounts.firstIndex(of: maxCount) {
//                switch dominantStage {
//                case 0: chart += "W" // Wake
//                case 1: chart += "R" // REM
//                case 2: chart += "L" // Light
//                case 3: chart += "D" // Deep
//                default: chart += "?"
//                }
//            }
//        }
//        BDLogger.info(chart)
//        BDLogger.info("   (W=清醒 R=眼动 L=浅睡 D=深睡)")
//
//        // 睡眠质量评价
//        BDLogger.info("\n💡 睡眠质量评价：")
//        if overview.score >= 80 {
//            BDLogger.info("   睡眠质量优秀！继续保持良好的睡眠习惯。")
//        } else if overview.score >= 60 {
//            BDLogger.info("   睡眠质量良好，可以尝试改善睡眠环境。")
//        } else if overview.score >= 40 {
//            BDLogger.info("   睡眠质量一般，建议调整作息时间。")
//        } else {
//            BDLogger.info("   睡眠质量较差，建议改善睡眠习惯并咨询专业人士。")
//        }
//
//        BDLogger.info("\n====================================\n")
//
//        // 显示分析完成提示
//        QMUITips.showSucceed("睡眠数据分析完成", in: view, hideAfterDelay: 2.0)
//    }
//

//    /// 开始录音
//    func ringStartRecordingExample() {
//        BCLRingManager.shared.ringStartRecording(isOpen: true) { result in
//            switch result {
//            case let .success(response):
//                if response.status == 1 {
//                    BDLogger.info("录音已开启")
//                } else {
//                    BDLogger.error("录音开启失败")
//                }
//            case let .failure(error):
//                BDLogger.error("错误：\(error)")
//            }
//        }
//    }
//
//    /// 停止录音
//    func ringStopRecordingExample() {
//        BCLRingManager.shared.ringStartRecording(isOpen: false) { result in
//            switch result {
//            case let .success(response):
//                if response.status == 1 {
//                    BDLogger.info("录音已停止")
//                } else {
//                    BDLogger.error("录音停止失败")
//                }
//            case let .failure(error):
//                BDLogger.error("错误：\(error)")
//            }
//        }
//    }
