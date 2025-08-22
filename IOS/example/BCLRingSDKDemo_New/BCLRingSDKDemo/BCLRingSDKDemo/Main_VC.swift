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

/// 固件升级类型
public enum FirmwareUpgradeType {
    case apollo // 阿波罗（Ambiq）升级
    case nordic // Nordic DFU 升级
    case phy // Phy 固件升级
    case phyBootMode // Phy Bootloader 固件升级
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


        // 定制厂商标识，进行特定处理
//        BCLRingManager.shared.manufacturerID = .KK

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

//        //  蓝牙设备连接状态Block方式
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

//        //  蓝牙设备连接状态RX监听
//        BCLRingManager.shared.bluetoothConnectStateObservable.subscribe(onNext: { state in
//            switch state {
//            case .connecting:
//                self.name_Label.text = "设备名称："
//                self.mac_Label.text = "MAC地址："
//                self.connect_Label.text = "连接状态：连接中..."
//                self.rssi_Label.text = "RSSI："
//                break
//            case .characteristicProcessingCompleted:
//                let deviceInfo = BCLRingManager.shared.currentConnectedDevice
//                if let advertisementData = deviceInfo?.advertisementData as? [String: Any] {
//                    BDLogger.info("广播数据：\(advertisementData)")
//                }
//                if let advDataManufacturerData = deviceInfo?.advDataManufacturerData as? Data {
//                    BDLogger.info("蓝牙制造商数据：\(advDataManufacturerData)")
//                    let hexString = advDataManufacturerData.map { String(format: "%02X", $0) }.joined()
//                    BDLogger.info("蓝牙制造商数据（Hex）：\(hexString)")
//                }
//                BDLogger.info("蓝牙广播协议中充电指示位：\(deviceInfo?.chargingIndicator ?? 0)")
//                BDLogger.info("蓝牙广播协议中绑定指示位：\(deviceInfo?.bindingIndicatorBit ?? 0)")
//                BDLogger.info("蓝牙广播协议中通讯协议版本号：\(deviceInfo?.communicationProtocolVersion ?? 0)")
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
//
//                UserDefaults.standard.set(deviceInfo.macAddress, forKey: "ring_macAddress")
//                UserDefaults.standard.set(deviceInfo.peripheralName, forKey: "ring_peripheralName")
//                UserDefaults.standard.set(deviceInfo.peripheral.identifier.uuidString, forKey: "ring_uuidString")
//                break
//            default:
//                self.name_Label.text = "设备名称："
//                self.mac_Label.text = "MAC地址："
//                self.connect_Label.text = "连接状态：未连接"
//                self.rssi_Label.text = "RSSI："
//                break
//            }
//        }).disposed(by: disposeBag)

        //  简化版本连接状态回调
        BCLRingManager.shared.deviceIsDidConnectedBlock = { state in
            switch state {
            case .connected:
                BDLogger.info("设备已连接-简化版本")
                if let connectedDevice = BCLRingManager.shared.currentConnectedDevice {
                    self.name_Label.text = "设备名称：\(connectedDevice.peripheralName ?? "")"
                    self.mac_Label.text = "MAC地址：\(connectedDevice.macAddress ?? "")"
                    self.connect_Label.text = "连接状态：已连接"
                    self.rssi_Label.text = "RSSI：\(connectedDevice.rssi ?? 0)"
                } else {
                    BDLogger.error("当前没有已连接的设备信息")
                    self.name_Label.text = "设备名称："
                    self.mac_Label.text = "MAC地址："
                    self.connect_Label.text = "连接状态：未连接"
                    self.rssi_Label.text = "RSSI："
                }
            case .connecting:
                BDLogger.info("设备连接中...-简化版本")
                if let pendingDevice = BCLRingManager.shared.pendingDeviceInfo {
                    self.name_Label.text = "设备名称：\(pendingDevice.peripheralName ?? "")"
                    self.mac_Label.text = "MAC地址：\(pendingDevice.macAddress ?? "")"
                    self.connect_Label.text = "连接状态：连接中"
                    self.rssi_Label.text = "RSSI：\(pendingDevice.rssi ?? 0)"
                } else {
                    BDLogger.error("当前没有连接中的设备信息")
                    self.name_Label.text = "设备名称："
                    self.mac_Label.text = "MAC地址："
                    self.connect_Label.text = "连接状态：未连接"
                    self.rssi_Label.text = "RSSI："
                }
            case .disconnected:
                BDLogger.info("设备已断开连接-简化版本")
                self.name_Label.text = "设备名称："
                self.mac_Label.text = "MAC地址："
                self.connect_Label.text = "连接状态：未连接"
                self.rssi_Label.text = "RSSI："
            }
        }

//        //  待连接的蓝牙设备信息
//        BCLRingManager.shared.pendingPeripheralDeviceInfoObservable.subscribe(onNext: { deviceInfo in
//            BDLogger.info("待连接设备信息: \(String(describing: deviceInfo))")
//            guard let deviceInfo = deviceInfo else {
//                BDLogger.error("待连接设备信息为空")
//                return
//            }
//            self.name_Label.text = "设备名称：\(deviceInfo.peripheralName ?? "")"
//            self.mac_Label.text = "MAC地址：\(deviceInfo.macAddress ?? "")"
//            self.connect_Label.text = "连接状态：连接中"
//            self.rssi_Label.text = "RSSI：\(deviceInfo.rssi ?? 0)"
//        }).disposed(by: disposeBag)
//
//        //  已连接的蓝牙设备信息
//        BCLRingManager.shared.connectedPeripheralDeviceInfoObservable.subscribe(onNext: { deviceInfo in
//            BDLogger.info("已连接的蓝牙设备信息: \(String(describing: deviceInfo))")
//            guard let deviceInfo = deviceInfo else {
//                BDLogger.error("待连接设备信息为空")
//                return
//            }
//            self.name_Label.text = "设备名称：\(deviceInfo.peripheralName ?? "")"
//            self.mac_Label.text = "MAC地址：\(deviceInfo.macAddress ?? "")"
//            self.connect_Label.text = "连接状态：已连接"
//            self.rssi_Label.text = "RSSI：\(deviceInfo.rssi ?? 0)"
//        }).disposed(by: disposeBag)

