//
//  Main_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/3/18.
//

import BCLRingSDK
import QMUIKit
import RxSwift
import UIKit

/// 固件升级类型
public enum FirmwareUpgradeType {
    case apollo // 阿波罗（Ambiq）升级
    case nordic // Nordic DFU 升级
    case phy // Phy 固件升级
}

class Main_VC: UIViewController {
    //  蓝牙设备列表页面
    private lazy var deviceTableVC: DeviceTableVC = {
        let vc = DeviceTableVC()
        return vc
    }()

    // LogVC
    private lazy var logVC: Log_VC = {
        let vc = Log_VC()
        return vc
    }()

    @IBOutlet var reconnect_Btn: UIButton!

    @IBOutlet var name_Label: UILabel!
    @IBOutlet var mac_Label: UILabel!
    @IBOutlet var connect_Label: UILabel!
    @IBOutlet var rssi_Label: UILabel!
    private let disposeBag = DisposeBag()
    // 历史数据
    private var historyData: [BCLRingDBModel] = []

    // 血压波形数据
    private var bloodPressureWaveData: [(Int, Int, Int, Int, Int)] = []
    private var curFirmwareUpgradeType: FirmwareUpgradeType = .apollo

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        // 蓝牙状态
        BCLRingManager.shared.systemBluetoothStateBlock = { state in
            if state == .poweredOn {
                BDLogger.info("系统蓝牙已打开")
            } else {
                BDLogger.info("系统蓝牙不可用")
            }
        }

        // 电量推送
        BCLRingManager.shared.batteryNotifyBlock = { batteryLevel in
            BDLogger.info("电量推送Block: \(batteryLevel)")
        }

//        //  蓝牙设备连接状态Block
//        BCLRingManager.shared.bluetoothConnectStateBlock = { state in
//            switch state {
//            case .connecting:
//                self.name_Label.text = "设备名称："
//                self.mac_Label.text = "MAC地址："
//                self.connect_Label.text = "连接状态：连接中..."
//                self.rssi_Label.text = "RSSI："
//                break
//            case .characteristicProcessingCompleted:
//                let deviceInfo = BCLRingManager.shared.currentConnectedDevice
//                guard let deviceInfo = deviceInfo else {
//                    self.name_Label.text = "设备名称："
//                    self.mac_Label.text = "MAC地址："
//                    self.connect_Label.text = "连接状态：未连接"
//                    self.rssi_Label.text = "RSSI："
//                    return
//                }
//                self.name_Label.text = "设备名称：\(deviceInfo.peripheralName ?? "")"
//                self.mac_Label.text = "MAC地址：\(deviceInfo.macAddress ?? "")"
//                self.connect_Label.text = "连接状态：已连接"
//                self.rssi_Label.text = "RSSI：\(deviceInfo.rssi ?? 0)"
//                break
//            default:
//                self.name_Label.text = "设备名称："
//                self.mac_Label.text = "MAC地址："
//                self.connect_Label.text = "连接状态：未连接"
//                self.rssi_Label.text = "RSSI："
//                break
//            }
//        }

        //  蓝牙设备连接状态
        BCLRingManager.shared.bluetoothConnectStateObservable.subscribe(onNext: { state in
            switch state {
            case .connecting:
                self.name_Label.text = "设备名称："
                self.mac_Label.text = "MAC地址："
                self.connect_Label.text = "连接状态：连接中..."
                self.rssi_Label.text = "RSSI："
                break
            case .characteristicProcessingCompleted:
                let deviceInfo = BCLRingManager.shared.currentConnectedDevice
                if let advertisementData = deviceInfo?.advertisementData as? [String: Any] {
                    BDLogger.info("广播数据：\(advertisementData)")
                }
                if let advDataManufacturerData = deviceInfo?.advDataManufacturerData as? Data {
                    BDLogger.info("蓝牙制造商数据：\(advDataManufacturerData)")
                    let hexString = advDataManufacturerData.map { String(format: "%02X", $0) }.joined()
                    BDLogger.info("蓝牙制造商数据（Hex）：\(hexString)")
                }
                BDLogger.info("蓝牙广播协议中充电指示位：\(deviceInfo?.chargingIndicator ?? 0)")
                BDLogger.info("蓝牙广播协议中绑定指示位：\(deviceInfo?.bindingIndicatorBit ?? 0)")
                BDLogger.info("蓝牙广播协议中通讯协议版本号：\(deviceInfo?.communicationProtocolVersion ?? 0)")
                guard let deviceInfo = deviceInfo else {
                    self.name_Label.text = "设备名称："
                    self.mac_Label.text = "MAC地址："
                    self.connect_Label.text = "连接状态：未连接"
                    self.rssi_Label.text = "RSSI："
                    return
                }
                self.name_Label.text = "设备名称：\(deviceInfo.peripheralName ?? "")"
                self.mac_Label.text = "MAC地址：\(deviceInfo.macAddress ?? "")"
                self.connect_Label.text = "连接状态：已连接"
                self.rssi_Label.text = "RSSI：\(deviceInfo.rssi ?? 0)"
                break
            default:
                self.name_Label.text = "设备名称："
                self.mac_Label.text = "MAC地址："
                self.connect_Label.text = "连接状态：未连接"
                self.rssi_Label.text = "RSSI："
                break
            }
        }).disposed(by: disposeBag)

