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

///// 固件升级类型
//public enum FirmwareUpgradeType {
//    case apollo // 阿波罗（Ambiq）升级
//    case nordic // Nordic DFU 升级
//    case phy // Phy 固件升级
//    case phyBootMode // Phy Bootloader 固件升级
//}
//
//class Main_VC: UIViewController {
//    //  蓝牙设备列表页面
//    private lazy var deviceTableVC: DeviceTableVC = {
//        let vc = DeviceTableVC()
//        return vc
//    }()
//
//    // LogVC
//    private lazy var logVC: Log_VC = {
//        let vc = Log_VC()
//        return vc
//    }()
//
//    @IBOutlet var reconnect_Btn: UIButton!
//
//    @IBOutlet var name_Label: UILabel!
//    @IBOutlet var mac_Label: UILabel!
//    @IBOutlet var connect_Label: UILabel!
//    @IBOutlet var rssi_Label: UILabel!
//    private let disposeBag = DisposeBag()
//    // 历史数据
//    private var historyData: [BCLRingDBModel] = []
//
//    // 血压波形数据
//    private var bloodPressureWaveData: [(Int, Int, Int, Int, Int)] = []
//    private var curFirmwareUpgradeType: FirmwareUpgradeType = .apollo
//
//    // 自定义指令ID（用于停止监听）
//    private var customCommandId: String?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        overrideUserInterfaceStyle = .light
//
//        // 配置日志级别，控制台可按需打印日志
////        BCLRingManager.shared.configLogLevels(consoleLogLevel: .verbose)
////        BCLRingManager.shared.manufacturerID = .KK
//        BCLRingManager.shared.commandTimeout = 8
//
//        // 显示悬浮窗
//        FloatingWindowManager.shared.show()
//
//        // 蓝牙状态
//        BCLRingManager.shared.systemBluetoothStateBlock = { state in
//            if state == .poweredOn {
//                BDLogger.info("系统蓝牙已打开")
//            } else {
//                BDLogger.info("系统蓝牙不可用")
//            }
//        }
//
//        // 电量推送
//        BCLRingManager.shared.batteryNotifyBlock = { batteryLevel in
//            BDLogger.info("电量推送Block: \(batteryLevel)")
//        }
//
////        //  蓝牙设备连接状态Block方式
////        BCLRingManager.shared.bluetoothConnectStateBlock = { state in
////            switch state {
////            case .connecting:
////                self.name_Label.text = "设备名称："
////                self.mac_Label.text = "MAC地址："
////                self.connect_Label.text = "连接状态：连接中..."
////                self.rssi_Label.text = "RSSI："
////                break
////            case .characteristicProcessingCompleted:
////                let deviceInfo = BCLRingManager.shared.currentConnectedDevice
////                guard let deviceInfo = deviceInfo else {
////                    self.name_Label.text = "设备名称："
////                    self.mac_Label.text = "MAC地址："
////                    self.connect_Label.text = "连接状态：未连接"
////                    self.rssi_Label.text = "RSSI："
////                    return
////                }
////                self.name_Label.text = "设备名称：\(deviceInfo.peripheralName ?? "")"
////                self.mac_Label.text = "MAC地址：\(deviceInfo.macAddress ?? "")"
////                self.connect_Label.text = "连接状态：已连接"
////                self.rssi_Label.text = "RSSI：\(deviceInfo.rssi ?? 0)"
////                break
////            default:
////                self.name_Label.text = "设备名称："
////                self.mac_Label.text = "MAC地址："
////                self.connect_Label.text = "连接状态：未连接"
////                self.rssi_Label.text = "RSSI："
////                break
////            }
////        }
//
////        //  蓝牙设备连接状态RX监听
////        BCLRingManager.shared.bluetoothConnectStateObservable.subscribe(onNext: { state in
////            switch state {
////            case .connecting:
////                self.name_Label.text = "设备名称："
////                self.mac_Label.text = "MAC地址："
////                self.connect_Label.text = "连接状态：连接中..."
////                self.rssi_Label.text = "RSSI："
////                break
////            case .characteristicProcessingCompleted:
////                let deviceInfo = BCLRingManager.shared.currentConnectedDevice
////                if let advertisementData = deviceInfo?.advertisementData as? [String: Any] {
////                    BDLogger.info("广播数据：\(advertisementData)")
////                }
////                if let advDataManufacturerData = deviceInfo?.advDataManufacturerData as? Data {
////                    BDLogger.info("蓝牙制造商数据：\(advDataManufacturerData)")
////                    let hexString = advDataManufacturerData.map { String(format: "%02X", $0) }.joined()
////                    BDLogger.info("蓝牙制造商数据（Hex）：\(hexString)")
////                }
////                BDLogger.info("蓝牙广播协议中充电指示位：\(deviceInfo?.chargingIndicator ?? 0)")
////                BDLogger.info("蓝牙广播协议中绑定指示位：\(deviceInfo?.bindingIndicatorBit ?? 0)")
////                BDLogger.info("蓝牙广播协议中通讯协议版本号：\(deviceInfo?.communicationProtocolVersion ?? 0)")
////                guard let deviceInfo = deviceInfo else {
////                    self.name_Label.text = "设备名称："
////                    self.mac_Label.text = "MAC地址："
////                    self.connect_Label.text = "连接状态：未连接"
////                    self.rssi_Label.text = "RSSI："
////                    return
////                }
////                self.name_Label.text = "设备名称：\(deviceInfo.peripheralName ?? "")"
////                self.mac_Label.text = "MAC地址：\(deviceInfo.macAddress ?? "")"
////                self.connect_Label.text = "连接状态：已连接"
////                self.rssi_Label.text = "RSSI：\(deviceInfo.rssi ?? 0)"
////
////                UserDefaults.standard.set(deviceInfo.macAddress, forKey: "ring_macAddress")
////                UserDefaults.standard.set(deviceInfo.peripheralName, forKey: "ring_peripheralName")
////                UserDefaults.standard.set(deviceInfo.peripheral.identifier.uuidString, forKey: "ring_uuidString")
////                break
////            default:
////                self.name_Label.text = "设备名称："
////                self.mac_Label.text = "MAC地址："
////                self.connect_Label.text = "连接状态：未连接"
////                self.rssi_Label.text = "RSSI："
////                break
////            }
////        }).disposed(by: disposeBag)
//
//        //  简化版本连接状态回调
//        BCLRingManager.shared.deviceIsDidConnectedBlock = { state in
//            switch state {
//            case .connected:
//                BDLogger.info("设备已连接-简化版本")
//                if let connectedDevice = BCLRingManager.shared.currentConnectedDevice {
//                    self.name_Label.text = "设备名称：\(connectedDevice.peripheralName ?? "")"
//                    self.mac_Label.text = "MAC地址：\(connectedDevice.macAddress ?? "")"
//                    self.connect_Label.text = "连接状态：已连接"
//                    self.rssi_Label.text = "RSSI：\(connectedDevice.rssi ?? 0)"
//                } else {
//                    BDLogger.error("当前没有已连接的设备信息")
//                    self.name_Label.text = "设备名称："
//                    self.mac_Label.text = "MAC地址："
//                    self.connect_Label.text = "连接状态：未连接"
//                    self.rssi_Label.text = "RSSI："
//                }
//            case .connecting:
//                BDLogger.info("设备连接中...-简化版本")
//                if let pendingDevice = BCLRingManager.shared.pendingDeviceInfo {
//                    self.name_Label.text = "设备名称：\(pendingDevice.peripheralName ?? "")"
//                    self.mac_Label.text = "MAC地址：\(pendingDevice.macAddress ?? "")"
//                    self.connect_Label.text = "连接状态：连接中"
//                    self.rssi_Label.text = "RSSI：\(pendingDevice.rssi ?? 0)"
//                } else {
//                    BDLogger.error("当前没有连接中的设备信息")
//                    self.name_Label.text = "设备名称："
//                    self.mac_Label.text = "MAC地址："
//                    self.connect_Label.text = "连接状态：未连接"
//                    self.rssi_Label.text = "RSSI："
//                }
//            case .disconnected:
//                BDLogger.info("设备已断开连接-简化版本")
//                self.name_Label.text = "设备名称："
//                self.mac_Label.text = "MAC地址："
//                self.connect_Label.text = "连接状态：未连接"
//                self.rssi_Label.text = "RSSI："
//            }
//        }
//
////        //  待连接的蓝牙设备信息
////        BCLRingManager.shared.pendingPeripheralDeviceInfoObservable.subscribe(onNext: { deviceInfo in
////            BDLogger.info("待连接设备信息: \(String(describing: deviceInfo))")
////            guard let deviceInfo = deviceInfo else {
////                BDLogger.error("待连接设备信息为空")
////                return
////            }
////            self.name_Label.text = "设备名称：\(deviceInfo.peripheralName ?? "")"
////            self.mac_Label.text = "MAC地址：\(deviceInfo.macAddress ?? "")"
////            self.connect_Label.text = "连接状态：连接中"
////            self.rssi_Label.text = "RSSI：\(deviceInfo.rssi ?? 0)"
////        }).disposed(by: disposeBag)
////
////        //  已连接的蓝牙设备信息
////        BCLRingManager.shared.connectedPeripheralDeviceInfoObservable.subscribe(onNext: { deviceInfo in
////            BDLogger.info("已连接的蓝牙设备信息: \(String(describing: deviceInfo))")
////            guard let deviceInfo = deviceInfo else {
////                BDLogger.error("待连接设备信息为空")
////                return
////            }
////            self.name_Label.text = "设备名称：\(deviceInfo.peripheralName ?? "")"
////            self.mac_Label.text = "MAC地址：\(deviceInfo.macAddress ?? "")"
////            self.connect_Label.text = "连接状态：已连接"
////            self.rssi_Label.text = "RSSI：\(deviceInfo.rssi ?? 0)"
////        }).disposed(by: disposeBag)
//
//        // 用于记录上次连接过的设备信息，应用启动后可选择是否自动连接
//        let macAddress = UserDefaults.standard.string(forKey: "ring_macAddress")
//        let peripheralName = UserDefaults.standard.string(forKey: "ring_peripheralName")
//
//        BDLogger.info("尝试读取已保存的设备信息 - MAC: \(macAddress ?? "nil"), 设备名: \(peripheralName ?? "nil")")
//
//        if let macAddress = macAddress {
//            let alert = UIAlertController(title: "提示", message: "是否自动连接设备？\n 设备MAC地址：\(macAddress) \n 设备名称：\(peripheralName ?? "未知")", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
//                self.connectDevice(macAddress: macAddress)
//            }))
//            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
//            present(alert, animated: true, completion: nil)
//        } else {
//            BDLogger.info("未找到已保存的设备信息，跳过自动连接提示")
//        }
//    }
//
//    // 连接设备
//    func connectDevice(macAddress: String) {
//        QMUITips.showLoading("Device Connecting...", in: view)
//        QMUITips.hideAllTips(in: view)
//        BCLRingManager.shared.startConnect(macAddress: macAddress, isAutoReconnect: true, autoReconnectTimeLimit: 1000, autoReconnectMaxAttempts: 5000) { result in
//            switch result {
//            case .success:
//                BDLogger.info("connect success")
//                QMUITips.hideAllTips(in: self.view)
//            case let .failure(error):
//                BDLogger.error("connect failed: \(error)")
//                QMUITips.hideAllTips(in: self.view)
//                QMUITips.showError("Connect Failed", in: self.view)
//            }
//        }
//    }
//
//    // MARK: - IBAction
//
//    @IBAction func logAction(_ sender: UIButton) {
//        navigationController?.pushViewController(logVC, animated: true)
//    }
//
//    @IBAction func btnAction(_ sender: UIButton) {
//        case 113: //    心率变异性
//            startHeartRateVariabilityMeasurement()
//            break
//        case 121: //    睡眠数据
//            BCLRingManager.shared.getSleepData(date: Date(), timeZone: .East8) { result in
//                switch result {
//                case let .success(sleepData):
//                    BDLogger.info("睡眠数据: \(sleepData)")
//                case let .failure(error):
//                    switch error {
//                    case let .network(.invalidParameters(message)):
//                        BDLogger.error("❌ 参数无效，请检查API Key和用户ID: \(message)")
//                    case let .network(.httpError(code)):
//                        BDLogger.error("❌ HTTP错误：\(code)")
//                    case let .network(.serverError(code, message)):
//                        BDLogger.error("❌ 服务器错误[\(code)]: \(message)")
//                    case .network(.invalidResponse):
//                        BDLogger.error("❌ 响应数据无效")
//                    case let .network(.decodingError(error)):
//                        BDLogger.error("❌ 数据解析失败: \(error)")
//                    case let .network(.networkError(message)):
//                        BDLogger.error("❌ 网络错误: \(message)")
//                    case let .network(.tokenError(message)):
//                        BDLogger.error("❌ Token异常: \(message)")
//                    default:
//                        BDLogger.error("❌ 其他错误: \(error)")
//                    }
//                }
//            }
//            break
//        case 123: //    固件版本更新检查
//            // 7.1.5.3Z3R / 7.1.7.0Z3R / (RH18:2.7.5.2Z3N) / 2.7.4.8Z27 / 7.2.0.2Z3R
//            BCLRingManager.shared.checkFirmwareUpdate(version: "5.5.1.6Z2Y") { result in
//                switch result {
//                case let .success(versionInfo):
//                    if versionInfo.hasNewVersion {
//                        BDLogger.info("""
//                        ✅ 发现新版本：
//                        - 版本号：\(versionInfo.version ?? "")
//                        - 下载地址：\(versionInfo.downloadUrl ?? "")
//                        - 文件名：\(versionInfo.fileName ?? "")
//                        """)
//                    } else {
//                        BDLogger.info("✅ 当前已是最新版本")
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
//            break
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
//        case 145: // 日志压缩
//            QMUITips.showLoading(in: view)
//            BCLRingManager.shared.compressLogAndDataFiles(fromDate: "2025-09-17") { res in
//                QMUITips.hideAllTips()
//                switch res {
//                case let .success(result):
//                    BDLogger.info("文件路径：\(result.0)")
//                    BDLogger.info("文件：\(result.1)")
//                case let .failure(error):
//                    BDLogger.error("压缩文件失败：\(error)")
//                }
//            }
//            break
//        case 146: // 清理压缩文件
//            BCLRingManager.shared.cleanCompressedFiles { res in
//                switch res {
//                case .success:
//                    BDLogger.info("清理压缩文件成功")
//                case let .failure(error):
//                    BDLogger.error("清理压缩文件失败: \(error)")
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
//        case 162: // 批量获取睡眠数据
//            BDLogger.info("批量获取睡眠数据")
//            let dates = ["2025-05-01", "2025-05-02", "2025-05-03", "2025-05-04", "2025-05-05", "2025-05-06", "2025-05-07", "2025-05-08", "2025-05-09", "2025-05-10", "2025-05-11", "2025-05-12", "2025-05-13"]
//            BCLRingManager.shared.getSleepDataByTimeRange(datas: dates) { res in
//                switch res {
//                case let .success(datas):
//                    BDLogger.info("批量获取睡眠数据成功: \(datas)")
//                case let .failure(error):
//                    BDLogger.error("批量获取睡眠数据失败: \(error)")
//                }
//            }
//            break
//
//        case 163: // 获取文件系统列表
//            BDLogger.info("获取文件系统列表")
//            BCLRingManager.shared.getFileList { res in
//                switch res {
//                case let .success(response):
//                    BDLogger.info("获取文件系统列表成功: \(response)")
//                    BDLogger.info("文件系统列表-总个数: \(response.fileTotalCount ?? 0)")
//                    BDLogger.info("文件系统列表-当前索引: \(response.fileIndex ?? 0)")
//                    BDLogger.info("文件系统列表-文件大小: \(response.fileSize ?? 0)")
//                    BDLogger.info("文件系统列表-用户ID: \(response.userId ?? "")")
//                    BDLogger.info("文件系统列表-日期: \(response.fileDate ?? "")")
//                    BDLogger.info("文件系统列表-文件名: \(response.fileName ?? "")")
//                    BDLogger.info("文件系统列表-文件类型: \(response.fileType ?? 0)")
//                case let .failure(error):
//                    BDLogger.error("获取文件系统列表失败: \(error)")
//                }
//            }
//            break
//        case 164: // 请求文件的数据
//            BDLogger.info("请求文件的数据")
//            // 临时测试文件名
//            let fileName = "010203040506_2025_09_02_14_43_19_9.bin"
//            BCLRingManager.shared.getFileData(fileName: fileName) { res in
//                switch res {
//                case let .success(response):
//                    BDLogger.info("获取文件数据成功: \(response)")
//                    BDLogger.info("文件数据-状态: \(response.fileSystemStatus ?? 0)")
//                    BDLogger.info("文件数据-大小: \(response.fileSize ?? 0)")
//                    BDLogger.info("文件数据-总包数: \(response.totalNumber ?? 0)")
//                    BDLogger.info("文件数据-当前包号: \(response.currentNumber ?? 0)")
//                    BDLogger.info("文件数据-当前包长度: \(response.currentLength ?? 0)")
//                    guard let fileType = response.fileType, fileType >= 1 || fileType <= 9 else {
//                        BDLogger.info("未知的文件类型")
//                        return
//                    }
//                    if fileType == 1 {
//                        BDLogger.info("文件数据:三轴数据-数据：\(response.fileDataType1 ?? [])")
//                    } else if fileType == 2 {
//                        BDLogger.info("文件数据:六轴数据-数据：\(response.fileDataType2 ?? [])")
//                    } else if fileType == 3 {
//                        BDLogger.info("文件数据:PPG数据红外+红色+x加速度+y加速度+z加速度-数据：\(response.fileDataType3 ?? [])")
//                    } else if fileType == 4 {
//                        BDLogger.info("文件数据:PPG数据绿色-数据：\(response.fileDataType4 ?? [])")
//                    } else if fileType == 5 {
//                        BDLogger.info("文件数据:PPG数据红外-数据：\(response.fileDataType5 ?? [])")
//                    } else if fileType == 6 {
//                        BDLogger.info("文件数据:温度数据红外-数据：\(response.fileDataType6 ?? [])")
//                    } else if fileType == 7 {
//                        // (时间戳,[(绿色+红色+红外+加速度X+加速度Y+加速度Z+陀螺仪X+陀螺仪Y+陀螺仪Z+温度0+温度1+温度2)])
//                        BDLogger.info("文件内容----时间戳：\(response.fileDataType7?.0 ?? 0)")
//                        BDLogger.info("文件内容----数据：\(response.fileDataType7?.1 ?? [])")
//                    } else if fileType == 8 { // adpcm音频
//                        if let data = response.fileDataType8 {
//                            let preview = data.map { String(format: "%02x", $0) }
//                            BDLogger.info("文件数据:adpcm音频，大小:\(data.count)字节，字节内容:\(preview)")
//                        } else {
//                            BDLogger.info("文件数据:adpcm音频：无数据")
//                        }
//                    } else if fileType == 9 { // opus音频
//                        if let data = response.fileDataType9 {
//                            let preview = data.map { String(format: "%02x", $0) }
//                            BDLogger.info("文件数据:opus音频，大小:\(data.count)字节，字节内容:\(preview)")
//                        } else {
//                            BDLogger.info("文件数据:opus音频：无数据")
//                        }
//                    } else if fileType == 10 { // 攀岩项目数据
//                        if let data = response.fileDataType10 {
//                            let preview = data.map { String(format: "%02x", $0) }
//                            BDLogger.info("文件数据:攀岩项目数据，大小:\(data.count)字节，字节内容:\(preview)")
//                        } else {
//                            BDLogger.info("文件数据:攀岩项目数据：无数据")
//                        }
//                    }
//                case let .failure(error):
//                    BDLogger.error("获取文件数据失败: \(error)")
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
//        case 166: // 格式化文件系统
//            BDLogger.info("格式化文件系统")
//            BCLRingManager.shared.formatFileSystem { res in
//                switch res {
//                case let .success(response):
//                    if let result = response.formatResult, result == 1 {
//                        BDLogger.info("格式化文件系统成功: \(response)")
//                    } else {
//                        BDLogger.info("格式化文件系统失败: \(response)")
//                    }
//                case let .failure(error):
//                    BDLogger.error("格式化文件系统失败: \(error)")
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
//        case 170: // 获取文件系统状态
//            BDLogger.info("获取文件系统状态")
//
//            BCLRingManager.shared.getFileSystemStatus { res in
//                switch res {
//                case let .success(response):
//                    BDLogger.info("获取文件系统状态成功: \(response)")
//                    if let status = response.status, status == 0 {
//                        BDLogger.info("文件系统状态: 空闲")
//                    } else if let status = response.status, status == 1 {
//                        BDLogger.info("文件系统状态: 上传文件状态")
//                    } else if let status = response.status, status == 2 {
//                        BDLogger.info("文件系统状态: 写状态")
//                    } else if let status = response.status, status == 3 {
//                        BDLogger.info("文件系统状态: 忙")
//                    } else {
//                        BDLogger.info("未知的文件系统状态")
//                    }
//                case let .failure(error):
//                    BDLogger.error("获取文件系统状态失败: \(error)")
//                }
//            }
//
//            break
//        case 171: // 根据固件版本号，返回固件升级类型
//            BDLogger.info("根据固件版本号，返回固件升级类型")
////                        let fileName = "7.1.9.2Z3R.bin"
////                        let fileName = "6.0.2.7Z2W.zip"
////                        let fileName = "2.7.4.8Z27.hex16"
//            BCLRingManager.shared.getOTAType(firmwareVersion: "5.5.1.6Z2Y") { response in
//                BDLogger.info("固件升级类型:\(response.rawValue)")
//                switch response.rawValue {
//                case 0:
//                    BDLogger.error("固件升级类型: 未知")
//                    break
//                case 1:
//                    BDLogger.info("固件升级类型: Apollo")
//                    // Apollo固件升级 查看以下方法
////                    func apolloUpgradeFirmware(filePath: String, progressHandler: ((Float) -> Void)? = nil, completion: @escaping (Result<Void, BCLError>) -> Void)
//                    break
//                case 2:
//                    BDLogger.info("固件升级类型: Nordic")
//                    // Nordic固件升级 查看以下方法
////                    func nrfUpgradeFirmware(filePath: String, fileName: String, progressHandler: ((Int) -> Void)? = nil, completion: @escaping (Result<BCLNrfUpgradeState.Stage, BCLError>) -> Void)
//                    break
//                case 3:
//                    BDLogger.info("固件升级类型: Phy")
//                    // Phy固件升级 查看以下方法
////                    func phyUpgradeFirmware(filePath: String, progressHandler: ((Double) -> Void)? = nil, completion: @escaping (Result<BCLPhyUpgradeState, BCLError>) -> Void)
//                    break
//                default:
//                    break
//                }
//            }
//            break
//
//        case 172: // 检查是否需要迁移数据
//            BDLogger.info("检查是否需要迁移数据:\(BCLRingManager.shared.checkNeedMigrateHistoryData())")
//            break
//        case 173: // 查询需要迁移数据的条数
//            BDLogger.info("查询需要迁移数据的条数:\(BCLRingManager.shared.getOldDatabaseRecordCount())")
//            break
//        case 174: // 开始迁移数据
//            BDLogger.info("开始迁移数据")
//            let macAddress = BCLRingManager.shared.currentConnectedDevice?.macAddress ?? ""
//            BCLRingManager.shared.migrateHistoryData(mac: macAddress) { res in
//                switch res {
//                case .success:
//                    BDLogger.info("迁移数据成功")
//                case let .failure(error):
//                    BDLogger.error("迁移数据失败: \(error)")
//                }
//            }
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
//        case 190: // 固件历史版本
//            BDLogger.info("获取固件历史版本")
//            BCLRingManager.shared.getFirmwareVersionList(category: "Z2Y") { res in
//                switch res {
//                case let .success(response):
//                    BDLogger.info("固件历史版本-总个数: \(response.count)")
//                    response.forEach { item in
//                        BDLogger.info("固件历史版本-文件名: \(item.fileName)")
//                        BDLogger.info("固件历史版本-文件路径: \(item.filePath)")
//                        BDLogger.info("固件历史版本-下载链接: \(item.fileUrl)")
//                    }
//                case let .failure(error):
//                    BDLogger.error("获取固件历史版本失败: \(error)")
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
//        case 201: // PHY Boot Mode 固件升级功能
//            BDLogger.info("PHY Boot Mode 升级功能")
//            var phyBootDeviceMacAddress = ""
//            // 首先获取当前连接的设备的MAC地址
//            guard let currentConnectedDevice = BCLRingManager.shared.currentConnectedDevice, currentConnectedDevice.macAddress?.isEmpty == false else {
//                BDLogger.error("当前没有连接的设备或设备MAC地址为空")
//                return
//            }
//            phyBootDeviceMacAddress = currentConnectedDevice.macAddress!
//            BDLogger.info("当前Phy Boot Mode 升级设备的MAC地址: \(phyBootDeviceMacAddress)")
//            BDLogger.info("当前Phy Boot Mode 设备升级完成后的地址则为:\(decrementMac(macAddress: phyBootDeviceMacAddress) ?? "Mac地址获取失败")")
//            // 如果戒指的固件升级模式为.phy的，存在戒指在固件升级过程中，因连接断开等因素导致的固件升级中断，则戒指会进入到boot模式。
//            // 此模式下戒指表现为名字为包含PPlus OTA信息，以及戒指的MAC地址最后一位会自动+1
//            // 首先查找设备名称包含 PPlusOTA 的设备，并进行连接。
//            guard let currentConnectedDevice = BCLRingManager.shared.currentConnectedDevice, currentConnectedDevice.isPhyBootMode else {
//                BDLogger.error("当前设备不支持PHY Boot Mode升级功能")
//                return
//            }
//
//            // 📢 根据实际情况选择以下两种 方式之一进行PHY Boot Mode升级：
//            // -----------------------------------------------------------------------------------------------------------------------------------------------------------
//
//            // 1、根据自身是否有固件版本号执行不同的逻辑，如果有固件版本信息，则可以直接通过当前的固件版本信息去检查是否有需要升级的固件版本，然后下载最新的固件文件后，进行PHY Boot Mode升级
//            // a、检查固件版本更新
////            let currentFirmwareVersion = "2.4.8.0Z34"
////            BCLRingManager.shared.checkFirmwareUpdate(version: currentFirmwareVersion) { result in
////                switch result {
////                case let .success(versionInfo):
////                    //  有新版本固件可以进行升级
////                    if versionInfo.hasNewVersion {
////                        BDLogger.info("""
////                        ✅ 发现新版本：
////                        - 版本号：\(versionInfo.version ?? "")
////                        - 下载地址：\(versionInfo.downloadUrl ?? "")
////                        - 文件名：\(versionInfo.fileName ?? "")
////                        """)
////
////                        // b、下载固件文件
////                        guard let fileName = versionInfo.fileName,
////                              let downloadUrl = versionInfo.downloadUrl,
////                              !fileName.isEmpty,
////                              !downloadUrl.isEmpty else {
////                            BDLogger.error("❌ 无法获取固件文件名或下载地址")
////                            return
////                        }
////                        let destinationPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
////                        BCLRingManager.shared.downloadFirmware(url: downloadUrl, fileName: fileName, destinationPath: destinationPath, progress: { progress in
////                            BDLogger.info("固件下载进度：\(progress)")
////                        }, completion: { result in
////                            switch result {
////                            case let .success(filePath):
////                                BDLogger.info("固件下载成功：\(filePath)")
////                                // c、执行PHY Boot Mode升级
////                                // 检查文件扩展名是否为.hex16
////                                guard filePath.lowercased() == "hex16" else {
////                                    BDLogger.error("请选择.hex16格式的固件文件")
////                                    return
////                                }
////                                BDLogger.info("选择的文件：\(filePath)")
////                                BDLogger.info("开始Phy Boot Mode 固件升级...")
////                                // 如果开启了自动重连，需要先关掉。
////                                BCLRingManager.shared.isAutoReconnectEnabled = false
////                                BCLRingManager.shared.phyBootModeUpgrade(
////                                    filePath: filePath,
////                                    device: BCLRingManager.shared.currentConnectedDevice!,
////                                    peripheral: BCLRingManager.shared.currentConnectedDevice!.peripheral
////                                ) { progress in
////                                    BDLogger.info("PHY Boot Mode 升级进度: \(progress)%")
////                                } completion: { result in
////                                    switch result {
////                                    case let .success(response):
////                                        switch response {
////                                        case .preparing:
////                                            BDLogger.info("PHY Boot Mode 升级中: 准备中...")
////                                        case .bootModeConnected:
////                                            BDLogger.info("PHY Boot Mode 升级中: 已连接到Boot模式设备...")
////                                        case .upgrading:
////                                            BDLogger.info("PHY Boot Mode 升级中: 文件传传输中...")
////                                        case .upgradingCompleted:
////                                            BDLogger.info("PHY Boot Mode 升级中: 文件传输完成，准备退出Boot模式...")
////                                        case .exitingBootMode:
////                                            BDLogger.info("PHY Boot Mode 升级中: 正在退出Boot模式...")
////                                        case .success:
////                                            BDLogger.info("✅ PHY Boot Mode 升级成功: \(response)")
////                                            // TODO: 升级成功后可以选择重新连接设备
////                                            // 将Phy Boot 模式下的Mac地址进行-1操作，然后进行重新连接设备
////                                            guard let targetDeviceMacAddress = self.decrementMac(macAddress: phyBootDeviceMacAddress) else {
////                                                BDLogger.error("❌ 获取目标设备的MAC地址失败,无法重连蓝牙设备")
////                                                return
////                                            }
////                                            BDLogger.info("升级成功后，目标设备的MAC地址: \(targetDeviceMacAddress)")
////                                            self.connectDevice(macAddress: targetDeviceMacAddress)
////                                        case let .failed(errString):
////                                            BDLogger.error("❌ PHY Boot Mode 升级失败: \(errString)")
////                                        }
////                                    case let .failure(error):
////                                        BDLogger.error("❌ PHY Boot Mode 升级失败: \(error)")
////                                    }
////                                }
////                            case let .failure(error):
////                                BDLogger.error("固件下载失败：\(error)")
////                            }
////                        })
////                    } else {
////                        BDLogger.info("✅ 当前已是最新版本")
////                        // 如果当前版本已经是最新的，没有最新版本固件可以下载，则可以通过固件版本历史信息去查询最新的固件文件进行PHY Boot Mode升级
////                    }
////                    BDLogger.info("📝 消息：\(String(describing: versionInfo.version))")
////                case let .failure(error):
////                    switch error {
////                    case let .network(.invalidParameters(message)):
////                        BDLogger.error("❌ 参数无效，请检查版本号格式: \(message)")
////                    case let .network(.httpError(code)):
////                        BDLogger.error("❌ HTTP请求失败：状态码 \(code)")
////                    case let .network(.serverError(code, message)):
////                        BDLogger.error("❌ 服务器错误：[\(code)] \(message)")
////                    case .network(.invalidResponse):
////                        BDLogger.error("❌ 响应数据无效")
////                    case let .network(.decodingError(error)):
////                        BDLogger.error("❌ 数据解析失败：\(error.localizedDescription)")
////                    case let .network(.networkError(message)):
////                        BDLogger.error("❌ 网络错误：\(message)")
////                    case let .network(.tokenError(message)):
////                        BDLogger.error("❌ Token异常：\(message)")
////                    default:
////                        BDLogger.error("❌ 其他错误：\(error)")
////                    }
////                }
////            }
//
//            // -----------------------------------------------------------------------------------------------------------------------------------------------------------
//
////            // 2、如果没有固件版本信息，则可以根据固件分配的编码例如：Q1W、Q2W、Q3W信息去查询固件历史版本信息，然后取最新版本的固件文件进行下载后，执行PHY Boot Mode升级
////            // 同样查找并连接戒指 名称包含 PPlusOTA 的设备，并进行连接。
////
////            // 通过标识查找固件版本信息列表
////            // 📢 注意：以下的 category 固件类别 标识 需要根据实际设备的固件类别进行替换 例如：Z21、Z34等，防止下载到错误的固件文件，导致蓝牙设备变砖
////            BCLRingManager.shared.getFirmwareVersionList(category: "000") { result in
////                switch result {
////                case let .success(response):
////                    BDLogger.info("固件历史版本-总个数: \(response.count)")
////                    // 解析版本号并找出最新版本
////                    let latestVersion = self.findLatestVersion(from: response)
////                    if let latest = latestVersion {
////                        let latestFileName = self.getFileName(from: latest)
////                        let latestFileUrl = self.getFileUrl(from: latest)
////                        BDLogger.info("✅ 找到最新版本：\(latestFileName)")
////                        BDLogger.info("✅ 最新版本号：\(self.extractVersionNumber(from: latestFileName))")
////                        BDLogger.info("✅ 最新版本下载链接：\(latestFileUrl)")
////                        guard !latestFileName.isEmpty, !latestFileUrl.isEmpty else {
////                            BDLogger.error("文件名或下载URL为空")
////                            return
////                        }
////                        BDLogger.info("开始下载最新固件：\(latestFileName)")
////
////                        // 获取文档目录路径
////                        let destinationPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
////
////                        // 调用固件的下载方法
////                        BCLRingManager.shared.downloadFirmware(
////                            url: latestFileUrl,
////                            fileName: latestFileName,
////                            destinationPath: destinationPath,
////                            progress: { progress in
////                                BDLogger.info("固件下载进度：\(progress)%")
////                            },
////                            completion: { result in
////                                switch result {
////                                case let .success(filePath):
////                                    BDLogger.info("✅ 固件下载成功：\(filePath)")
////                                    guard let currentDevice = BCLRingManager.shared.currentConnectedDevice else {
////                                        BDLogger.error("当前没有连接的设备")
////                                        return
////                                    }
////                                    BDLogger.info("开始PHY Boot Mode升级...")
////                                    // 如果开启了自动重连，需要先关掉。
////                                    BCLRingManager.shared.isAutoReconnectEnabled = false
////                                    BCLRingManager.shared.phyBootModeUpgrade(
////                                        filePath: filePath,
////                                        device: currentDevice,
////                                        peripheral: currentDevice.peripheral
////                                    ) { progress in
////                                        BDLogger.info("PHY Boot Mode 升级进度: \(progress)%")
////                                    } completion: { result in
////                                        switch result {
////                                        case let .success(response):
////                                            switch response {
////                                            case .preparing:
////                                                BDLogger.info("PHY Boot Mode 升级中: 准备中...")
////                                            case .bootModeConnected:
////                                                BDLogger.info("PHY Boot Mode 升级中: 已连接到Boot模式设备...")
////                                            case .upgrading:
////                                                BDLogger.info("PHY Boot Mode 升级中: 文件传传输中...")
////                                            case .upgradingCompleted:
////                                                BDLogger.info("PHY Boot Mode 升级中: 文件传输完成，准备退出Boot模式...")
////                                            case .exitingBootMode:
////                                                BDLogger.info("PHY Boot Mode 升级中: 正在退出Boot模式...")
////                                            case .success:
////                                                BDLogger.info("✅ PHY Boot Mode 升级成功: \(response)")
////                                                // 📢 需要将Phy Boot 模式下的Mac地址进行-1操作，然后进行重新连接设备
////                                                guard let targetDeviceMacAddress = self.decrementMac(macAddress: phyBootDeviceMacAddress) else {
////                                                    BDLogger.error("❌ 获取目标设备的MAC地址失败,无法重连蓝牙设备")
////                                                    return
////                                                }
////                                                BDLogger.info("升级成功后，目标设备的MAC地址: \(targetDeviceMacAddress)")
////                                                self.connectDevice(macAddress: targetDeviceMacAddress)
////                                            case let .failed(errString):
////                                                BDLogger.error("❌ PHY Boot Mode 升级失败: \(errString)")
////                                            }
////                                        case let .failure(error):
////                                            BDLogger.error("❌ PHY Boot Mode 升级失败: \(error)")
////                                        }
////                                    }
////                                case let .failure(error):
////                                    BDLogger.error("❌ 固件下载失败：\(error)")
////                                }
////                            }
////                        )
////                    } else {
////                        BDLogger.error("❌ 未找到有效的固件版本")
////                    }
////                case let .failure(error):
////                    BDLogger.error("获取固件历史版本失败: \(error)")
////                }
////            }
//
//            // 📢 注意：如果需要在手机上选择文件进行PHY Boot Mode升级，请使用以下代码实现文件选择器
//            // ------------------------------------------------------------------------------------------------------------------------------------------------------------
//            curFirmwareUpgradeType = .phyBootMode
//            // 实现打开文件选择器
//            let filePicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
//            filePicker.delegate = self
//            filePicker.allowsMultipleSelection = false
//            present(filePicker, animated: true, completion: nil)
//            break
//
//        case 202: // 开始老化测试
//            BDLogger.info("开始老化测试")
//            BCLRingManager.shared.setAgingMode(mode: 0) { result in
//                switch result {
//                case let .success(response):
//                    BDLogger.info("老化测试开始-成功 \n 当前模式：\(response.agingMode)")
//                case let .failure(error):
//                    BDLogger.error("老化测试开始-失败: \(error)")
//                }
//            }
//            break
//        case 203: // 读取老化测试信息
//            BDLogger.info("读取老化测试信息")
//            BCLRingManager.shared.readAgingModeInfo { result in
//                switch result {
//                case let .success(response):
//                    BDLogger.info("读取老化测试信息-成功")
//                    BDLogger.info("老化信息-总时长（分钟）: \(response.totalDurationMinutes)")
//                    BDLogger.info("老化信息-开始时间戳: \(response.startTime)")
//                    BDLogger.info("老化信息-结束时间戳: \(response.endTime)")
//                    BDLogger.info("老化信息-老化状态: \(response.agingStatus)")
//                    BDLogger.info("老化信息-充电最高温度: \(Float(response.maxChargeTemp) / 100.0)°C")
//                    BDLogger.info("老化信息-充电最高温度时长: \(response.maxChargeTempTime)")
//                case let .failure(error):
//                    BDLogger.error("读取老化测试信息-失败: \(error)")
//                }
//            }
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
//        case 209: // mcu读取
//            BCLRingManager.shared.mcuIDRead { result in
//                switch result {
//                case let .success(response):
//                    BDLogger.info("mcuID:\(response.mcu_ID ?? "")")
//                case let .failure(error):
//                    BDLogger.error("mcu读取失败: \(error)")
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
////        case 215: //
////            break
////        case 216: //
////            break
//        case 215: // 发送自定义指令
////            showCustomCommandInputAlert()
////            /// 当前测量状态
////            public var status: BCLTakePWTTStatus = .measuring
////            /// 当前测量进度
////            public var progress: Int?
////            /// PPG心率（0：无效）
////            public var ppgHeartRate: Int?
////            /// 血氧（0：无效）
////            public var bloodOxygen: Int?
////            /// ECG心率（0：无效）
////            public var ecgHeartRate: Int?
////            /// 血压（0：舒张压，1：收缩压）
////            public var bloodPressure: (Int, Int)?
////            /// 波形数据 (序号，数据个数，[红色，红外，心电])
////            public var waveformData: (Int, Int, [(Int, Int, Int)])?
////            /// 错误
////            public var error: BCLError?
//            BCLRingManager.shared.startPWTT(collectTime: 30, collectFrequency: 100, waveformConfig: 1) { result in
//                switch result {
//                case let .success(data):
//                    BDLogger.info("PWTT测试-测量状态：\(data.status.rawValue)")
//                    BDLogger.info("PWTT测试-当前测量进度：\(data.progress ?? 0)")
//                    BDLogger.info("PWTT测试-PPG心率：\(data.ppgHeartRate ?? 0)")
//                    BDLogger.info("PWTT测试-血氧：\(data.bloodOxygen ?? 0)")
//                    BDLogger.info("PWTT测试-ECG心率：\(data.ecgHeartRate ?? 0)")
//                    BDLogger.info("PWTT测试-血压：\(data.bloodPressure?.0 ?? 0)/\(data.bloodPressure?.1 ?? 0)mmHg")
//                    BDLogger.info("PWTT测试-波形数据：\(data.waveformData ?? (0,0,[]))")
//                    
//                case let .failure(error):
//                    // 处理错误
//                    BDLogger.error("PWTT测试-失败：\(error)")
//                }
//            }
//            break
//        case 216: // 停止自定义指令
////            stopCustomCommand()
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
//    // MARK: - GoMore设置个人信息示例 0x3723
//
//    /// 设置GoMore个人信息示例
//    /// - Parameters:
//    /// - age: 年龄
//    /// - gender: 性别（0-女性，1-男性）
//    /// - height: 身高（cm）
//    /// - weight: 体重（kg）
//    /// - maxHeartRate: 最大心率（bpm）
//    /// - normalHeartRate: 静息心率（bpm）
//    /// - maxOxygenUptake: 最大摄氧量（ml/kg/min）
//    func setGoMorePersonalInfoExample(age: Int, gender: Int, height: Int, weight: Int, maxHeartRate: Int, normalHeartRate: Int, maxOxygenUptake: Int) {
//        BCLRingManager.shared.goMoreSetPersonalInformation(
//            age: 30,
//            gender: 1, // 男性
//            height: 175,
//            weight: 70,
//            maxHeartRate: 180,
//            normalHeartRate: 70,
//            maxOxygenUptake: 45
//        ) { result in
//            switch result {
//            case let .success(response):
//                if response.success {
//                    BDLogger.info("设置成功")
//                } else {
//                    BDLogger.error("设置失败")
//                }
//            case let .failure(error):
//                BDLogger.error("错误：\(error)")
//            }
//        }
//    }
//
//    /// 读取GoMore个人信息示例 0x3724
//    func readGoMorePersonalInfoExample() {
//        BCLRingManager.shared.goMoreGetPersonalInformation { result in
//            switch result {
//            case let .success(response):
//                BDLogger.info("年龄：\(response.age)")
//                BDLogger.info("性别：\(response.gender)")
//                BDLogger.info("身高：\(response.height)cm")
//                BDLogger.info("体重：\(response.weight)kg")
//                BDLogger.info("最大心率：\(response.maxHeartRate)")
//                BDLogger.info("常态心率：\(response.normalHeartRate)")
//                BDLogger.info("最大摄氧量：\(response.maxOxygenUptake)ml/kg/min")
//            case let .failure(error):
//                BDLogger.error("错误：\(error)")
//            }
//        }
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
//
//    // MARK: - 自定义指令相关方法
//
//    /// 显示自定义指令输入弹窗
//    private func showCustomCommandInputAlert() {
//        let alert = UIAlertController(
//            title: "发送自定义指令",
//            message: "请输入16进制指令数据（例如：A5 5A 36 01）",
//            preferredStyle: .alert
//        )
//
//        alert.addTextField { textField in
//            textField.placeholder = "A5 5A 36 01"
//            textField.autocapitalizationType = .allCharacters
//            textField.keyboardType = .default
//        }
//
//        alert.addTextField { textField in
//            textField.placeholder = "超时时间（秒），留空表示无超时"
//            textField.keyboardType = .numberPad
//        }
//
//        let confirmAction = UIAlertAction(title: "发送", style: .default) { [weak self] _ in
//            guard let self = self else { return }
//            guard let hexString = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces),
//                  !hexString.isEmpty else {
//                BDLogger.error("请输入有效的16进制指令数据")
//                QMUITips.showError("请输入有效的16进制指令数据", in: self.view, hideAfterDelay: 2)
//                return
//            }
//
//            let timeoutString = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces) ?? ""
//            let timeout: TimeInterval? = timeoutString.isEmpty ? nil : TimeInterval(timeoutString)
//
//            guard let commandData = self.hexStringToData(hexString) else {
//                BDLogger.error("16进制字符串格式错误")
//                QMUITips.showError("16进制字符串格式错误", in: self.view, hideAfterDelay: 2)
//                return
//            }
//            self.sendCustomCommand(commandData: commandData, timeout: timeout)
//        }
//
//        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
//        alert.addAction(cancelAction)
//        alert.addAction(confirmAction)
//        present(alert, animated: true)
//    }
//
//    /// 发送自定义指令
//    /// - Parameters:
//    ///   - commandData: 指令数据
//    ///   - timeout: 超时时间
//    private func sendCustomCommand(commandData: Data, timeout: TimeInterval?) {
//        // 先停止之前的自定义指令（如果有）
//        if let commandId = customCommandId {
//            BCLRingManager.shared.stopCustomCommand(commandId: commandId)
//            customCommandId = nil
//        }
//
//        BDLogger.info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
//        BDLogger.info("📤 准备发送自定义指令")
//        let commanDataStr = commandData.map({ String(format: "%02X", $0) })
//        BDLogger.info("   指令数据: \(commanDataStr)")
//        if let timeout = timeout {
//            BDLogger.info("   超时时间: \(timeout) 秒")
//        } else {
//            BDLogger.info("   超时时间: 无超时")
//        }
//        BDLogger.info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
//
//        let result = BCLRingManager.shared.sendCustomCommand(
//            commandData: commandData,
//            timeout: timeout
//        ) { [weak self] responseData in
//            guard let self = self else { return }
//            // 在主线程更新UI
//            DispatchQueue.main.async {
//                let responseDataStr = responseData.map({ String(format: "%02X", $0) })
//                BDLogger.info("📥 收到自定义指令响应: \(responseDataStr)")
//            }
//        }
//
//        switch result {
//        case let .success(commandId):
//            customCommandId = commandId
//            BDLogger.info("✅ 自定义指令发送成功，指令ID: \(commandId)")
//            BDLogger.info("⏳ 开始监听响应数据...")
//            QMUITips.showSucceed("指令发送成功", in: view, hideAfterDelay: 2)
//
//        case let .failure(error):
//            BDLogger.error("❌ 自定义指令发送失败: \(error)")
//            QMUITips.showError("发送失败: \(error.localizedDescription)", in: view, hideAfterDelay: 2)
//        }
//    }
//
//    /// 停止自定义指令
//    private func stopCustomCommand() {
//        guard let commandId = customCommandId else {
//            BDLogger.warning("⚠️ 没有正在运行的自定义指令")
//            QMUITips.showInfo("没有正在运行的自定义指令", in: view, hideAfterDelay: 2)
//            return
//        }
//
//        BCLRingManager.shared.stopCustomCommand(commandId: commandId)
//        customCommandId = nil
//
//        BDLogger.info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
//        BDLogger.info("🛑 已停止自定义指令监听，指令ID: \(commandId)")
//        BDLogger.info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
//        QMUITips.showSucceed("已停止监听", in: view, hideAfterDelay: 2)
//    }
//
//    /// 将16进制字符串转换为Data
//    /// - Parameter hexString: 16进制字符串（可以包含空格，例如 "A5 5A 36 01" 或 "A55A3601"）
//    /// - Returns: Data对象，如果转换失败则返回nil
//    private func hexStringToData(_ hexString: String) -> Data? {
//        let cleanedString = hexString.replacingOccurrences(of: " ", with: "")
//            .replacingOccurrences(of: "-", with: "")
//            .replacingOccurrences(of: ":", with: "")
//            .uppercased()
//        guard cleanedString.count % 2 == 0 else {
//            return nil
//        }
//
//        var data = Data()
//        var index = cleanedString.startIndex
//        while index < cleanedString.endIndex {
//            let nextIndex = cleanedString.index(index, offsetBy: 2)
//            let byteString = cleanedString[index ..< nextIndex]
//
//            guard let byte = UInt8(byteString, radix: 16) else {
//                return nil
//            }
//            data.append(byte)
//            index = nextIndex
//        }
//        return data
//    }
//}