        // 用于记录上次连接过的设备信息，应用启动后可选择是否自动连接
        let macAddress = UserDefaults.standard.string(forKey: "ring_macAddress")
        let peripheralName = UserDefaults.standard.string(forKey: "ring_peripheralName")
        if let macAddress = macAddress {
            let alert = UIAlertController(title: "提示", message: "是否自动连接设备？\n 设备MAC地址：\(macAddress) \n 设备名称：\(peripheralName)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                self.connectDevice(macAddress: macAddress)
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    // 连接设备
    func connectDevice(macAddress: String) {
        QMUITips.showLoading("Device Connecting...", in: view)
        BCLRingManager.shared.startConnect(macAddress: macAddress, isAutoReconnect: true, autoReconnectTimeLimit: 1000, autoReconnectMaxAttempts: 5000) { result in
            switch result {
            case .success:
                BDLogger.info("connect success")
                QMUITips.hideAllTips(in: self.view)
            case let .failure(error):
                BDLogger.error("connect failed: \(error)")
                QMUITips.hideAllTips(in: self.view)
                QMUITips.showError("Connect Failed", in: self.view)
            }
        }
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
            BCLRingManager.shared.syncTime(timeZone: .East8) { res in
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
            // 7.1.5.3Z3R / 7.1.7.0Z3R / (RH18:2.7.5.2Z3N) / 2.7.4.8Z27 / 7.2.0.2Z3R
            BCLRingManager.shared.checkFirmwareUpdate(version: "7.2.0.2Z3R") { result in
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
            guard BCLRingManager.shared.deviceIsDidConnected else {
                QMUITips.show(withText: "请连接蓝牙设备")
                return
            }
            let contentView = UpdateDeviceName_Dialog(x: 15, y: UIScreen.main.bounds.height / 2 - 100, width: UIScreen.main.bounds.width - 30, height: 200)
            contentView.confirmButtonCallback = { name in
                BDLogger.info("更改蓝牙名称-\(name)")
                BCLRingManager.shared.setBluetoothName(name: name) { res in
                    switch res {
                    case let .success(res):
                        if res.success {
                            BDLogger.info("设置蓝牙名称成功")
                            QMUITips.show(withText: "设置成功")
                        } else {
                            BDLogger.info("设置蓝牙名称失败")
                            QMUITips.show(withText: "设置失败")
                        }
                    case let .failure(error):
                        BDLogger.error("设置蓝牙名称失败: \(error)")
                        QMUITips.show(withText: "设置失败")
                    }
                }
            }
            let modalPresentation_VC = QMUIModalPresentationViewController()
            modalPresentation_VC.isModal = true
            modalPresentation_VC.contentView = contentView
            modalPresentation_VC.showWith(animated: true)
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
                    BDLogger.info("血糖测量支持:\(response.isBloodGlucoseMeasurementSupported) ")
                    BDLogger.info("文件支持:\(response.isFileSystemSupported) ")
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

            // 设置过滤时间（可选）(如果不需要过滤时间，可以传nil，表示不过滤) (传入时间则只会同步过滤时间之后的数据)
            let filterTime = "2025-01-01 00:00:00".toDate("yyyy-MM-dd HH:mm:ss", region: Region.local)?.date
            BDLogger.info("APP事件-连接戒指-过滤时间: \(String(describing: filterTime))")
            BCLRingManager.shared.appEventConnectRing(date: Date(), timeZone: .East8, filterTime: filterTime, callbacks: callbacks) { res in
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
                    BDLogger.info("血糖测量支持:\(response.isBloodGlucoseMeasurementSupported) ")
                    BDLogger.info("文件支持:\(response.isFileSystemSupported) ")
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

            // 设置过滤时间（可选）(如果不需要过滤时间，可以传nil，表示不过滤) (传入时间则只会同步过滤时间之后的数据)
            let filterTime = "2025-01-01 00:00:00".toDate("yyyy-MM-dd HH:mm:ss", region: Region.local)?.date
            BDLogger.info("APP事件-刷新戒指-过滤时间: \(String(describing: filterTime))")
            BCLRingManager.shared.appEventRefreshRing(date: Date(), timeZone: .East8, filterTime: filterTime, callbacks: callbacks) { res in
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
                    BDLogger.info("血糖测量支持:\(response.isBloodGlucoseMeasurementSupported) ")
                    BDLogger.info("文件支持:\(response.isFileSystemSupported) ")
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
        case 142: // 血压-血糖测量
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
                        BDLogger.info("+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                        BDLogger.info("血压波形数据量:\(self.bloodPressureWaveData.count)")
                        BDLogger.info("血压波形数据:\(self.bloodPressureWaveData)")
                        let mac = BCLRingManager.shared.currentConnectedDevice?.macAddress ?? ""
                        BDLogger.info("Mac地址:\(mac)")
                        // 血压云端算法
                        BCLRingManager.shared.uploadBloodPressureData(mac: mac, waveData: self.bloodPressureWaveData) { res in
                            switch res {
                            case let .success(data):
                                BDLogger.info("收缩压：\(data.0)、舒张压：\(data.1)")
                            case let .failure(error):
                                BDLogger.error("数据计算失败: \(error.localizedDescription)")
                            }
                        }

                        // 血糖云端算法
                        BCLRingManager.shared.uploadBloodGlucoseData(mac: mac, waveData: self.bloodPressureWaveData) { res in
                            switch res {
                            case let .success(data):
                                BDLogger.info("血糖数据：\(data) mmol/L")
                            case let .failure(error):
                                BDLogger.error("血糖数据上传失败: \(error.localizedDescription)")
                            }
                        }

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
            BCLRingManager.shared.startBloodPressure(collectTime: 30, waveformConfig: 1, progressConfig: 1) { result in
                switch result {
                case .success:
                    break
                case let .failure(error):
                    BDLogger.error("启动心率测量失败: \(error)")
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
            let date = Date("2025-08-08", format: "yyyy-MM-dd")
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
            // 临时测试文件名
            let fileName = "010203040506_749D2668_8.txt"
            BCLRingManager.shared.getFileData(fileName: fileName) { res in
                switch res {
                case let .success(response):
                    BDLogger.info("获取文件数据成功: \(response)")
                    BDLogger.info("文件数据-状态: \(response.fileSystemStatus ?? 0)")
                    BDLogger.info("文件数据-大小: \(response.fileSize ?? 0)")
                    BDLogger.info("文件数据-总包数: \(response.totalNumber ?? 0)")
                    BDLogger.info("文件数据-当前包号: \(response.currentNumber ?? 0)")
                    BDLogger.info("文件数据-当前包长度: \(response.currentLength ?? 0)")
                    guard let fileType = response.fileType, fileType >= 1 || fileType <= 8 else {
                        BDLogger.info("未知的文件类型")
                        return
                    }
                    if fileType == 1 {
                        BDLogger.info("文件类型:三轴数据-数据：\(response.fileDataType1 ?? [])")
                    } else if fileType == 2 {
                        BDLogger.info("文件类型:六轴数据-数据：\(response.fileDataType2 ?? [])")
                    } else if fileType == 3 {
                        BDLogger.info("文件类型:PPG数据红外+红色+三轴(spo2)-数据：\(response.fileDataType3 ?? [])")
                    } else if fileType == 4 {
                        BDLogger.info("文件类型:PPG数据绿色-数据：\(response.fileDataType4 ?? [])")
                    } else if fileType == 5 {
                        BDLogger.info("文件类型:PPG数据红外-数据：\(response.fileDataType5 ?? [])")
                    } else if fileType == 6 {
                        BDLogger.info("文件类型:温度数据红外-数据：\(response.fileDataType6 ?? [])")
                    } else if fileType == 7 {
                        BDLogger.info("文件类型:红外+红色+绿色+温度+三轴-数据：\(response.fileDataType7 ?? [])")
                    } else if fileType == 8 {
                        BDLogger.info("文件类型:PPG数据绿色+三轴(hr)-数据：\(response.fileDataType8 ?? [])")
                    }
                case let .failure(error):
                    BDLogger.error("获取文件数据失败: \(error)")
                }
            }
            break
        case 165: // 删除文件
            BDLogger.info("删除文件")
            // 临时测试文件名
            let fileName = "010203040506_749D2668_8.txt"
            BCLRingManager.shared.deleteFile(fileName: fileName) { res in
                switch res {
                case let .success(response):
                    if let result = response.deleteResult, result == 1 {
                        BDLogger.info("删除文件成功: \(response)")
                    } else {
                        BDLogger.info("删除文件失败: \(response)")
                    }
                case let .failure(error):
                    BDLogger.error("删除文件失败: \(error)")
                }
            }
            break
        case 166: // 格式化文件系统
            BDLogger.info("格式化文件系统")
            BCLRingManager.shared.formatFileSystem { res in
                switch res {
                case let .success(response):
                    if let result = response.formatResult, result == 1 {
                        BDLogger.info("格式化文件系统成功: \(response)")
                    } else {
                        BDLogger.info("格式化文件系统失败: \(response)")
                    }
                case let .failure(error):
                    BDLogger.error("格式化文件系统失败: \(error)")
                }
            }
            break
        case 167: // 获取文件系统空间信息
            BDLogger.info("获取文件系统空间信息")
            BCLRingManager.shared.getFileSystemInfo { res in
                switch res {
                case let .success(response):
                    BDLogger.info("获取文件系统空间信息成功: \(response)")
                    BDLogger.info("文件系统空间信息-总空间: \(response.totalSize ?? 0)")
                    BDLogger.info("文件系统空间信息-可用空间: \(response.freeSize ?? 0)")
                    BDLogger.info("文件系统空间信息-已用空间: \(response.usedSize ?? 0)")
                case let .failure(error):
                    BDLogger.error("获取文件系统空间信息失败: \(error)")
                }
            }
            break
        case 168: // 设置自动记录采集数据模式
            BDLogger.info("设置自动记录采集数据模式")
            BCLRingManager.shared.setAutoRecordDataMode(type: 1) { res in
                switch res {
                case let .success(response):
                    if let result = response.result, result == 1 {
                        BDLogger.info("设置自动记录采集数据模式成功")
                    } else {
                        BDLogger.info("设置自动记录采集数据模式失败")
                    }
                case let .failure(error):
                    BDLogger.error("设置自动记录采集数据模式失败: \(error)")
                }
            }

            break
        case 169: // 获取自动记录采集数据模式
            BDLogger.info("获取自动记录采集数据模式")
            BCLRingManager.shared.getAutoRecordDataMode { res in
                switch res {
                case let .success(response):
                    BDLogger.info("获取自动记录采集数据模式成功: \(response)")
                    // 0：停止自动记录采集信息、1：开启自动记录三轴信息、2：开启自动记录六轴信息、3：开启自动记录spo2信息、4：开启自动记录hr信息、5：开启自动记录红外信息、6：开启自动记温度信息
                    if let mode = response.status {
                        switch mode {
                        case 0:
                            BDLogger.info("停止自动记录采集信息")
                        case 1:
                            BDLogger.info("开启自动记录三轴信息")
                        case 2:
                            BDLogger.info("开启自动记录六轴信息")
                        case 3:
                            BDLogger.info("开启自动记录spo2信息")
                        case 4:
                            BDLogger.info("开启自动记录hr信息")
                        case 5:
                            BDLogger.info("开启自动记录红外信息")
                        case 6:
                            BDLogger.info("开启自动记温度信息")
                        default:
                            BDLogger.info("未知的自动记录采集数据模式")
                        }
                    }
                case let .failure(error):
                    BDLogger.error("获取自动记录采集数据模式失败: \(error)")
                }
            }

            break
        case 170: // 获取文件系统状态
            BDLogger.info("获取文件系统状态")

            BCLRingManager.shared.getFileSystemStatus { res in
                switch res {
                case let .success(response):
                    BDLogger.info("获取文件系统状态成功: \(response)")
                    if let status = response.status, status == 0 {
                        BDLogger.info("文件系统状态: 空闲")
                    } else if let status = response.status, status == 1 {
                        BDLogger.info("文件系统状态: 上传文件状态")
                    } else if let status = response.status, status == 2 {
                        BDLogger.info("文件系统状态: 写状态")
                    } else if let status = response.status, status == 3 {
                        BDLogger.info("文件系统状态: 忙")
                    } else {
                        BDLogger.info("未知的文件系统状态")
                    }
                case let .failure(error):
                    BDLogger.error("获取文件系统状态失败: \(error)")
                }
            }

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

        case 172: // 检查是否需要迁移数据
            BDLogger.info("检查是否需要迁移数据:\(BCLRingManager.shared.checkNeedMigrateHistoryData())")
            break
        case 173: // 查询需要迁移数据的条数
            BDLogger.info("查询需要迁移数据的条数:\(BCLRingManager.shared.getOldDatabaseRecordCount())")
            break
        case 174: // 开始迁移数据
            BDLogger.info("开始迁移数据")
            let macAddress = BCLRingManager.shared.currentConnectedDevice?.macAddress ?? ""
            BCLRingManager.shared.migrateHistoryData(mac: macAddress) { res in
                switch res {
                case .success:
                    BDLogger.info("迁移数据成功")
                case let .failure(error):
                    BDLogger.error("迁移数据失败: \(error)")
                }
            }
            break
        case 175: // ECG采集人体心电信号
            BDLogger.info("ECG采集人体心电信号")
            BCLRingManager.shared.startTakeECG { res in
                switch res {
                case let .success(response):
                    BDLogger.info("开始ECG采集人体心电-HeadTypeSize: \(response.headTypeSize)")
                    BDLogger.info("开始ECG采集人体心电-HeadType: \(response.headType)")
                    BDLogger.info("开始ECG采集人体心电-DeviceType: \(response.deviceType)")
                    BDLogger.info("开始ECG采集人体心电-seq: \(response.seq)")
                    BDLogger.info("开始ECG采集人体心电-hr: \(response.hr)")
                    BDLogger.info("开始ECG采集人体心电-dataLength: \(response.dataLength)")
                    BDLogger.info("开始ECG采集人体心电-ecgValues: \(response.ecgValues)")
                case let .failure(error):
                    BDLogger.error("开始ECG采集人体心电信号失败: \(error)")
                }
            }

            break
        case 176: // ECG采集模拟信号
            BDLogger.info("ECG采集模拟信号")

            BCLRingManager.shared.startTakeECGSimulator { res in
                switch res {
                case let .success(response):
                    BDLogger.info("开始ECG采集模拟信号-HeadTypeSize: \(response.headTypeSize)")
                    BDLogger.info("开始ECG采集模拟信号-HeadType: \(response.headType)")
                    BDLogger.info("开始ECG采集模拟信号-DeviceType: \(response.deviceType)")
                    BDLogger.info("开始ECG采集模拟信号-seq: \(response.seq)")
                    BDLogger.info("开始ECG采集模拟信号-hr: \(response.hr)")
                    BDLogger.info("开始ECG采集模拟信号-dataLength: \(response.dataLength)")
                    BDLogger.info("开始ECG采集模拟信号-ecgValues: \(response.ecgValues)")
                case let .failure(error):
                    BDLogger.error("开始ECG采集模拟信号失败: \(error)")
                }
            }
            break
        case 177: // 停止ECG采集
            BDLogger.info("停止ECG采集")

            BCLRingManager.shared.stopECG { res in
                switch res {
                case .success:
                    BDLogger.info("停止ECG采集成功")
                case let .failure(error):
                    BDLogger.error("停止ECG采集失败: \(error)")
                }
            }
            break
        case 178: // 十米-六轴三轴协议-六轴开始采集
            BDLogger.info("十米-六轴三轴协议-六轴开始采集")
            BCLRingManager.shared.startSixAxis { res in
                switch res {
                case let .success(response):
                    if let status = response.deviceStatus, status == 0 { // 正常
                        BDLogger.info("十米-六轴三轴协议-六轴开始采集数据-轴实时转向：\(response.axisRealTurn ?? 0)")
                        BDLogger.info("十米-六轴三轴协议-六轴开始采集数据-轴实时俯仰：\(response.axisRealPitch ?? 0)")
                        BDLogger.info("十米-六轴三轴协议-六轴开始采集数据-实时速度：\(response.realSpeed ?? 0)")
                        BDLogger.info("十米-六轴三轴协议-六轴开始采集数据-瞬间转向：\(response.instantTurn ?? 0)")
                        BDLogger.info("十米-六轴三轴协议-六轴开始采集数据-瞬间俯仰：\(response.instantPitch ?? 0)")
                        BDLogger.info("十米-六轴三轴协议-六轴开始采集数据-Z轴加速度计：\(response.zAxisAccelerometer ?? 0)")
                        BDLogger.info("十米-六轴三轴协议-六轴开始采集数据-Y轴加速度计：\(response.yAxisAccelerometer ?? 0)")
                        BDLogger.info("十米-六轴三轴协议-六轴开始采集数据-X轴加速度计：\(response.xAxisAccelerometer ?? 0)")
                        BDLogger.info("十米-六轴三轴协议-六轴开始采集数据-计数：\(response.count ?? 0)")
                    } else {
                        BDLogger.info("十米-六轴三轴协议-六轴开始采集-设备繁忙")
                    }
                case let .failure(error):
                    BDLogger.error("十米-六轴三轴协议-六轴开始采集失败: \(error)")
                }
            }
            break
        case 179: // 十米-六轴三轴协议-三轴开始采集
            BDLogger.info("十米-六轴三轴协议-三轴开始采集")
            BCLRingManager.shared.startThreeAxis { res in
                switch res {
                case let .success(response):
                    if let status = response.deviceStatus, status == 0 { // 正常
                        BDLogger.info("十米-六轴三轴协议-三轴开始采集数据-Z轴加速度计：\(response.zAxisAccelerometer ?? 0)")
                        BDLogger.info("十米-六轴三轴协议-三轴开始采集数据-Y轴加速度计：\(response.yAxisAccelerometer ?? 0)")
                        BDLogger.info("十米-六轴三轴协议-三轴开始采集数据-X轴加速度计：\(response.xAxisAccelerometer ?? 0)")
                    } else {
                        BDLogger.info("十米-六轴三轴协议-三轴开始采集-设备繁忙")
                    }
                case let .failure(error):
                    BDLogger.error("十米-六轴三轴协议-三轴开始采集失败: \(error)")
                }
            }
            break
        case 180: // 十米-六轴三轴协议-停止
            BDLogger.info("十米-六轴三轴协议-停止")
            BCLRingManager.shared.stop { res in
                switch res {
                case .success:
                    BDLogger.info("十米-六轴三轴协议-停止-成功")
                case let .failure(error):
                    BDLogger.error("十米-六轴三轴协议-停止失败: \(error)")
                }
            }
            break
        case 181: // 十米-六轴三轴协议-加速度计校准
            BDLogger.info("十米-六轴三轴协议-加速度计校准")
            BCLRingManager.shared.accelerationCalibration { res in
                switch res {
                case let .success(response):
                    if let status = response.calibrationResult, status == 0 {
                        BDLogger.info("十米-六轴三轴协议-加速度计校准-成功")
                    } else {
                        BDLogger.info("十米-六轴三轴协议-加速度计校准-失败")
                    }
                case let .failure(error):
                    BDLogger.error("十米-六轴三轴协议-加速度计校准失败: \(error)")
                }
            }
            break
        case 182: // 清除戒指内历史数据
            BDLogger.info("清除戒指内历史数据")
            BCLRingManager.shared.deleteRingAllHistoryData { res in
                switch res {
                case .success:
                    BDLogger.info("清除戒指内历史数据成功")
                case let .failure(error):
                    BDLogger.error("清除戒指内历史数据失败: \(error)")
                }
            }
            break
        case 183: // 打开PCM格式音频传输
            BDLogger.info("打开PCM格式音频传输")
            BCLRingManager.shared.controlPCMFormatAudio(isOpen: true) { res in
                switch res {
                case let .success(response):
                    BDLogger.info("PCM格式音频传输-音频数据长度: \(response.audioDataLength ?? 0)")
                    BDLogger.info("PCM格式音频传输-音频数据序号: \(response.seq ?? 0)")
                    BDLogger.info("PCM格式音频传输-音频数据: \(response.audioData)")
                case let .failure(error):
                    BDLogger.error("开启PCM格式音频传输失败: \(error)")
                }
            }
            break
        case 184: // 关闭PCM格式音频传输
            BDLogger.info("关闭PCM格式音频传输")
            BCLRingManager.shared.controlPCMFormatAudio(isOpen: false) { res in
                switch res {
                case .success:
                    BDLogger.info("关闭PCM格式音频传输-成功")
                case let .failure(error):
                    BDLogger.error("关闭PCM格式音频传输失败: \(error)")
                }
            }
            break
        case 185: // 开启ADPCM格式音频传输
            BDLogger.info("开启ADPCM格式音频传输")
            BCLRingManager.shared.controlADPCMFormatAudio(isOpen: true) { res in
                switch res {
                case let .success(response):
                    BDLogger.info("ADPCM格式音频传输-音频数据长度: \(response.audioDataLength)")
                    BDLogger.info("ADPCM格式音频传输-音频数据序号: \(response.seq)")
                    BDLogger.info("ADPCM格式音频传输-音频数据: \(response.audioData)")
                case let .failure(error):
                    BDLogger.error("开启ADPCM格式音频传输失败: \(error)")
                }
            }
            break
        case 186: // 关闭ADPCM格式音频传输
            BDLogger.info("关闭ADPCM格式音频传输")
            BCLRingManager.shared.controlADPCMFormatAudio(isOpen: false) { res in
                switch res {
                case .success:
                    BDLogger.info("关闭ADPCM格式音频传输-成功")
                case let .failure(error):
                    BDLogger.error("关闭ADPCM格式音频传输-失败: \(error)")
                }
            }
            break
        case 187: // 设置主动推送音频信息
            BDLogger.info("设置主动推送音频信息")
            let audioType: BCLAudioType = .pcm // 可选值：pcm, adpcm
            BCLRingManager.shared.setActivePushAudioInfo(audioType: .pcm) { res in
                switch res {
                case let .success(response):
                    if response.status == 0 {
                        if audioType == .pcm {
                            BDLogger.info("主动推送音频信息已开启，格式为PCM")
                        } else {
                            BDLogger.info("主动推送音频信息已开启，格式为ADPCM")
                        }
                    } else {
                        BDLogger.info("主动推送音频信息设置失败")
                    }
                case let .failure(error):
                    BDLogger.error("设置主动推送音频信息失败: \(error)")
                }
            }
            break
        case 188: // 获取主动推送音频信息
            BDLogger.info("获取主动推送音频信息")
            BCLRingManager.shared.getActivePushAudioInfo { res in
                switch res {
                case let .success(response):
                    if response.audioType == .pcm {
                        BDLogger.info("主动推送音频信息已开启，格式为PCM")
                    } else if response.audioType == .adpcm {
                        BDLogger.info("主动推送音频信息已开启，格式为ADPCM")
                    }
                case let .failure(error):
                    BDLogger.error("获取主动推送音频信息失败: \(error)")
                }
            }
            break
        case 189: //  设置HID触摸-上传实时音频模式
            BDLogger.info("设置HID触摸-上传实时音频模式")

            BCLRingManager.shared.hidTouchAudioDataBlock = { dataLenght, seq, audioData, isEnd in
                BDLogger.info("HID触摸-上传实时音频数据-数据长度: \(dataLenght)")
                BDLogger.info("HID触摸-上传实时音频数据-包序号: \(seq)")
                BDLogger.info("HID触摸-上传实时音频数据-音频数据: \(audioData)")
                BDLogger.info("HID触摸-上传实时音频数据-是否结束: \(isEnd)")
            }

            BCLRingManager.shared.setHIDMode(touchMode: 4,
                                             gestureMode: 255,
                                             systemType: 1,
                                             deviceModelName: BCLRingManager.shared.getMobileDeviceModelName(),
                                             screenHeightPixel: BCLRingManager.shared.getMobileDeviceScreenWidthPixel(),
                                             screenWidthPixel: BCLRingManager.shared.getMobileDeviceScreenHeightPixel()) { res in
                switch res {
                case let .success(response):
                    if response.status == 1 {
                        BDLogger.info("设置HID触摸-上传实时音频模式成功")
                    } else {
                        BDLogger.info("设置HID触摸-上传实时音频模式失败")
                    }
                case let .failure(error):
                    BDLogger.error("设置HID触摸-上传实时音频模式失败: \(error)")
                }
            }
            break
        case 190: // 固件历史版本
            BDLogger.info("获取固件历史版本")
            BCLRingManager.shared.getFirmwareVersionList(category: "Z3N") { res in
                switch res {
                case let .success(response):
                    BDLogger.info("固件历史版本-总个数: \(response.count)")
                    response.forEach { item in
                        BDLogger.info("固件历史版本-文件名: \(item.fileName)")
                        BDLogger.info("固件历史版本-文件路径: \(item.filePath)")
                        BDLogger.info("固件历史版本-下载链接: \(item.fileUrl)")
                    }
                case let .failure(error):
                    BDLogger.error("获取固件历史版本失败: \(error)")
                }
            }
            break
        case 191: // 开始运动
            BDLogger.info("开始运动")

            /// 运动数据监听
            BCLRingManager.shared.sportDataBlock = { sportDataResponse in
                BDLogger.info("运动数据-时间戳: \(sportDataResponse.timestamp ?? 0)")
                BDLogger.info("运动数据-步数: \(sportDataResponse.totalSteps ?? 0)")
                BDLogger.info("运动数据-心率: \(sportDataResponse.heartRate ?? 0)次/分")
                BDLogger.info("运动数据-能量消耗: \(sportDataResponse.energyConsumption ?? 0)")
            }

            BCLRingManager.shared.startSportMode(sportType: 1) { res in
                switch res {
                case let .success(response):
                    if response.status == 1 {
                        BDLogger.info("开始运动-成功")
                    } else {
                        BDLogger.info("开始运动-失败")
                    }
                case let .failure(error):
                    BDLogger.error("开始运动失败: \(error)")
                }
            }
            break
        case 192: // 停止运动
            BDLogger.info("停止运动")
            BCLRingManager.shared.stopSportMode { res in
                switch res {
                case let .success(response):
                    if response.status == 1 {
                        BDLogger.info("停止运动-成功")
                    } else {
                        BDLogger.info("停止运动-失败")
                    }
                case let .failure(error):
                    BDLogger.error("停止运动失败: \(error)")
                }
            }
            break
        case 193: // 运动漏点续传
            BDLogger.info("运动漏点续传")

            /// 漏传运动数据监听
            BCLRingManager.shared.sportDataMissingPointsBlock = { missingPointsDtatRes in
                BDLogger.info("漏传-运动数据-时间戳: \(missingPointsDtatRes.timestamp ?? 0)")
                BDLogger.info("漏传-运动数据-步数: \(missingPointsDtatRes.totalSteps ?? 0)")
                BDLogger.info("漏传-运动数据-心率: \(missingPointsDtatRes.heartRate ?? 0)次/分")
                BDLogger.info("漏传-运动数据-能量消耗: \(missingPointsDtatRes.energyConsumption ?? 0)")
            }

            /// 请求获取漏传运动数据
            BCLRingManager.shared.requestMissingPointsSportMode()
            break
        case 194: // 闹钟配置
            BDLogger.info("设置闹钟")
            let alarmClock1 = BCLAlarmClockData(timestamp: "2025-06-24 12:33:00".toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date.timeIntervalSince1970 ?? 0,
                                                repeatType: .once,
                                                vibrationEffect: .strong,
                                                isEnabled: true,
                                                isMonday: true,
                                                isTuesday: true,
                                                isWednesday: true,
                                                isThursday: true,
                                                isFriday: true,
                                                isSaturday: true,
                                                isSunday: true)
            let alarmClock2 = BCLAlarmClockData(timestamp: "2025-06-24 12:34:00".toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date.timeIntervalSince1970 ?? 0,
                                                repeatType: .once,
                                                vibrationEffect: .strong,
                                                isEnabled: true,
                                                isMonday: true,
                                                isTuesday: true,
                                                isWednesday: true,
                                                isThursday: true,
                                                isFriday: true,
                                                isSaturday: true,
                                                isSunday: true)
            let alarmClock3 = BCLAlarmClockData(timestamp: "2025-06-24 12:35:00".toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date.timeIntervalSince1970 ?? 0,
                                                repeatType: .once,
                                                vibrationEffect: .strong,
                                                isEnabled: true,
                                                isMonday: true,
                                                isTuesday: true,
                                                isWednesday: true,
                                                isThursday: true,
                                                isFriday: true,
                                                isSaturday: true,
                                                isSunday: true)
            let alarmClock4 = BCLAlarmClockData(timestamp: "2025-06-24 12:36:00".toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date.timeIntervalSince1970 ?? 0,
                                                repeatType: .once,
                                                vibrationEffect: .strong,
                                                isEnabled: true,
                                                isMonday: true,
                                                isTuesday: true,
                                                isWednesday: true,
                                                isThursday: true,
                                                isFriday: true,
                                                isSaturday: true,
                                                isSunday: true)

            let alarmClock5 = BCLAlarmClockData(timestamp: "2025-06-24 12:37:00".toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date.timeIntervalSince1970 ?? 0,
                                                repeatType: .once,
                                                vibrationEffect: .strong,
                                                isEnabled: true,
                                                isMonday: true,
                                                isTuesday: true,
                                                isWednesday: true,
                                                isThursday: true,
                                                isFriday: true,
                                                isSaturday: true,
                                                isSunday: true)
            BCLRingManager.shared.setAlarmClock(items: [alarmClock1, alarmClock2, alarmClock3, alarmClock4, alarmClock5]) { res in
                switch res {
                case let .success(response):
                    if response.status == 1 {
                        BDLogger.info("闹钟设置--成功")
                    } else {
                        BDLogger.error("闹钟设置--失败")
                    }
                case let .failure(err):
                    BDLogger.error("闹钟设置失败：\(err)")
                }
            }

            break
        case 195: // 读取闹钟配置
            BDLogger.info("读取闹钟")
            BCLRingManager.shared.readAlarmClock { res in
                switch res {
                case let .success(response):
                    BDLogger.info("读取闹钟配置成功，共有\(response.items.count)个闹钟")
                    for alarmClock in response.items {
                        BDLogger.info("闹钟时间: \(alarmClock.timestamp)")
                        BDLogger.info("重复类型: \(alarmClock.repeatType.rawValue)")
                        BDLogger.info("振动效果: \(alarmClock.vibrationEffect.rawValue)")
                        BDLogger.info("是否启用: \(alarmClock.isEnabled)")
                        BDLogger.info("星期一: \(alarmClock.isMonday)")
                        BDLogger.info("星期二: \(alarmClock.isTuesday)")
                        BDLogger.info("星期三: \(alarmClock.isWednesday)")
                        BDLogger.info("星期四: \(alarmClock.isThursday)")
                        BDLogger.info("星期五: \(alarmClock.isFriday)")
                        BDLogger.info("星期六: \(alarmClock.isSaturday)")
                        BDLogger.info("星期日: \(alarmClock.isSunday)")
                    }
                case let .failure(error):
                    BDLogger.error("读取闹钟配置失败: \(error)")
                }
            }
            break
        case 196: // 智能节假日配置
            BDLogger.info("智能节假日配置")
            let holidayData = BCLHolidayData(year: 2025, nonWeekendHolidayCount: 18, nonWeekendHolidayDays: [1, 28, 29, 30, 31, 34, 35, 94, 121, 122, 125, 153, 274, 275, 276, 279, 280, 281], workDaysCount: 5, workDays: [26, 39, 117, 271, 284])
            BCLRingManager.shared.setHoliday(holidayData: holidayData) { res in
                switch res {
                case let .success(response):
                    if response.status == 1 {
                        BDLogger.info("智能节假日配置设置成功")
                    } else {
                        BDLogger.error("智能节假日配置设置失败")
                    }
                case let .failure(err):
                    BDLogger.error("智能节假日配置设置失败: \(err)")
                }
            }

            break
        case 197: // 智能节假日配置读取
            BDLogger.info("智能节假日配置读取")
            BCLRingManager.shared.readHoliday(year: 2025) { res in
                switch res {
                case let .success(response):
                    guard let holidayData = response.holidayData else {
                        BDLogger.info("智能节假日配置读取失败，数据为空")
                        return
                    }
                    BDLogger.info("智能节假日配置读取成功")
                    BDLogger.info("智能节假日数据-年份: \(holidayData.year)")
                    BDLogger.info("智能节假日数据-全年非周末的假日天数: \(holidayData.nonWeekendHolidayCount)")
                    BDLogger.info("智能节假日数据-非周六日的假日下nonWeekendHolidayCount标的列表（一年中的第几天）: \(holidayData.nonWeekendHolidayDays)")
                    BDLogger.info("智能节假日数据-周末中的工作天数: \(holidayData.workDaysCount)")
                    BDLogger.info("智能节假日数据-周末中的调休日期（是一年中的第几天): \(holidayData.workDays)")
                case let .failure(error):
                    BDLogger.error("智能节假日配置读取失败: \(error)")
                }
            }
            break
        case 198: // 马达立刻震动
            BDLogger.info("马达立刻震动")
            BCLRingManager.shared.linearMotorImmediateVibration(type: .continuousVibration) { res in
                switch res {
                case let .success(response):
                    if response.setStatus == 1 {
                        BDLogger.info("马达立刻震动指令设置-成功")
                    } else {
                        BDLogger.info("马达立刻震动指令设置-失败")
                    }
                case let .failure(error):
                    BDLogger.error("马达立刻震动指令设置失败: \(error)")
                }
            }
            break
        case 199: // 震动马达-倒计时震动
            BDLogger.info("震动马达-倒计时震动")
            BCLRingManager.shared.linearMotorTimerVibration(seconds: 3, type: .strongVibration) { res in
                switch res {
                case let .success(response):
                    if response.setStatus == 1 {
                        BDLogger.info("震动马达-倒计时震动指令设置-成功")
                    } else {
                        BDLogger.info("震动马达-倒计时震动指令设置-失败")
                    }
                case let .failure(error):
                    BDLogger.error("震动马达-倒计时震动指令设置失败: \(error)")
                }
            }
            break
        case 200:
            let swipeUpGesture = 255
            let swipeDownGesture = 255
            let snapGesture = 255
            let pinchGesture = 255
            BCLRingManager.shared.setGestureFunction(swipeUpGesture: swipeUpGesture, swipeDownGesture: swipeDownGesture, snapGesture: snapGesture, pinchGesture: pinchGesture) { res in
                switch res {
                case let .success(response):
                    if response.setStatus == 1 {
                        BDLogger.info("设置当前HID手势2模式成功")
                        if swipeUpGesture == 255 && swipeDownGesture == 255 && snapGesture == 255 && pinchGesture == 255 {
                            BDLogger.info("当前HID手势2模式已关闭")
                            QMUITips.show(withText: "提醒用户需要手动去系统蓝牙设置页面忽略蓝牙设备，重新连接的时候需要取消配对模式")
                        } else {
                            QMUITips.show(withText: "手势功能已开启，需要选择配对模式")
                            /// 此处断开蓝牙连接，如果有开启自动重连，则会进行自动重连并触发系统弹窗（是否配对）
                            BCLRingManager.shared.disconnect(peripheral: BCLRingManager.shared.currentConnectedDevice?.peripheral)
                        }
                    } else {
                        BDLogger.info("设置当前HID手势2模式失败")
                    }
                case let .failure(error):
                    BDLogger.error("设置当前HID手势2模式失败: \(error)")
                }
            }

            break
        case 201: // PHY Boot Mode 固件升级功能
            BDLogger.info("PHY Boot Mode 升级功能")
            var phyBootDeviceMacAddress = ""
            // 首先获取当前连接的设备的MAC地址
            guard let currentConnectedDevice = BCLRingManager.shared.currentConnectedDevice, currentConnectedDevice.macAddress?.isEmpty == false else {
                BDLogger.error("当前没有连接的设备或设备MAC地址为空")
                return
            }
            phyBootDeviceMacAddress = currentConnectedDevice.macAddress!
            BDLogger.info("当前Phy Boot Mode 升级设备的MAC地址: \(phyBootDeviceMacAddress)")
            BDLogger.info("当前Phy Boot Mode 设备升级完成后的地址则为:\(decrementMac(macAddress: phyBootDeviceMacAddress) ?? "Mac地址获取失败")")
            // 如果戒指的固件升级模式为.phy的，存在戒指在固件升级过程中，因连接断开等因素导致的固件升级中断，则戒指会进入到boot模式。
            // 此模式下戒指表现为名字为包含PPlus OTA信息，以及戒指的MAC地址最后一位会自动+1
            // 首先查找设备名称包含 PPlusOTA 的设备，并进行连接。
            guard let currentConnectedDevice = BCLRingManager.shared.currentConnectedDevice, currentConnectedDevice.isPhyBootMode else {
                BDLogger.error("当前设备不支持PHY Boot Mode升级功能")
                return
            }

            // 📢 根据实际情况选择以下两种 方式之一进行PHY Boot Mode升级：
            // -----------------------------------------------------------------------------------------------------------------------------------------------------------

            // 1、根据自身是否有固件版本号执行不同的逻辑，如果有固件版本信息，则可以直接通过当前的固件版本信息去检查是否有需要升级的固件版本，然后下载最新的固件文件后，进行PHY Boot Mode升级
            // a、检查固件版本更新
//            let currentFirmwareVersion = "2.4.8.0Z34"
//            BCLRingManager.shared.checkFirmwareUpdate(version: currentFirmwareVersion) { result in
//                switch result {
//                case let .success(versionInfo):
//                    //  有新版本固件可以进行升级
//                    if versionInfo.hasNewVersion {
//                        BDLogger.info("""
//                        ✅ 发现新版本：
//                        - 版本号：\(versionInfo.version ?? "")
//                        - 下载地址：\(versionInfo.downloadUrl ?? "")
//                        - 文件名：\(versionInfo.fileName ?? "")
//                        """)
//
//                        // b、下载固件文件
//                        guard let fileName = versionInfo.fileName,
//                              let downloadUrl = versionInfo.downloadUrl,
//                              !fileName.isEmpty,
//                              !downloadUrl.isEmpty else {
//                            BDLogger.error("❌ 无法获取固件文件名或下载地址")
//                            return
//                        }
//                        let destinationPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//                        BCLRingManager.shared.downloadFirmware(url: downloadUrl, fileName: fileName, destinationPath: destinationPath, progress: { progress in
//                            BDLogger.info("固件下载进度：\(progress)")
//                        }, completion: { result in
//                            switch result {
//                            case let .success(filePath):
//                                BDLogger.info("固件下载成功：\(filePath)")
//                                // c、执行PHY Boot Mode升级
//                                // 检查文件扩展名是否为.hex16
//                                guard filePath.lowercased() == "hex16" else {
//                                    BDLogger.error("请选择.hex16格式的固件文件")
//                                    return
//                                }
//                                BDLogger.info("选择的文件：\(filePath)")
//                                BDLogger.info("开始Phy Boot Mode 固件升级...")
//                                // 如果开启了自动重连，需要先关掉。
//                                BCLRingManager.shared.isAutoReconnectEnabled = false
//                                BCLRingManager.shared.phyBootModeUpgrade(
//                                    filePath: filePath,
//                                    device: BCLRingManager.shared.currentConnectedDevice!,
//                                    peripheral: BCLRingManager.shared.currentConnectedDevice!.peripheral
//                                ) { progress in
//                                    BDLogger.info("PHY Boot Mode 升级进度: \(progress)%")
//                                } completion: { result in
//                                    switch result {
//                                    case let .success(response):
//                                        switch response {
//                                        case .preparing:
//                                            BDLogger.info("PHY Boot Mode 升级中: 准备中...")
//                                        case .bootModeConnected:
//                                            BDLogger.info("PHY Boot Mode 升级中: 已连接到Boot模式设备...")
//                                        case .upgrading:
//                                            BDLogger.info("PHY Boot Mode 升级中: 文件传传输中...")
//                                        case .upgradingCompleted:
//                                            BDLogger.info("PHY Boot Mode 升级中: 文件传输完成，准备退出Boot模式...")
//                                        case .exitingBootMode:
//                                            BDLogger.info("PHY Boot Mode 升级中: 正在退出Boot模式...")
//                                        case .success:
//                                            BDLogger.info("✅ PHY Boot Mode 升级成功: \(response)")
//                                            // TODO: 升级成功后可以选择重新连接设备
//                                            // 将Phy Boot 模式下的Mac地址进行-1操作，然后进行重新连接设备
//                                            guard let targetDeviceMacAddress = self.decrementMac(macAddress: phyBootDeviceMacAddress) else {
//                                                BDLogger.error("❌ 获取目标设备的MAC地址失败,无法重连蓝牙设备")
//                                                return
//                                            }
//                                            BDLogger.info("升级成功后，目标设备的MAC地址: \(targetDeviceMacAddress)")
//                                            self.connectDevice(macAddress: targetDeviceMacAddress)
//                                        case let .failed(errString):
//                                            BDLogger.error("❌ PHY Boot Mode 升级失败: \(errString)")
//                                        }
//                                    case let .failure(error):
//                                        BDLogger.error("❌ PHY Boot Mode 升级失败: \(error)")
//                                    }
//                                }
//                            case let .failure(error):
//                                BDLogger.error("固件下载失败：\(error)")
//                            }
//                        })
//                    } else {
//                        BDLogger.info("✅ 当前已是最新版本")
//                        // 如果当前版本已经是最新的，没有最新版本固件可以下载，则可以通过固件版本历史信息去查询最新的固件文件进行PHY Boot Mode升级
//                    }
//                    BDLogger.info("📝 消息：\(String(describing: versionInfo.version))")
//                case let .failure(error):
//                    switch error {
//                    case let .network(.invalidParameters(message)):
//                        BDLogger.error("❌ 参数无效，请检查版本号格式: \(message)")
//                    case let .network(.httpError(code)):
//                        BDLogger.error("❌ HTTP请求失败：状态码 \(code)")
//                    case let .network(.serverError(code, message)):
//                        BDLogger.error("❌ 服务器错误：[\(code)] \(message)")
//                    case .network(.invalidResponse):
//                        BDLogger.error("❌ 响应数据无效")
//                    case let .network(.decodingError(error)):
//                        BDLogger.error("❌ 数据解析失败：\(error.localizedDescription)")
//                    case let .network(.networkError(message)):
//                        BDLogger.error("❌ 网络错误：\(message)")
//                    case let .network(.tokenError(message)):
//                        BDLogger.error("❌ Token异常：\(message)")
//                    default:
//                        BDLogger.error("❌ 其他错误：\(error)")
//                    }
//                }
//            }

            // -----------------------------------------------------------------------------------------------------------------------------------------------------------

//            // 2、如果没有固件版本信息，则可以根据固件分配的编码例如：Q1W、Q2W、Q3W信息去查询固件历史版本信息，然后取最新版本的固件文件进行下载后，执行PHY Boot Mode升级
//            // 同样查找并连接戒指 名称包含 PPlusOTA 的设备，并进行连接。
//
//            // 通过标识查找固件版本信息列表
//            // 📢 注意：以下的 category 固件类别 标识 需要根据实际设备的固件类别进行替换 例如：Z21、Z34等，防止下载到错误的固件文件，导致蓝牙设备变砖
//            BCLRingManager.shared.getFirmwareVersionList(category: "000") { result in
//                switch result {
//                case let .success(response):
//                    BDLogger.info("固件历史版本-总个数: \(response.count)")
//                    // 解析版本号并找出最新版本
//                    let latestVersion = self.findLatestVersion(from: response)
//                    if let latest = latestVersion {
//                        let latestFileName = self.getFileName(from: latest)
//                        let latestFileUrl = self.getFileUrl(from: latest)
//                        BDLogger.info("✅ 找到最新版本：\(latestFileName)")
//                        BDLogger.info("✅ 最新版本号：\(self.extractVersionNumber(from: latestFileName))")
//                        BDLogger.info("✅ 最新版本下载链接：\(latestFileUrl)")
//                        guard !latestFileName.isEmpty, !latestFileUrl.isEmpty else {
//                            BDLogger.error("文件名或下载URL为空")
//                            return
//                        }
//                        BDLogger.info("开始下载最新固件：\(latestFileName)")
//
//                        // 获取文档目录路径
//                        let destinationPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//
//                        // 调用固件的下载方法
//                        BCLRingManager.shared.downloadFirmware(
//                            url: latestFileUrl,
//                            fileName: latestFileName,
//                            destinationPath: destinationPath,
//                            progress: { progress in
//                                BDLogger.info("固件下载进度：\(progress)%")
//                            },
//                            completion: { result in
//                                switch result {
//                                case let .success(filePath):
//                                    BDLogger.info("✅ 固件下载成功：\(filePath)")
//                                    guard let currentDevice = BCLRingManager.shared.currentConnectedDevice else {
//                                        BDLogger.error("当前没有连接的设备")
//                                        return
//                                    }
//                                    BDLogger.info("开始PHY Boot Mode升级...")
//                                    // 如果开启了自动重连，需要先关掉。
//                                    BCLRingManager.shared.isAutoReconnectEnabled = false
//                                    BCLRingManager.shared.phyBootModeUpgrade(
//                                        filePath: filePath,
//                                        device: currentDevice,
//                                        peripheral: currentDevice.peripheral
//                                    ) { progress in
//                                        BDLogger.info("PHY Boot Mode 升级进度: \(progress)%")
//                                    } completion: { result in
//                                        switch result {
//                                        case let .success(response):
//                                            switch response {
//                                            case .preparing:
//                                                BDLogger.info("PHY Boot Mode 升级中: 准备中...")
//                                            case .bootModeConnected:
//                                                BDLogger.info("PHY Boot Mode 升级中: 已连接到Boot模式设备...")
//                                            case .upgrading:
//                                                BDLogger.info("PHY Boot Mode 升级中: 文件传传输中...")
//                                            case .upgradingCompleted:
//                                                BDLogger.info("PHY Boot Mode 升级中: 文件传输完成，准备退出Boot模式...")
//                                            case .exitingBootMode:
//                                                BDLogger.info("PHY Boot Mode 升级中: 正在退出Boot模式...")
//                                            case .success:
//                                                BDLogger.info("✅ PHY Boot Mode 升级成功: \(response)")
//                                                // 📢 需要将Phy Boot 模式下的Mac地址进行-1操作，然后进行重新连接设备
//                                                guard let targetDeviceMacAddress = self.decrementMac(macAddress: phyBootDeviceMacAddress) else {
//                                                    BDLogger.error("❌ 获取目标设备的MAC地址失败,无法重连蓝牙设备")
//                                                    return
//                                                }
//                                                BDLogger.info("升级成功后，目标设备的MAC地址: \(targetDeviceMacAddress)")
//                                                self.connectDevice(macAddress: targetDeviceMacAddress)
//                                            case let .failed(errString):
//                                                BDLogger.error("❌ PHY Boot Mode 升级失败: \(errString)")
//                                            }
//                                        case let .failure(error):
//                                            BDLogger.error("❌ PHY Boot Mode 升级失败: \(error)")
//                                        }
//                                    }
//                                case let .failure(error):
//                                    BDLogger.error("❌ 固件下载失败：\(error)")
//                                }
//                            }
//                        )
//                    } else {
//                        BDLogger.error("❌ 未找到有效的固件版本")
//                    }
//                case let .failure(error):
//                    BDLogger.error("获取固件历史版本失败: \(error)")
//                }
//            }

            // 📢 注意：如果需要在手机上选择文件进行PHY Boot Mode升级，请使用以下代码实现文件选择器
            // ------------------------------------------------------------------------------------------------------------------------------------------------------------
            curFirmwareUpgradeType = .phyBootMode
            // 实现打开文件选择器
            let filePicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
            filePicker.delegate = self
            filePicker.allowsMultipleSelection = false
            present(filePicker, animated: true, completion: nil)
            break

        case 202: // 开始老化测试
            BDLogger.info("开始老化测试")
            BCLRingManager.shared.setAgingMode(mode: 0) { result in
                switch result {
                case let .success(response):
                    BDLogger.info("老化测试开始-成功 \n 当前模式：\(response.agingMode)")
                case let .failure(error):
                    BDLogger.error("老化测试开始-失败: \(error)")
                }
            }
            break
        case 203: // 读取老化测试信息
            BDLogger.info("读取老化测试信息")
            BCLRingManager.shared.readAgingModeInfo { result in
                switch result {
                case let .success(response):
                    BDLogger.info("读取老化测试信息-成功")
                    BDLogger.info("老化信息-总时长（分钟）: \(response.totalDurationMinutes)")
                    BDLogger.info("老化信息-开始时间戳: \(response.startTime)")
                    BDLogger.info("老化信息-结束时间戳: \(response.endTime)")
                    BDLogger.info("老化信息-老化状态: \(response.agingStatus)")
                    BDLogger.info("老化信息-充电最高温度: \(Float(response.maxChargeTemp) / 100.0)°C")
                    BDLogger.info("老化信息-充电最高温度时长: \(response.maxChargeTempTime)")
                case let .failure(error):
                    BDLogger.error("读取老化测试信息-失败: \(error)")
                }
            }
            break
        case 204: // 特定固件步数获取
            BDLogger.info("特定固件步数获取")
            BCLRingManager.shared.queryStepInfo(mac: "42:4A:2D:2C:E1:6E") { res in
                switch res {
                case let .success(response):
                    BDLogger.info("特定固件步数获取-成功")
                    BDLogger.info("步数信息-总步数: \(response)")
                case let .failure(error):
                    BDLogger.error("特定固件步数获取-失败: \(error)")
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
        BCLRingManager.shared.startBloodOxygen(collectTime: 30,
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
        let callBacks = BCLHeartRateCallbacks(
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
        )

        // 开始测量
        BCLRingManager.shared.startHeartRate(collectTime: 30,
                                             collectFrequency: 25,
                                             waveformConfig: 1,
                                             progressConfig: 1,
                                             intervalConfig: 1,
                                             callbacks: callBacks) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                BDLogger.error("启动心率测量失败: \(error)")
            }
        }
    }

    // 心率变异性测量
    func startHeartRateVariabilityMeasurement() {
        let callBacks = BCLHeartRateCallbacks(
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
        )

        // 开始测量
        BCLRingManager.shared.startHeartRate(collectTime: 30,
                                             collectFrequency: 25,
                                             waveformConfig: 1,
                                             progressConfig: 1,
                                             intervalConfig: 1,
                                             callbacks: callBacks) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                BDLogger.error("启动心率变异性测量失败: \(error)")
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
            // 如果开启了自动重连，需要先关掉。
            BCLRingManager.shared.isAutoReconnectEnabled = false
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
        } else if curFirmwareUpgradeType == .phyBootMode {
            // 检查文件扩展名是否为.hex16
            guard fileURL.pathExtension.lowercased() == "hex16" else {
                BDLogger.error("请选择.hex16格式的固件文件")
                return
            }
            BDLogger.info("选择的文件：\(fileURL)")
            BDLogger.info("文件名称：\(fileURL.lastPathComponent)")
            BDLogger.info("开始Phy Boot Mode 固件升级...")
            BCLRingManager.shared.isAutoReconnectEnabled = false
            BCLRingManager.shared.phyBootModeUpgrade(filePath: fileURL.path, device: BCLRingManager.shared.currentConnectedDevice!, peripheral: BCLRingManager.shared.currentConnectedDevice!.peripheral) { progress in
                BDLogger.info("PHY Boot Mode 升级进度: \(progress)%")
            } completion: { res in
                switch res {
                case let .success(response):
                    BDLogger.info("PHY Boot Mode 升级成功: \(response)")
                case let .failure(error):
                    BDLogger.error("PHY Boot Mode 升级失败: \(error)")
                }
            }
        }
    }
}

// MARK: - 版本号处理工具方法

extension Main_VC {
    /// 从文件名中提取版本号
    /// - Parameter fileName: 文件名，例如 "2.7.5.0Z3N.hex16"
    /// - Returns: 版本号字符串，例如 "2.7.5.0"
    private func extractVersionNumber(from fileName: String) -> String {
        // 使用正则表达式匹配版本号格式
        let pattern = #"^(\d+\.\d+\.\d+\.\d+)"#

        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: fileName, range: NSRange(fileName.startIndex..., in: fileName)) {
            let versionRange = Range(match.range(at: 1), in: fileName)!
            return String(fileName[versionRange])
        }

        // 如果正则匹配失败，使用简单的字符串分割
        let components = fileName.components(separatedBy: "Z")
        if let firstComponent = components.first {
            return firstComponent
        }

        return ""
    }

    /// 比较两个版本号
    /// - Parameters:
    ///   - version1: 第一个版本号
    ///   - version2: 第二个版本号
    /// - Returns: 比较结果：-1表示version1更旧，0表示相等，1表示version1更新
    private func compareVersions(_ version1: String, _ version2: String) -> Int {
        let components1 = version1.components(separatedBy: ".").compactMap { Int($0) }
        let components2 = version2.components(separatedBy: ".").compactMap { Int($0) }

        let maxLength = max(components1.count, components2.count)

        for i in 0 ..< maxLength {
            let num1 = i < components1.count ? components1[i] : 0
            let num2 = i < components2.count ? components2[i] : 0

            if num1 < num2 {
                return -1
            } else if num1 > num2 {
                return 1
            }
        }

        return 0
    }

    /// 从固件版本列表中找出最新版本
    /// - Parameter versions: 固件版本列表
    /// - Returns: 最新版本的固件信息
    private func findLatestVersion(from versions: [Any]) -> Any? {
        var latestVersion: Any?
        var latestVersionNumber = ""

        for version in versions {
            // 使用 Mirror 反射来获取 fileName 属性
            let mirror = Mirror(reflecting: version)
            var fileName: String?

            for child in mirror.children {
                if child.label == "fileName" {
                    fileName = child.value as? String
                    break
                }
            }

            if let fileName = fileName {
                let versionNumber = extractVersionNumber(from: fileName)

                if versionNumber.isEmpty {
                    continue
                }

                if latestVersion == nil {
                    latestVersion = version
                    latestVersionNumber = versionNumber
                } else {
                    let comparison = compareVersions(versionNumber, latestVersionNumber)
                    if comparison > 0 {
                        latestVersion = version
                        latestVersionNumber = versionNumber
                    }
                }
            }
        }

        return latestVersion
    }

    /// 从固件版本对象中获取文件名
    /// - Parameter version: 固件版本对象
    /// - Returns: 文件名
    private func getFileName(from version: Any) -> String {
        let mirror = Mirror(reflecting: version)
        for child in mirror.children {
            if child.label == "fileName" {
                return child.value as? String ?? ""
            }
        }
        return ""
    }

    /// 从固件版本对象中获取文件URL
    /// - Parameter version: 固件版本对象
    /// - Returns: 文件URL
    private func getFileUrl(from version: Any) -> String {
        let mirror = Mirror(reflecting: version)
        for child in mirror.children {
            if child.label == "fileUrl" {
                return child.value as? String ?? ""
            }
        }
        return ""
    }

    /// 递增MAC地址(当前Mac地址+1)
    /// - Parameter macAddress: MAC地址
    /// - Returns: 递增后的MAC地址
    func incrementMac(macAddress: String) -> String? {
        let components = macAddress.components(separatedBy: ":")
        var bytes = [UInt8]()

        for component in components {
            if let byte = UInt8(component, radix: 16) {
                bytes.append(byte)
            } else {
                return nil // 非法的MAC地址格式
            }
        }

        for i in (0 ..< 6).reversed() {
            if bytes[i] < 255 {
                bytes[i] += 1
                break
            } else {
                bytes[i] = 0
            }
        }

        let incrementedMacAddress = bytes.map { String(format: "%02X", $0) }.joined(separator: ":")
        return incrementedMacAddress
    }

    /// 递减MAC地址(当前Mac地址-1)
    /// - Parameter macAddress: MAC地址
    /// - Returns: 递减后的MAC地址
    func decrementMac(macAddress: String) -> String? {
        let components = macAddress.components(separatedBy: ":")
        var bytes = [UInt8]()

        for component in components {
            if let byte = UInt8(component, radix: 16) {
                bytes.append(byte)
            } else {
                return nil // 非法的MAC地址格式
            }
        }

        for i in (0 ..< 6).reversed() {
            if bytes[i] > 0 {
                bytes[i] -= 1
                break
            } else {
                bytes[i] = 255
            }
        }

        let decrementedMacAddress = bytes.map { String(format: "%02X", $0) }.joined(separator: ":")
        return decrementedMacAddress
    }
}