        //  已连接的蓝牙设备信息
        BCLRingManager.shared.connectedPeripheralDeviceInfoObservable.subscribe(onNext: { deviceInfo in
            BDLogger.info("已连接的蓝牙设备信息: \(String(describing: deviceInfo))")
        }).disposed(by: disposeBag)
    }

    // MARK: - IBAction

    @IBAction func logAction(_ sender: UIButton) {
        navigationController?.pushViewController(logVC, animated: true)
    }

    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 100: //    搜索蓝牙设备
            navigationController?.pushViewController(deviceTableVC, animated: true)
            break
        case 101: //    断开连接
            BCLRingManager.shared.disconnect()
            break
        case 102: //    自动重连
            BCLRingManager.shared.isAutoReconnectEnabled = false
            break
        case 103: //    同步时间
            BCLRingManager.shared.syncTime { res in
                switch res {
                case .success:
                    BDLogger.info("同步时间成功")
                case let .failure(error):
                    BDLogger.error("同步时间失败: \(error)")
                }
            }
            break
        case 104: //    读取时间
            BCLRingManager.shared.readTime { res in
                switch res {
                case let .success(response):
                    BDLogger.info("timeStamp: \(response.timestamp)")
                    BDLogger.info("timeZone: \(response.ringTimeZone)")
                    BDLogger.info("utcDate: \(response.utcDate)")
                    BDLogger.info("localDate: \(response.localDate)")
                case let .failure(error):
                    BDLogger.error("读取时间失败: \(error)")
                }
            }
            break
        case 105: //    读取温度
            BCLRingManager.shared.readTemperature { result in
                switch result {
                case let .success(response):
                    if let error = response.status.error {
                        switch error {
                        case let .temperature(tempError):
                            switch tempError {
                            case .measuring:
                                BDLogger.info("测量中，请等待...")
                                BDLogger.info("温度值：\(response.temperature ?? 0)")
                            case .charging:
                                BDLogger.error("设备正在充电，无法测量")
                            case .notWearing:
                                BDLogger.error("检测未佩戴，测量失败")
                            case .invalid:
                                BDLogger.error("无效数据")
                            case .busy:
                                BDLogger.error("设备繁忙")
                            }
                        default:
                            BDLogger.error("读取温度失败: \(error)")
                        }
                    } else if let temperature = response.temperature {
                        BDLogger.info("测量完成，温度：\(String(format: "%.2f", Double(temperature) * 0.01))℃")
                    } else {
                        BDLogger.error("无效的温度数据")
                    }
                case let .failure(error):
                    // 处理连接错误等其他错误
                    BDLogger.error("读取温度失败: \(error)")
                }
            }
            break
        case 106: //    实时步数
            BCLRingManager.shared.readStepCount { result in
                switch result {
                case let .success(response):
                    BDLogger.info("实时步数: \(response.stepCount)")
                case let .failure(error):
                    BDLogger.error("读取实时步数失败: \(error)")
                }
            }
            break
        case 107: //    清除步数
            BCLRingManager.shared.clearStepCount { result in
                switch result {
                case .success:
                    BDLogger.info("清除步数成功")
                case let .failure(error):
                    BDLogger.error("清除步数失败: \(error)")
                }
            }
            break
        case 108: //    获取电量（主动）
            BCLRingManager.shared.readBattery { res in
                switch res {
                case let .success(response):
                    BDLogger.info("电量: \(response.batteryLevel)")
                case let .failure(error):
                    BDLogger.error("读取电量失败: \(error)")
                }
            }
            break
        case 109: //    获取电量（被动）
            BCLRingManager.shared.batteryNotifyObservable.subscribe(onNext: { batteryLevel in
                BDLogger.info("电量推送订阅: \(batteryLevel)")
            }).disposed(by: disposeBag)

            BCLRingManager.shared.batteryNotifyBlock = { batteryLevel in
                BDLogger.info("电量推送Block: \(batteryLevel)")
            }

            break
        case 110: //    充电状态
            BCLRingManager.shared.readChargingState { res in
                switch res {
                case let .success(response):
                    BDLogger.info("充电状态: \(response.chargingState)")
                case let .failure(error):
                    BDLogger.error("读取充电状态失败: \(error)")
                }
            }
            break
        case 111: //    血氧
            startBloodOxygenMeasurement()
            break
        case 112: //    心率
            startHeartRateMeasurement()
            break
        case 113: //    心率变异性
            startHeartRateVariabilityMeasurement()
            break
        case 114: //    获取全部数据
            readAllHistoryData()
            break
        case 115: //    读取未上传记录
            readUnUploadData()
            break
        case 116: //    恢复出厂设置
            BCLRingManager.shared.restoreFactorySettings { res in
                switch res {
                case .success:
                    BDLogger.info("恢复出厂设置成功")
                case let .failure(error):
                    BDLogger.error("恢复出厂设置失败: \(error)")
                }
            }
            break
        case 117: //    硬件版本
            BCLRingManager.shared.readHardware { res in
                switch res {
                case let .success(response):
                    BDLogger.info("硬件版本: \(response.hardwareVersion)")
                case let .failure(error):
                    BDLogger.error("读取硬件版本失败: \(error)")
                }
            }
            break
        case 118: //    固件版本
            BCLRingManager.shared.readFirmware { res in
                switch res {
                case let .success(response):
                    BDLogger.info("固件版本: \(response.firmwareVersion)")
                case let .failure(error):
                    BDLogger.error("读取固件版本失败: \(error)")
                }
            }
            break
        case 119: //    设置采集周期
            BCLRingManager.shared.setCollectPeriod(period: 900) { res in
                switch res {
                case let .success(response):
                    BDLogger.info("设置采集周期状态: \(response.success)")
                case let .failure(error):
                    BDLogger.error("设置采集周期失败: \(error)")
                }
            }
            break
        case 120: //    读取采集周期
            BCLRingManager.shared.getCollectPeriod { res in
                switch res {
                case let .success(response):
                    BDLogger.info("采集周期: \(response.time)")
                case let .failure(error):
                    BDLogger.error("读取采集周期失败: \(error)")
                }
            }
            break
        case 121: //    睡眠数据
            BCLRingManager.shared.getSleepData(date: Date(), timeZone: .East8) { result in
                switch result {
                case let .success(sleepData):
                    BDLogger.info("睡眠数据: \(sleepData)")
                case let .failure(error):
                    switch error {
                    case let .network(.invalidParameters(message)):
                        BDLogger.error("❌ 参数无效，请检查API Key和用户ID: \(message)")
                    case let .network(.httpError(code)):
                        BDLogger.error("❌ HTTP错误：\(code)")
                    case let .network(.serverError(code, message)):
                        BDLogger.error("❌ 服务器错误[\(code)]: \(message)")
                    case .network(.invalidResponse):
                        BDLogger.error("❌ 响应数据无效")
                    case let .network(.decodingError(error)):
                        BDLogger.error("❌ 数据解析失败: \(error)")
                    case let .network(.networkError(message)):
                        BDLogger.error("❌ 网络错误: \(message)")
                    case let .network(.tokenError(message)):
                        BDLogger.error("❌ Token异常: \(message)")
                    default:
                        BDLogger.error("❌ 其他错误: \(error)")
                    }
                }
            }
            break
        case 122: //    获取Token
            BCLRingManager.shared.createToken(apiKey: "76d07e37bfe341b1a25c76c0e25f457a", userIdentifier: "432591@qq.com") { result in
                switch result {
                case let .success(token):
                    BDLogger.info("✅ Token获取成功：")
                    BDLogger.info("- Token: \(token)")
                case let .failure(error):
                    BDLogger.error("❌ Token获取失败：")
                    // 根据不同错误类型显示不同的错误信息
                    switch error {
                    case let .network(.invalidParameters(message)):
                        BDLogger.error("❌ 参数无效，请检查API Key和用户ID: \(message)")
                    case let .network(.httpError(code)):
                        BDLogger.error("❌ HTTP错误：\(code)")
                    case let .network(.serverError(code, message)):
                        BDLogger.error("❌ 服务器错误[\(code)]: \(message)")
                    case .network(.invalidResponse):
                        BDLogger.error("❌ 响应数据无效")
                    case let .network(.decodingError(error)):
                        BDLogger.error("❌ 数据解析失败: \(error)")
                    case let .network(.networkError(message)):
                        BDLogger.error("❌ 网络错误: \(message)")
                    case let .network(.tokenError(message)):
                        BDLogger.error("❌ Token异常: \(message)")
                    default:
                        BDLogger.error("❌ 其他错误: \(error)")
                    }
                }
            }
            break
        case 123: //    固件版本更新检查
            // 7.1.5.3Z3R / 7.1.7.0Z3R / (RH18:2.7.5.2Z3N) / 2.7.4.8Z27
            BCLRingManager.shared.checkFirmwareUpdate(version: "2.7.4.0Z27") { result in
                switch result {
                case let .success(versionInfo):
                    if versionInfo.hasNewVersion {
                        BDLogger.info("""
                        ✅ 发现新版本：
                        - 版本号：\(versionInfo.version ?? "")
                        - 下载地址：\(versionInfo.downloadUrl ?? "")
                        - 文件名：\(versionInfo.fileName ?? "")
                        """)
                    } else {
                        BDLogger.info("✅ 当前已是最新版本")
                    }
                    BDLogger.info("📝 消息：\(String(describing: versionInfo.version))")
                case let .failure(error):
                    switch error {
                    case let .network(.invalidParameters(message)):
                        BDLogger.error("❌ 参数无效，请检查版本号格式: \(message)")
                    case let .network(.httpError(code)):
                        BDLogger.error("❌ HTTP请求失败：状态码 \(code)")
                    case let .network(.serverError(code, message)):
                        BDLogger.error("❌ 服务器错误：[\(code)] \(message)")
                    case .network(.invalidResponse):
                        BDLogger.error("❌ 响应数据无效")
                    case let .network(.decodingError(error)):
                        BDLogger.error("❌ 数据解析失败：\(error.localizedDescription)")
                    case let .network(.networkError(message)):
                        BDLogger.error("❌ 网络错误：\(message)")
                    case let .network(.tokenError(message)):
                        BDLogger.error("❌ Token异常：\(message)")
                    default:
                        BDLogger.error("❌ 其他错误：\(error)")
                    }
                }
            }
            break
        case 124: //    固件文件下载
//            let fileName = "7.1.7.0Z3R.bin"
//            let downloadUrl = "https://image.lmyiot.com/FiaeMmw7OwXNwtKWoaQM2HsNhi4z"

//            let fileName = "7.1.9.2Z3R.bin"
//            let downloadUrl = "http://221.226.159.58:22222/profile/upload/2025/04/15/7.1.9.2Z3R.bin"

//            let fileName = "6.0.2.7Z2W.zip"
//            let downloadUrl = "http://221.226.159.58:22222/profile/upload/2025/04/01/6.0.3.9Z2W.zip"

//            let fileName = "2.7.4.8Z27.hex16"
//            let downloadUrl = "http://221.226.159.58:22222/profile/upload/2025/04/01/2.7.4.8Z27.hex16"

            let fileName = "2.7.4.8Z27.hex16"
            let downloadUrl = "http://221.226.159.58:22222/profile/upload/2025/04/01/2.7.4.8Z27.hex16"

            let destinationPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            BCLRingManager.shared.downloadFirmware(url: downloadUrl, fileName: fileName, destinationPath: destinationPath, progress: { progress in
                BDLogger.info("固件下载进度：\(progress)")
            }, completion: { result in
                switch result {
                case let .success(filePath):
                    BDLogger.info("固件下载成功：\(filePath)")
                case let .failure(error):
                    BDLogger.error("固件下载失败：\(error)")
                }
            })
            break
        case 125: //    实时RSSI
            //  每隔1s开始读取RSSI
            BCLRingManager.shared.startReadRSSI(interval: 1, readRSSIBlock: { result in
                switch result {
                case let .success(rssi):
                    BDLogger.info("RSSI: \(rssi)")
                    self.rssi_Label.text = "RSSI：\(rssi)"
                case let .failure(error):
                    BDLogger.error("读取RSSI失败: \(error)")
                }
            })
            break
        case 126: //    停止RSSI
            BCLRingManager.shared.stopReadRSSI()
            break
        case 127: //    设置蓝牙名称
            BCLRingManager.shared.setBluetoothName(name: "HR18") { res in
                switch res {
                case .success:
                    BDLogger.info("设置蓝牙名称成功")
                case let .failure(error):
                    BDLogger.error("设置蓝牙名称失败: \(error)")
                }
            }
            break
        case 128: //    读取蓝牙名称
            BCLRingManager.shared.getBluetoothName { res in
                switch res {
                case let .success(response):
                    BDLogger.info("蓝牙名称: \(response.name)")
                case let .failure(error):
                    BDLogger.error("读取蓝牙名称失败: \(error)")
                }
            }
            break
        case 129: //    停止血氧测量
            BCLRingManager.shared.stopBloodOxygen { res in
                switch res {
                case .success:
                    BDLogger.info("停止血氧测量成功")
                case let .failure(error):
                    BDLogger.error("停止血氧测量失败: \(error)")
                }
            }
        case 130: // 一键自检
            BCLRingManager.shared.oneKeySelfInspection { res in
                switch res {
                case let .success(response):
                    if response.hasError {
                        // 有故障情况
                        BDLogger.warning("一键自检发现设备故障: \(response.errorDescription)")
                        // 针对特定故障处理示例
                        if response.hasPPGLedError {
                            BDLogger.error("PPG LED 故障，需要维修")
                        }
                        // 获取完整错误码
                        BDLogger.debug("故障码: 0x\(String(format: "%04X", response.errorCode))")
                    } else {
                        // 无故障情况
                        BDLogger.info("一键自检成功，设备正常")
                    }
                case let .failure(error):
                    // 自检操作本身失败
                    BDLogger.error("一键自检操作失败: \(error)")
                }
            }
        case 131: // APP事件-绑定戒指
            BCLRingManager.shared.appEventBindRing(date: Date(), timeZone: .East8) { res in
                switch res {
                case let .success(response):
                    BDLogger.info("绑定戒指成功: \(response)")
                    BDLogger.info("固件版本: \(response.firmwareVersion)")
                    BDLogger.info("硬件版本: \(response.hardwareVersion)")
                    BDLogger.info("电量: \(response.batteryLevel)")
                    BDLogger.info("充电状态: \(response.chargingState)")
                    BDLogger.info("采集间隔: \(response.collectInterval)")
                    BDLogger.info("计步: \(response.stepCount)")
                    BDLogger.info("自检标志：\(response.selfInspectionFlag)")
                    BDLogger.info("自检是否有错误：\(response.hasSelfInspectionError)")
                    BDLogger.info("自检错误描述：\(response.selfInspectionErrorDescription)")
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
                case let .failure(error):
                    switch error {
                    case let .responseParsing(reason):
                        BDLogger.error("绑定戒指响应解析失败: \(reason.localizedDescription)")
                    default:
                        BDLogger.error("绑定戒指失败: \(error)")
                    }
                }
            }
        case 132: // APP事件-连接戒指
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
                    self.historyData = models
                },
                onError: { error in
                    BDLogger.error("连接戒指-历史数据同步出错：\(error.localizedDescription)")
                }
            )
            BCLRingManager.shared.appEventConnectRing(date: Date(), timeZone: .East8, callbacks: callbacks) { res in
                switch res {
                case let .success(response):
                    BDLogger.info("连接戒指成功: \(response)")
                    BDLogger.info("固件版本: \(response.firmwareVersion)")
                    BDLogger.info("硬件版本: \(response.hardwareVersion)")
                    BDLogger.info("电量: \(response.batteryLevel)")
                    BDLogger.info("充电状态: \(response.chargingState)")
                    BDLogger.info("采集间隔: \(response.collectInterval)")
                    BDLogger.info("计步: \(response.stepCount)")
                    BDLogger.info("自检标志：\(response.selfInspectionFlag)")
                    BDLogger.info("自检是否有错误：\(response.hasSelfInspectionError)")
                    BDLogger.info("自检错误描述：\(response.selfInspectionErrorDescription)")
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
                case let .failure(error):
                    BDLogger.error("连接戒指失败: \(error)")
                }
            }
        case 133: // APP事件-刷新戒指
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
                    self.historyData = models
                },
                onError: { error in
                    BDLogger.error("刷新戒指-历史数据同步出错：\(error.localizedDescription)")
                }
            )

            BCLRingManager.shared.appEventRefreshRing(date: Date(), timeZone: .East8, callbacks: callbacks) { res in
                switch res {
                case let .success(response):
                    BDLogger.info("刷新戒指成功: \(response)")
                    BDLogger.info("固件版本: \(response.firmwareVersion)")
                    BDLogger.info("硬件版本: \(response.hardwareVersion)")
                    BDLogger.info("电量: \(response.batteryLevel)")
                    BDLogger.info("充电状态: \(response.chargingState)")
                    BDLogger.info("采集间隔: \(response.collectInterval)")
                    BDLogger.info("计步: \(response.stepCount)")
                    BDLogger.info("自检标志：\(response.selfInspectionFlag)")
                    BDLogger.info("自检是否有错误：\(response.hasSelfInspectionError)")
                    BDLogger.info("自检错误描述：\(response.selfInspectionErrorDescription)")
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
                case let .failure(error):
                    BDLogger.error("刷新戒指失败: \(error)")
                }
            }
        case 134: // 获取HID功能码
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
                }
            }
        case 135: // 获取当前HID模式
            BCLRingManager.shared.getCurrentHIDMode { res in
                switch res {
                case let .success(response):
                    BDLogger.info("获取当前HID模式成功: \(response)")
                    BDLogger.info("触摸模式: \(response.touchHIDMode)")
                    BDLogger.info("手势模式: \(response.gestureHIDMode)")
                    BDLogger.info("系统类型: \(response.systemType)")
                case let .failure(error):
                    BDLogger.error("获取当前HID模式失败: \(error)")
                }
            }
        case 136: // 上传历史记录
            guard let device = BCLRingManager.shared.currentConnectedDevice else {
                BDLogger.error("请连接蓝牙设备")
                QMUITips.show(withText: "请连接蓝牙设备", in: view, hideAfterDelay: 2)
                return
            }
            guard let mac = device.macAddress else {
                BDLogger.error("设备MAC地址为空")
                QMUITips.show(withText: "设备MAC地址为空", in: view, hideAfterDelay: 2)
                return
            }

            guard !historyData.isEmpty else {
                BDLogger.error("历史数据为空")
                QMUITips.show(withText: "历史数据为空", in: view, hideAfterDelay: 2)
                return
            }
            BCLRingManager.shared.uploadHistory(historyData: historyData, mac: mac) { res in
                switch res {
                case let .success(response):
                    BDLogger.info("上传历史记录成功: \(response)")
                case let .failure(error):
                    switch error {
                    case let .network(networkError):
                        switch networkError {
                        case .tokenError:
                            BDLogger.error("Token错误,需要重新获取Token")
                        case let .serverError(code, message):
                            BDLogger.error("服务器错误: \(code), \(message)")
                        default:
                            BDLogger.error("上传失败: \(error)")
                        }
                    default:
                        BDLogger.error("上传失败: \(error)")
                    }
                }
            }
        case 137: // 通讯回环测试
            // 设置测试时长为2分钟
            let duration = 2 * 60
            // 设置测试间隔为1秒
            let interval = 1.0
            // 记录开始时间
            let startTime = Date()
            // 计算结束时间
            let endTime = startTime.addingTimeInterval(TimeInterval(duration))
            // 创建计时器，每秒执行一次测试
            var timer: Timer?
            // 计算剩余时间
            var remainingSeconds = duration
            // 创建并启动定时器
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] t in
                guard let self = self else {
                    t.invalidate()
                    return
                }
                // 执行通讯回环测试
                BCLRingManager.shared.communicationLoopRateTest(dataLength: 2) { res in
                    switch res {
                    case let .success(response):
                        BDLogger.info("通讯回环测试成功: \(response)")
                    case let .failure(error):
                        BDLogger.error("通讯回环测试失败: \(error)")
                    }
                }
                // 更新剩余时间
                remainingSeconds -= Int(interval)
                // 更新UI
                DispatchQueue.main.async {
                    if let button = self.view.viewWithTag(137) as? UIButton {
                        button.setTitle("通讯回环测试中... 剩余\(remainingSeconds)秒", for: .normal)
                        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
                    }
                }
                // 检查是否达到结束时间
                if Date() >= endTime {
                    t.invalidate()
                    timer = nil
                    // 测试完成后更新UI
                    DispatchQueue.main.async {
                        if let button = self.view.viewWithTag(137) as? UIButton {
                            button.setTitle("通讯回环测试", for: .normal)
                            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                        }
                    }
                    BDLogger.info("通讯回环测试完成")
                }
            }
        case 138: // Apollo固件升级
            curFirmwareUpgradeType = .apollo
            // 实现打开文件选择器
            let filePicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
            filePicker.delegate = self
            filePicker.allowsMultipleSelection = false
            present(filePicker, animated: true, completion: nil)
            break
        case 139: // 停止Apollo固件升级
            BCLRingManager.shared.stopApolloUpgrade()
            break
        case 140: // Nordic 固件升级
            curFirmwareUpgradeType = .nordic
            // 实现打开文件选择器
            let filePicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
            filePicker.delegate = self
            filePicker.allowsMultipleSelection = false
            present(filePicker, animated: true, completion: nil)
            break
        case 141: // Phy 固件升级
            curFirmwareUpgradeType = .phy
            // 实现打开文件选择器
            let filePicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
            filePicker.delegate = self
            filePicker.allowsMultipleSelection = false
            present(filePicker, animated: true, completion: nil)
            break
        case 142: // 血压测量
            bloodPressureWaveData = []
            // 设置回调
            BCLBloodPressureResponse.setCallbacks(BCLBloodPressureCallbacks(
                onProgress: { progress in
                    // 更新进度UI
                    BDLogger.info("测量进度: \(progress)%")
                },
                onStatusChanged: { status in
                    switch status {
                    case .completed:
                        BDLogger.info("测量完成")
                    case .measuring:
                        BDLogger.info("测量中...")
                    case .busy:
                        BDLogger.error("设备正忙，无法开始测量")
                    case .notWearing:
                        BDLogger.error("设备未佩戴，请先佩戴设备")
                    case .dataCollectionTimeout:
                        BDLogger.error("数据采集超时")
                    default:
                        break
                    }
                },
                onMeasureValue: { heartRate, systolicPressure, diastolicPressure in
                    BDLogger.info("心率: \(heartRate ?? 0)次/分")
                    BDLogger.info("收缩压: \(systolicPressure ?? 0)")
                    BDLogger.info("舒张压: \(diastolicPressure ?? 0)")
                },
                onWaveform: { seq, num, datas in
                    // 处理波形数据
                    BDLogger.info("波形数据: 序号\(seq), 数量\(num)")
                    switch datas {
                    case let .redAndInfrared(waveData):
                        BDLogger.info("波形数据: \(waveData)")
                        // 将波形数据添加到数组中
                        self.bloodPressureWaveData.append(contentsOf: waveData)
                    default:
                        BDLogger.error("不支持的波形数据类型")
                    }
                },
                onError: { error in
                    BDLogger.info("错误: \(error)")
                }
            ))

            // 开始测量
            BCLRingManager.shared.startBloodPressure(collectTime: 30, waveformConfig: 1, progressConfig: 1, waveformSetting: 0) { result in
                switch result {
                case .success:
                    break
                case let .failure(error):
                    BDLogger.error("启动心率测量失败: \(error)")
                    // 发生错误时清理回调
                    BCLHeartRateResponse.cleanupCurrentMeasurement()
                }
            }
            break
        case 143: // 停止血压测量
            BCLRingManager.shared.stopBloodPressure { res in
                switch res {
                case .success:
                    BDLogger.info("停止血压测量成功")
                case let .failure(error):
                    BDLogger.error("停止血压测量失败: \(error)")
                }
            }
            break
        case 144: // 血压数据上传
            let macAddress = BCLRingManager.shared.currentConnectedDevice?.macAddress ?? ""
            BCLRingManager.shared.uploadBloodPressureData(mac: macAddress, waveData: bloodPressureWaveData) { res in
                switch res {
                case let .success(data):
                    BDLogger.info("收缩压：\(data.0)、舒张压：\(data.1)")
                case let .failure(error):
                    BDLogger.error("数据计算失败: \(error.localizedDescription)")
                }
            }
            break
        case 145: // 日志压缩
            QMUITips.showLoading(in: view)
            BCLRingManager.shared.compressLogAndDataFiles { res in
                QMUITips.hideAllTips()
                switch res {
                case let .success(result):
                    BDLogger.info("文件路径：\(result.0)")
                    BDLogger.info("文件：\(result.1)")
                case let .failure(error):
                    BDLogger.error("压缩文件失败：\(error)")
                }
            }
            break
        case 146: // 清理压缩文件
            BCLRingManager.shared.cleanCompressedFiles { res in
                switch res {
                case .success:
                    BDLogger.info("清理压缩文件成功")
                case let .failure(error):
                    BDLogger.error("清理压缩文件失败: \(error)")
                }
            }
            break
        case 147: // 刷新Token
            BCLRingManager.shared.refreshToken { res in
                switch res {
                case .success:
                    BDLogger.info("刷新Token成功")
                case let .failure(error):
                    switch error {
                    case let .network(.tokenError(message)):
                        // 处理 Token 错误
                        BDLogger.error("Token已失效，需要重新登录: \(message)")
                    default:
                        // 处理其他错误
                        BDLogger.error("刷新Token失败: \(error)")
                    }
                }
            }
            break
        case 148: // SDK本地计算睡眠数据
            BDLogger.info("使用SDK内置计算睡眠数据方法获取睡眠数据")
            let date = Date("2025-05-09", format: "yyyy-MM-dd")
            // BCLRingLocalSleepModel
            let sleepModel = BCLRingManager.shared.calculateSleepLocally(targetDate: date!, macString: nil)
            BDLogger.info("睡眠数据\(sleepModel.description)")
            break
        case 149: // 停止心率测量
            BDLogger.info("停止心率测量")
            BCLRingManager.shared.stopHeartRate { res in
                switch res {
                case .success:
                    BDLogger.info("停止心率测量成功")
                case let .failure(error):
                    BDLogger.error("停止心率测量失败: \(error)")
                }
            }
            break
        case 150: // PPG波形透传输
            BDLogger.info("开始-PPG波形透传输")
            let waveSetting = 0
            BCLRingManager.shared.ppgWaveFormMeasurement(collectTime: 30, waveConfig: 0, progressConfig: 0, waveSetting: waveSetting) { res in
                switch res {
                case let .success(response):
                    BDLogger.info("PPG波形透传输成功: \(response)")
                    BDLogger.info("PPG波形透传输进度: \(String(describing: response.progressData))")
                    BDLogger.info("PPG波形透传输-心率: \(String(describing: response.heartRate))")
                    BDLogger.info("PPG波形透传输-血氧: \(String(describing: response.oxygen))")
                    if waveSetting == 0 {
                        if let waveData = response.waveform0 {
                            BDLogger.info("波形数据: 序号\(waveData.0), 数量\(waveData.1)")
                            BDLogger.info("波形数据-绿色: \(waveData.2)")
                        }
                    } else if waveSetting == 1 {
                        if let waveData = response.waveform1 {
                            BDLogger.info("波形数据: 序号\(waveData.0), 数量\(waveData.1)")
                            BDLogger.info("波形数据-(绿色+红外): \(waveData.2)")
                        }
                    } else if waveSetting == 2 {
                        BDLogger.info("PPG波形透传输-佩戴检测")
                    }
                    break
                case let .failure(error):
                    BDLogger.error("PPG波形透传输失败: \(error)")
                    break
                }
            }
            break
        case 151: // PPG波形透传输停止
            BDLogger.info("停止-PPG波形透传输")
            BCLRingManager.shared.ppgWaveFormStop { res in
                switch res {
                case .success:
                    BDLogger.info("停止PPG波形透传输成功")
                case let .failure(error):
                    BDLogger.error("停止PPG波形透传输失败: \(error)")
                }
            }
            break
        case 152: // 六轴-加速度-单次
            BDLogger.info("六轴-加速度-单次")
            BCLRingManager.shared.getSixAxisAccelerationData { res in
                switch res {
                case let .success(data):
                    BDLogger.info("六轴-加速度-单次数据: \(data)")
                    BDLogger.info("六轴-加速度-单次数据-状态: \(data.status ?? 0)")
                    BDLogger.info("六轴-加速度-单次数据-X: \(data.xAcceleration ?? 0)")
                    BDLogger.info("六轴-加速度-单次数据-Y: \(data.yAcceleration ?? 0)")
                    BDLogger.info("六轴-加速度-单次数据-Z: \(data.zAcceleration ?? 0)")
                case let .failure(error):
                    BDLogger.error("六轴-加速度-单次数据失败: \(error)")
                }
            }
            break
        case 153: // 六轴-陀螺仪-单次
            BDLogger.info("六轴-陀螺仪-单次")
            BCLRingManager.shared.getSixAxisGyroscopeData { res in
                switch res {
                case let .success(data):
                    BDLogger.info("六轴-陀螺仪-单次数据: \(data)")
                    BDLogger.info("六轴-陀螺仪-单次数据-状态: \(data.status ?? 0)")
                    BDLogger.info("六轴-陀螺仪-单次数据-X: \(data.xGyroscope ?? 0)")
                    BDLogger.info("六轴-陀螺仪-单次数据-Y: \(data.yGyroscope ?? 0)")
                    BDLogger.info("六轴-陀螺仪-单次数据-Z: \(data.zGyroscope ?? 0)")
                case let .failure(error):
                    BDLogger.error("六轴-陀螺仪-单次数据失败: \(error)")
                }
            }
            break
        case 154: // 六轴-加速度、陀螺仪-单次
            BDLogger.info("六轴-加速度、陀螺仪-单次")
            BCLRingManager.shared.getSixAxisAccelerationAndGyroscopeData { res in
                switch res {
                case let .success(data):
                    BDLogger.info("六轴-加速度、陀螺仪-单次数据: \(data)")
                    BDLogger.info("六轴-加速度、陀螺仪-单次数据-状态: \(data.status ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-单次数据-xAcceleration: \(data.xAcceleration ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-单次数据-yAcceleration: \(data.yAcceleration ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-单次数据-zAcceleration: \(data.zAcceleration ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-单次数据-xGyroscope: \(data.xGyroscope ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-单次数据-yGyroscope: \(data.yGyroscope ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-单次数据-zGyroscope: \(data.zGyroscope ?? 0)")
                case let .failure(error):
                    BDLogger.error("六轴-加速度、陀螺仪-单次数据失败: \(error)")
                }
            }
            break
        case 155: // 六轴-加速度-持续
            BDLogger.info("六轴-加速度-持续")
            BCLRingManager.shared.getSixAxisRealTimeAccelerationData { res in
                switch res {
                case let .success(data):
                    BDLogger.info("六轴-加速度-持续数据: \(data)")
                    BDLogger.info("六轴-加速度-持续数据-状态: \(data.status ?? 0)")
                    BDLogger.info("六轴-加速度-持续数据-X: \(data.xAcceleration ?? 0)")
                    BDLogger.info("六轴-加速度-持续数据-Y: \(data.yAcceleration ?? 0)")
                    BDLogger.info("六轴-加速度-持续数据-Z: \(data.zAcceleration ?? 0)")
                case let .failure(error):
                    BDLogger.error("六轴-加速度-持续数据失败: \(error)")
                }
            }
            break
        case 156: // 六轴-陀螺仪-持续
            BDLogger.info("六轴-陀螺仪-持续")
            BCLRingManager.shared.getSixAxisRealTimeGyroscopeData { res in
                switch res {
                case let .success(data):
                    BDLogger.info("六轴-陀螺仪-持续数据: \(data)")
                    BDLogger.info("六轴-陀螺仪-持续数据-状态: \(data.status ?? 0)")
                    BDLogger.info("六轴-陀螺仪-持续数据-X: \(data.xGyroscope ?? 0)")
                    BDLogger.info("六轴-陀螺仪-持续数据-Y: \(data.yGyroscope ?? 0)")
                    BDLogger.info("六轴-陀螺仪-持续数据-Z: \(data.zGyroscope ?? 0)")
                case let .failure(error):
                    BDLogger.error("六轴-陀螺仪-持续数据失败: \(error)")
                }
            }
            break
        case 157: // 六轴-加速度、陀螺仪-持续
            BDLogger.info("六轴-加速度、陀螺仪-持续")
            BCLRingManager.shared.getSixAxisRealTimeAccelerationAndGyroscopeData { res in
                switch res {
                case let .success(data):
                    BDLogger.info("六轴-加速度、陀螺仪-持续数据: \(data)")
                    BDLogger.info("六轴-加速度、陀螺仪-持续数据-状态: \(data.status ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-持续数据-xAcceleration: \(data.xAcceleration ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-持续数据-yAcceleration: \(data.yAcceleration ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-持续数据-zAcceleration: \(data.zAcceleration ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-持续数据-xGyroscope: \(data.xGyroscope ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-持续数据-yGyroscope: \(data.yGyroscope ?? 0)")
                    BDLogger.info("六轴-加速度、陀螺仪-持续数据-zGyroscope: \(data.zGyroscope ?? 0)")
                case let .failure(error):
                    BDLogger.error("六轴-加速度、陀螺仪-持续数据失败: \(error)")
                }
            }
            break
        case 158: // 六轴-停止测量
            BDLogger.info("六轴-停止测量")
            BCLRingManager.shared.stopSixAxisData { res in
                switch res {
                case .success:
                    BDLogger.info("停止采集获取六轴数据成功")
                case let .failure(error):
                    BDLogger.error("停止采集获取六轴数据失败: \(error)")
                }
            }
            break
        case 159: // 设置六轴传感器工作频率 (暂不支持分开设置，需保证加速度、陀螺仪频率一致)
            BDLogger.info("设置六轴传感器工作频率")
            // 频率25hz，50hz，100hz，150hz，200hz
            BCLRingManager.shared.setSixAxisWorkFrequency(accelerationFrequency: 25, gyroscopeFrequency: 25) { res in
                switch res {
                case let .success(response):
                    BDLogger.info("设置六轴传感器工作频率返回数据: \(response)")
                    if let status = response.status, status == 1 {
                        BDLogger.info("设置六轴传感器工作频率成功")
                    } else {
                        BDLogger.info("设置六轴传感器工作频率失败")
                    }
                case let .failure(error):
                    BDLogger.error("设置六轴传感器工作频率失败: \(error)")
                }
            }

            break
        case 160: // 获取六轴传感器工作频率
            BDLogger.info("获取六轴传感器工作频率")
            BCLRingManager.shared.getSixAxisWorkFrequency { res in
                switch res {
                case let .success(response):
                    BDLogger.info("获取六轴传感器工作频率返回数据: \(response)")
                    BDLogger.info("加速度频率: \(response.accelerationFrequency ?? 0)")
                    BDLogger.info("陀螺仪频率: \(response.gyroscopeFrequency ?? 0)")
                case let .failure(error):
                    BDLogger.error("获取六轴传感器工作频率失败: \(error)")
                }
            }
            break
        case 161: // 设置六轴传感器省电模式
            BDLogger.info("设置六轴传感器省电模式")
            BCLRingManager.shared.setSixAxisPowerSavingMode { res in
                switch res {
                case let .success(response):
                    BDLogger.info("设置六轴传感器省电模式返回数据: \(response)")
                    if let status = response.status, status == 1 {
                        BDLogger.info("设置六轴传感器省电模式-成功")
                    } else {
                        BDLogger.info("设置六轴传感器省电模式-失败")
                    }
                case let .failure(error):
                    BDLogger.error("设置六轴传感器省电模式失败: \(error)")
                }
            }
            break
        case 162: // 批量获取睡眠数据
            BDLogger.info("批量获取睡眠数据")
            let dates = ["2025-05-01", "2025-05-02", "2025-05-03", "2025-05-04", "2025-05-05", "2025-05-06", "2025-05-07", "2025-05-08", "2025-05-09", "2025-05-10", "2025-05-11", "2025-05-12", "2025-05-13"]
            BCLRingManager.shared.getSleepDataByTimeRange(datas: dates) { res in
                switch res {
                case let .success(datas):
                    BDLogger.info("批量获取睡眠数据成功: \(datas)")
                case let .failure(error):
                    BDLogger.error("批量获取睡眠数据失败: \(error)")
                }
            }
            break

        case 163: // 获取文件系统列表
            BDLogger.info("获取文件系统列表")
            BCLRingManager.shared.getFileList { res in
                switch res {
                case let .success(response):
                    BDLogger.info("获取文件系统列表成功: \(response)")
                    BDLogger.info("文件系统列表-总个数: \(response.fileTotalCount ?? 0)")
                    BDLogger.info("文件系统列表-当前索引: \(response.fileIndex ?? 0)")
                    BDLogger.info("文件系统列表-文件大小: \(response.fileSize ?? 0)")
                    BDLogger.info("文件系统列表-文件名: \(response.fileName ?? "")")
                    BDLogger.info("文件系统列表-文件类型: \(response.fileType ?? 0)")
                case let .failure(error):
                    BDLogger.error("获取文件系统列表失败: \(error)")
                }
            }
            break
        case 164: // 请求文件的数据
            BDLogger.info("请求文件的数据")
            break
        case 165: // 删除文件
            BDLogger.info("删除文件")
            break
        case 166: // 格式化文件系统
            BDLogger.info("格式化文件系统")
            break
        case 167: // 获取文件系统空间信息
            BDLogger.info("获取文件系统空间信息")
            break
        case 168: // 设置自动记录采集数据模式
            BDLogger.info("设置自动记录采集数据模式")
            break
        case 169: // 获取自动记录采集数据模式
            BDLogger.info("获取自动记录采集数据模式")
            break
        case 170: // 获取文件系统状态
            BDLogger.info("获取文件系统状态")
            break
        case 171: // 根据固件版本号，返回固件升级类型
            BDLogger.info("根据固件版本号，返回固件升级类型")
//                        let fileName = "7.1.9.2Z3R.bin"
//                        let fileName = "6.0.2.7Z2W.zip"
//                        let fileName = "2.7.4.8Z27.hex16"
            BCLRingManager.shared.getOTAType(firmwareVersion: "6.0.2.7Z2W") { response in
                BDLogger.info("固件升级类型:\(response.rawValue)")
                switch response.rawValue {
                case 0:
                    BDLogger.error("固件升级类型: 未知")
                    break
                case 1:
                    BDLogger.info("固件升级类型: Apollo")
                    // Apollo固件升级 查看以下方法
//                    func apolloUpgradeFirmware(filePath: String, progressHandler: ((Float) -> Void)? = nil, completion: @escaping (Result<Void, BCLError>) -> Void)
                    break
                case 2:
                    BDLogger.info("固件升级类型: Nordic")
                    // Nordic固件升级 查看以下方法
//                    func nrfUpgradeFirmware(filePath: String, fileName: String, progressHandler: ((Int) -> Void)? = nil, completion: @escaping (Result<BCLNrfUpgradeState.Stage, BCLError>) -> Void)
                    break
                case 3:
                    BDLogger.info("固件升级类型: Phy")
                    // Phy固件升级 查看以下方法
//                    func phyUpgradeFirmware(filePath: String, progressHandler: ((Double) -> Void)? = nil, completion: @escaping (Result<BCLPhyUpgradeState, BCLError>) -> Void)
                    break
                default:
                    break
                }
            }
            break
        default:
            break
        }
    }

    // 血氧测量
    func startBloodOxygenMeasurement() {
        // 设置回调
        BCLBloodOxygenResponse.setCallbacks(BCLBloodOxygenCallbacks(
            onProgress: { progress in
                // 更新进度UI
                BDLogger.info("测量进度: \(progress)%")
            },
            onStatusChanged: { status in
                switch status {
                case .completed:
                    BDLogger.info("测量完成")
                    // 清理回调
                    BCLBloodOxygenResponse.cleanupCurrentMeasurement()
                case .measuring:
                    BDLogger.info("测量中...")
                case .busy:
                    BDLogger.error("设备正忙，无法开始测量")
                    // 清理回调
                    BCLBloodOxygenResponse.cleanupCurrentMeasurement()
                case .chargingNotAllowed:
                    BDLogger.error("设备正在充电，无法测量")
                    // 清理回调
                    BCLBloodOxygenResponse.cleanupCurrentMeasurement()
                case .notWearing:
                    BDLogger.error("设备未佩戴，请先佩戴设备")
                    // 清理回调
                    BCLBloodOxygenResponse.cleanupCurrentMeasurement()
                case .dataCollectionTimeout:
                    BDLogger.error("数据采集超时")
                    // 清理回调
                    BCLBloodOxygenResponse.cleanupCurrentMeasurement()
                default:
                    break
                }
            },
            onMeasureValue: { bloodOxygen, heartRate, temperature in
                BDLogger.info("血氧: \(bloodOxygen ?? 0)%")
                BDLogger.info("心率: \(heartRate ?? 0)次/分")
                // 温度 (需要先解包，然后转换)
                if let temp = temperature {
                    BDLogger.info("温度：\(String(format: "%.2f°C", Double(temp) * 0.01))")
                }
            },
            onPerfusionRate: { rate in
                BDLogger.info("灌注率: \(rate)")
            },
            onBloodPressure: { diastolic, systolic in
                BDLogger.info("血压: \(systolic)/\(diastolic)mmHg")
            },
            onWaveform: { seq, num, datas in
                // 处理波形数据
                BDLogger.info("波形数据: 序号\(seq), 数量\(num)")
                BDLogger.info("波形数据: \(datas)")

            },
            onError: { error in
                BDLogger.info("错误: \(error)")
            }
        ))

        // 开始测量
        BCLRingManager.shared.startBloodOxygen(collectTime: 10,
                                               collectFrequency: 25,
                                               waveformConfig: 1,
                                               progressConfig: 1) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                BDLogger.error("启动血氧测量失败: \(error)")
                // 发生错误时清理回调
                BCLBloodOxygenResponse.cleanupCurrentMeasurement()
            }
        }
    }

    // 心率测量
    func startHeartRateMeasurement() {
        // 设置回调
        BCLHeartRateResponse.setCallbacks(BCLHeartRateCallbacks(
            onProgress: { progress in
                // 更新进度UI
                BDLogger.info("测量进度: \(progress)%")
            },
            onStatusChanged: { status in
                switch status {
                case .completed:
                    BDLogger.info("测量完成")
                case .measuring:
                    BDLogger.info("测量中...")
                case .busy:
                    BDLogger.error("设备正忙，无法开始测量")
                case .notWearing:
                    BDLogger.error("设备未佩戴，请先佩戴设备")
                case .dataCollectionTimeout:
                    BDLogger.error("数据采集超时")
                default:
                    break
                }
            },
            onMeasureValue: { heartRate, heartRateVariability, stressIndex, temperature in
                BDLogger.info("心率: \(heartRate ?? 0)次/分")
                BDLogger.info("心率变异性: \(heartRateVariability ?? 0)")
                BDLogger.info("精神压力指数: \(stressIndex ?? 0)")
                BDLogger.info("温度: \(temperature ?? 0)°C")
            },
            onWaveform: { seq, num, datas in
                // 处理波形数据
                BDLogger.info("波形数据: 序号\(seq), 数量\(num)")
                BDLogger.info("波形数据: \(datas)")
            },
            onRRInterval: { seq, num, datas in
                // 处理间期数据
                BDLogger.info("间期数据: 序号\(seq), 数量\(num)")
                BDLogger.info("间期数据: \(datas)")
            },
            onError: { error in
                BDLogger.info("错误: \(error)")
            }
        ))

        // 开始测量
        BCLRingManager.shared.startHeartRate(collectTime: 10,
                                             collectFrequency: 25,
                                             waveformConfig: 1,
                                             progressConfig: 1,
                                             intervalConfig: 1) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                BDLogger.error("启动心率测量失败: \(error)")
                // 发生错误时清理回调
                BCLHeartRateResponse.cleanupCurrentMeasurement()
            }
        }
    }

    // 心率变异性测量
    func startHeartRateVariabilityMeasurement() {
        // 设置回调
        BCLHeartRateResponse.setCallbacks(BCLHeartRateCallbacks(
            onProgress: { progress in
                // 更新进度UI
                BDLogger.info("测量进度: \(progress)%")
            },
            onStatusChanged: { status in
                switch status {
                case .completed:
                    BDLogger.info("测量完成")
                case .measuring:
                    BDLogger.info("测量中...")
                case .busy:
                    BDLogger.error("设备正忙，无法开始测量")
                case .notWearing:
                    BDLogger.error("设备未佩戴，请先佩戴设备")
                case .dataCollectionTimeout:
                    BDLogger.error("数据采集超时")
                default:
                    break
                }
            },
            onMeasureValue: { heartRate, heartRateVariability, stressIndex, temperature in
                BDLogger.info("心率: \(heartRate ?? 0)次/分")
                BDLogger.info("心率变异性: \(heartRateVariability ?? 0)")
                BDLogger.info("精神压力指数: \(stressIndex ?? 0)")
                BDLogger.info("温度: \(temperature ?? 0)°C")
            },
            onWaveform: { seq, num, datas in
                // 处理波形数据
                BDLogger.info("波形数据: 序号\(seq), 数量\(num)")
                BDLogger.info("波形数据: \(datas)")
            },
            onRRInterval: { seq, num, datas in
                // 处理间期数据
                BDLogger.info("间期数据: 序号\(seq), 数量\(num)")
                BDLogger.info("间期数据: \(datas)")
            },
            onError: { error in
                BDLogger.info("错误: \(error)")
            }
        ))

        // 开始测量
        BCLRingManager.shared.startHeartRate(collectTime: 10,
                                             collectFrequency: 50,
                                             waveformConfig: 1,
                                             progressConfig: 1,
                                             intervalConfig: 1) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                BDLogger.error("启动心率变异性测量失败: \(error)")
                // 发生错误时清理回调
                BCLHeartRateResponse.cleanupCurrentMeasurement()
            }
        }
    }

    // 读取未上传记录
    func readUnUploadData() {
        let callbacks = BCLDataSyncCallbacks(
            onProgress: { totalNumber, currentIndex, progress, model in
                BDLogger.info("同步进度：\(currentIndex)/\(totalNumber) (\(progress)%)")
                BDLogger.info("当前数据：\(model.localizedDescription)")
            },
            onStatusChanged: { status in
                BDLogger.info("同步状态变化：\(status)")
                switch status {
                case .syncing:
                    BDLogger.info("同步中...")
                case .noData:
                    BDLogger.info("无数据")
                case .completed:
                    BDLogger.info("同步完成")
                case .error:
                    BDLogger.error("同步出错")
                }
            },
            onCompleted: { models in
                BDLogger.info("同步完成，共获取 \(models.count) 条记录")
                BDLogger.info("\(models)")
                self.historyData = models
            },
            onError: { error in
                BDLogger.error("同步出错：\(error.localizedDescription)")
            }
        )

        // 调用读取方法
        BCLRingManager.shared.readUnUploadData(timestamp: 0, callbacks: callbacks) { result in
            switch result {
            case .success:
                BDLogger.info("开始数据同步")
            case let .failure(error):
                BDLogger.error("启动同步失败：\(error.localizedDescription)")
            }
        }
    }

    // 读取全部历史数据
    func readAllHistoryData() {
        // 创建回调结构体
        let callbacks = BCLDataSyncCallbacks(
            onProgress: { totalNumber, currentIndex, progress, model in
                BDLogger.info("全部历史同步进度：\(currentIndex)/\(totalNumber) (\(progress)%)")
                BDLogger.info("当前数据：\(model.localizedDescription)")
            },
            onStatusChanged: { status in
                BDLogger.info("全部历史同步状态变化：\(status)")
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
                BDLogger.info("全部历史同步完成，共获取 \(models.count) 条记录")
                BDLogger.info("\(models)")
                self.historyData = models
            },
            onError: { error in
                BDLogger.error("全部历史同步出错：\(error.localizedDescription)")
            }
        )

        // 调用读取方法
        BCLRingManager.shared.readAllHistoryData(callbacks: callbacks) { result in
            switch result {
            case .success:
                BDLogger.info("开始全部历史数据同步")
            case let .failure(error):
                BDLogger.error("启动全部历史同步失败：\(error.localizedDescription)")
            }
        }
    }
}

extension Main_VC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }

        if curFirmwareUpgradeType == .apollo {
            // 检查文件扩展名是否为.bin
            guard fileURL.pathExtension.lowercased() == "bin" else {
                BDLogger.error("请选择.bin格式的固件文件")
                return
            }
            BDLogger.info("选择的文件：\(fileURL)")
            BDLogger.info("文件名称：\(fileURL.lastPathComponent)")
            BDLogger.info("开始apollo固件升级...")

            guard let fileurl = fileURL as URL? else {
                BDLogger.error("文件路径无效")
                return
            }
            BCLRingManager.shared.apolloUpgradeFirmware(
                filePath: fileurl.path,
                progressHandler: { progress in
                    BDLogger.info("当前进度：\(progress)%")
                },
                completion: { result in
                    switch result {
                    case .success:
                        BDLogger.info("升级成功")
                    case let .failure(error):
                        BDLogger.error("升级失败：\(error)")
                    }
                }
            )
        } else if curFirmwareUpgradeType == .nordic {
            // 检查文件扩展名是否为.zip
            guard fileURL.pathExtension.lowercased() == "zip" else {
                BDLogger.error("请选择.zip格式的固件文件")
                return
            }
            BDLogger.info("选择的文件：\(fileURL)")
            BDLogger.info("文件名称：\(fileURL.lastPathComponent)")
            BDLogger.info("开始Nordic固件升级...")

            let fileName = fileURL.lastPathComponent
            if let rootView = UIApplication.shared.windows.first?.rootViewController?.view {
                QMUITips.show(withText: "设备重启中.....", in: rootView)
            }
            BCLRingManager.shared.nrfUpgradeFirmware(filePath: fileURL.path, fileName: fileName) { progress in
                QMUITips.hideAllTips()
                BDLogger.info("当前进度：\(progress)%")
                if let rootView = UIApplication.shared.windows.first?.rootViewController?.view {
                    QMUITips.show(withText: "升级进度：\(progress)%", in: rootView)
                }
            } completion: { res in
                switch res {
                case let .success(state):
                    QMUITips.hideAllTips()
                    if state == .rebooting {
                        if let rootView = UIApplication.shared.windows.first?.rootViewController?.view {
                            QMUITips.show(withText: "设备重启中", in: rootView)
                        }
                    } else if state == .completed {
                        BDLogger.info("固件升级成功")
                        if let rootView = UIApplication.shared.windows.first?.rootViewController?.view {
                            QMUITips.show(withText: "固件升级成功", in: rootView)
                        }
                    }
                    break
                case let .failure(error):
                    BDLogger.error("升级失败：\(error)")
                    QMUITips.hideAllTips()
                    if let rootView = UIApplication.shared.windows.first?.rootViewController?.view {
                        QMUITips.show(withText: "固件升级失败：\(error)", in: rootView)
                    }
                    break
                }
            }
        } else if curFirmwareUpgradeType == .phy {
            // 检查文件扩展名是否为.hex16
            guard fileURL.pathExtension.lowercased() == "hex16" else {
                BDLogger.error("请选择.hex16格式的固件文件")
                return
            }
            BDLogger.info("选择的文件：\(fileURL)")
            BDLogger.info("文件名称：\(fileURL.lastPathComponent)")
            BDLogger.info("开始Phy固件升级...")
            BCLRingManager.shared.phyUpgradeFirmware(filePath: fileURL.path) { progress in
                BDLogger.info("升级进度：\(progress)")
            } completion: { res in
                switch res {
                case let .success(state):
                    BDLogger.error("升级成功：\(state)")
                    break
                case let .failure(error):
                    BDLogger.error("升级失败：\(error)")
                    break
                }
            }
        }
    }
}
