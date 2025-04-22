//
//  MainVC.swift
//  Rings-SDK_Example
//
//  Created by JianDan on 2025/1/10.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import QMUIKit
import RingsSDK
import UIKit

class MainVC: UIViewController {
    @IBOutlet var name_Label: UILabel!
    @IBOutlet var mac_Label: UILabel!
    @IBOutlet var connectState_Label: UILabel!
    @IBOutlet var autoConnect_Btn: UIButton!

    //  蓝牙设备列表
    private lazy var deviceTableVC: DeviceTableVC = {
        let vc = DeviceTableVC()
        return vc
    }()

    //  日志页面
    var logVC = LogVC()

    //  自动重连设备的UUID
    var deviceUUID = "" {
        didSet {
            UserDefaults.standard.set(deviceUUID, forKey: "bcl_deviceUUID")
        }
    }

    //  是否开启自动重连
    var autoConnect = false {
        didSet {
            autoConnect_Btn.setTitle(autoConnect ? "自动重连(开)" : "自动重连关", for: .normal)
            UserDefaults.standard.set(autoConnect, forKey: "bcl_autoConnect")
        }
    }

    // 固件下载保存本地路径
    var filePathUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let log_VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogVC_ID") as? LogVC {
            logVC = log_VC
            present(logVC, animated: true, completion: nil)
        }

        RingManager.shared.connectStateChangeBlock = { state in
            if state {
                BDLogger.info("蓝牙设备已连接")
            } else {
                BDLogger.info("蓝牙设备断开连接")
            }
            self.updateDeviceInfo()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        autoConnect = UserDefaults.standard.bool(forKey: "bcl_autoConnect")
        deviceUUID = UserDefaults.standard.string(forKey: "bcl_deviceUUID") ?? ""
        //  自动重连
        if autoConnect {
            guard !deviceUUID.isEmpty else {
                return
            }
            BDLogger.info("开始尝试重连设备UUID:\(deviceUUID)")
            RingManager.shared.reconnect(deviceUUID: deviceUUID, resultBlock: { res in
                switch res {
                case let .success(deviceInfo):
                    BDLogger.info("已连接设备 =========>\(String(describing: deviceInfo.peripheral.name))")
                case let .failure(error):
                    BDLogger.info("连接失败 ========> \(error)连接状态\(RingManager.shared.isDidConnect)")
                }
            })
        }
    }

    //  更新设备信息
    func updateDeviceInfo() {
        guard let device = RingManager.shared.currentDevice else {
            name_Label.text = "设备名字："
            mac_Label.text = "Mac地址："
            connectState_Label.text = "连接状态：未连接"
            return
        }
        name_Label.text = "设备名字：\(device.peripheral.name ?? "")"
        var macString = ""
        if let macData = device.advertisementData["kCBAdvDataManufacturerData"] as? Data, macData.count >= 8 {
            macString = String(format: "%02X:%02X:%02X:%02X:%02X:%02X", macData[7], macData[6], macData[5], macData[4], macData[3], macData[2])
        }
        mac_Label.text = "Mac地址：\(macString)"
        connectState_Label.text = "连接状态：\(RingManager.shared.isDidConnect ? "已连接" : "未连接")"
        deviceUUID = device.peripheral.identifier.uuidString
    }

    @IBAction func clickAction(_ sender: UIButton) {
        switch sender.tag {
        case 1000: //  搜索并连接设备
            navigationController?.pushViewController(deviceTableVC, animated: true)
            break
        case 1001: // 断开连接
            BDLogger.info("=========>执行断开连接操作")
            RingManager.shared.disconnect()
            break
        case 1002: // 同步时间
            BDLogger.info("=========>执行同步时间操作")
            //  默认UTC时区
            RingManager.shared.syncTime(date: Date()) { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1003: // 同步时间+时区设置
            //  东8区
            RingManager.shared.syncTime(date: Date(), timeZone: RingTimeZone.East8) { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1004: // 读取时间
            BDLogger.info("=========>执行读取时间操作")
            RingManager.shared.readTime { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)毫秒")
                    let dateFormate = DateFormatter()
                    dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    //  此处注意时区，按照自己同步时间时候的时区进行转换
                    dateFormate.timeZone = TimeZone.current
                    let timeDate = dateFormate.string(from: Date(timeIntervalSince1970: TimeInterval(value / 1000)))
                    BDLogger.info("时间=====>\(timeDate)")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1005: // 读取温度
            BDLogger.info("=========>执行体温操作")
            RingManager.shared.readTemperature { res in
                switch res {
                case let .success(temperature):
                    BDLogger.info("温度：=====>\(temperature)")
                    BDLogger.info("转换：=====>\(String(format: "%.2f", Double(temperature) * 0.01))℃")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }

            break
        case 1006: // 读取步数
            BDLogger.info("=========>执行读取步数操作")
            RingManager.shared.readSteps { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)步")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1007: // 清除步数
            BDLogger.info("=========>执行清除步数操作")
            RingManager.shared.clearSteps { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1008: // 读取电量
            BDLogger.info("=========>执行读取电量操作")
            RingManager.shared.readBattery { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1009: // 充电状态
            BDLogger.info("=========>执行读取充电状态操作")
            RingManager.shared.readChargeStatus { res in
                switch res {
                case let .success(success):
                    if success == .full {
                        BDLogger.info("充电状态=====>充满")
                    } else if success == .charging {
                        BDLogger.info("充电状态=====>充电中")
                    } else {
                        BDLogger.info("充电状态=====>未充电")
                    }
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1010: // 血氧
            BDLogger.info("=========>执行实时血氧操作")
            RingManager.shared.readO2(progressBlock: { progress in
                BDLogger.info(" 进度 =====>\(progress)")
            }, isOpenWave: true) { seq, num, datas in
                BDLogger.info("序号 ====>\(seq)")
                BDLogger.info("数据个数 ====>\(num)")
                BDLogger.info("波形数据 ====>\(datas)")
            } resultBlock: { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1011: // 心率
            BDLogger.info("=========>执行实时心率及间期RR-50操作")
            RingManager.shared.readHeartRateWithRR(rrTime: 50, progressBlock: { progress in
                BDLogger.info(" 进度 =====>\(progress)")
            }, inHeartRRBlock: { seq, num, datas in
                BDLogger.info("序号 ====>\(seq)")
                BDLogger.info("数据个数 ====>\(num)")
                BDLogger.info("RR数据 ====>\(datas)")
            }, inHeartBlock: { heartValue in
                BDLogger.info("测量中的心率:\(heartValue)")
            }, resultBlock: { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            })
            break
        case 1012: // 心率变异性
            BDLogger.info("=========>执行心率变异性操作")
            RingManager.shared.readHRV(progressBlock: { progress in
                BDLogger.info(" 进度 =====>\(progress)")
            }, isOpenWave: true) { seq, num, datas in
                BDLogger.info("序号 ====>\(seq)")
                BDLogger.info("数据个数 ====>\(num)")
                BDLogger.info("波形数据 ====>\(datas)")
            } resultBlock: { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1013: // 读取全部数据
            BDLogger.info("=========>执行读取全部数据操作")
//            let now = Date()
//            var calendar = Calendar.current
//            var comps = calendar.dateComponents([.year, .month, .day], from: now)
//            comps.hour = 1
//            comps.minute = 45
//            guard let date = calendar.date(from: comps) else {
//                BDLogger.error("时间转换失败")
//                return
//            }
//            BDLogger.debug("目标时间戳：\(date.timeIntervalSince1970)")
//            RingManager.shared.readAllHistoryDatas(targetTimeInterval: date.timeIntervalSince1970) { progress, dataModel in
//                BDLogger.info("进度 =====>\(progress)==\(dataModel)")
//            } resultBlock: { res in
//                switch res {
//                case let .success(success):
//                    BDLogger.info("成功====>\(success)")
//                case let .failure(failure):
//                    BDLogger.info("失败====>\(failure)")
//                }
//            }
            RingManager.shared.readAllHistoryDatas { progress, dataModel in
                BDLogger.info("进度 =====>\(progress)==\(dataModel)")
            } resultBlock: { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败====>\(failure)")
                }
            }
            break
        case 1014: // 读取未上传数
            BDLogger.info("=========>执行读取未上传数据操作")
            let now = Date()
            var calendar = Calendar.current
            var comps = calendar.dateComponents([.year, .month, .day], from: now)
            comps.hour = 9
            comps.minute = 0
            guard let date = calendar.date(from: comps) else {
                BDLogger.error("时间转换失败")
                return
            }
            BDLogger.debug("目标时间戳：\(date.timeIntervalSince1970)")
            RingManager.shared.readNewHistoryDatas(targetTimeInterval: date.timeIntervalSince1970) { progress, dataModel in
                BDLogger.info("进度 =====>\(progress)==\(dataModel)")
            } resultBlock: { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败====>\(failure)")
                }
            }

//            RingManager.shared.readNewHistoryDatas { progress, dataModel in
//                BDLogger.info("进度 =====>\(progress)==\(dataModel)")
//            } resultBlock: { res in
//                switch res {
//                case let .success(success):
//                    BDLogger.info("成功====>\(success)")
//                case let .failure(failure):
//                    BDLogger.info("失败====>\(failure)")
//                }
//            }
            break
        case 1015: // 清除数据
            BDLogger.info("=========>执行清除数据操作")
            RingManager.shared.clearRingData { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1016: // 恢复出厂设置
            BDLogger.info("=========>执行恢复出厂设置操作")
            RingManager.shared.reset { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1017: // 硬件版本
            BDLogger.info("=========>执行硬件版本操作")
            RingManager.shared.readHardWareVersion { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1018: // 固件版本
            BDLogger.info("=========>执行固件版本操作")
            RingManager.shared.readAppVersion { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1019: // 设置采集周期
            BDLogger.info("=========>执行设置采集周期操作")
            let alert = QMUIAlertController(title: "请输入采集周期，单位秒(最小值60s)", message: "", preferredStyle: .alert)
            alert.addTextField { tf in
                tf.keyboardType = .numberPad
                tf.placeholder = "请输入"
                tf.font = .systemFont(ofSize: 16)
                tf.textInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
            }
            let checkAction = QMUIAlertAction(title: "确定", style: .default) { alertVC, _ in
                guard let text = alertVC.textFields?.first?.text,
                      let time = Int(text) else {
                    QMUITips.show(withText: "请输入正确的时间")
                    return
                }
                RingManager.shared.setFrequency(time: time) { res in
                    switch res {
                    case let .success(success):
                        BDLogger.info("成功=====>\(success)")
                    case let .failure(failure):
                        BDLogger.info("失败=====>\(failure)")
                    }
                }
            }
            checkAction.buttonAttributes = [.font: UIFont.qmui_mediumSystemFont(ofSize: 16)!, .foregroundColor: UIColor.qmui_color(withHexString: "478EDA")!]
            let cancelAction = QMUIAlertAction(title: "取消", style: .cancel)
            cancelAction.buttonAttributes = [.font: UIFont.qmui_mediumSystemFont(ofSize: 16)!, .foregroundColor: UIColor.qmui_color(withHexString: "999999")!]
            alert.addAction(checkAction)
            alert.addAction(cancelAction)
            alert.modalPresentationStyle = .fullScreen
            alert.showWith(animated: true)
            alert.textFields?.first?.becomeFirstResponder()
            break
        case 1020: // 读取采集周期
            BDLogger.info("=========>执行读取采集周期操作")
            RingManager.shared.readFrequency { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)秒")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1021: // 读取睡眠数据
            BDLogger.info("=========>获取指定日期的睡眠数据")
//            let date = Date("2025-04-01", format: "yyyy-MM-dd")
            let sleepModel = RingManager.shared.caculateSleep(targetDate: Date())
            BDLogger.info("睡眠数据\(sleepModel.description)")
            break
        case 1022: // SDK集成Token获取
            BDLogger.info("=========>获取SDK Token")
            RingNetworkManager.shared.createToken(apiKey: "76d07e37bfe341b1a25c76c0e25f457a", userIdentifier: "432591@qq.com") { result in
                switch result {
                case let .success(token):
                    BDLogger.info("✅ Token获取成功：")
                    BDLogger.info("- Token: \(token)")
                case let .failure(error):
                    BDLogger.error("❌ Token获取失败：")
                    // 根据不同错误类型显示不同的错误信息
                    let errorMessage: String
                    switch error {
                    case .invalidParameters:
                        BDLogger.error("❌ 参数无效，请检查API Key和用户ID")
                    case let .httpError(code):
                        BDLogger.error("❌ HTTP错误：\(code)")
                    case let .serverError(code, message):
                        BDLogger.error("❌ 服务器错误[\(code)]: \(message)")
                    case .invalidResponse:
                        BDLogger.error("❌ 响应数据无效")
                    case .decodingError:
                        BDLogger.error("❌ 数据解析失败")
                    case let .networkError(message):
                        BDLogger.error("❌ 网络错误: \(message)")
                    case .tokenError:
                        BDLogger.error("❌ Token异常")
                    }
                }
            }
            break
        case 1023: // 固件新版本检查
            // 7.1.5.3Z3R / 7.1.7.0Z3R
            BDLogger.info("=========>检查固件版本")
            RingNetworkManager.shared.checkDeviceVersion(version: "7.1.7.0Z3R") { result in
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
                    case .invalidParameters:
                        BDLogger.error("❌ 参数无效，请检查版本号格式")
                    case let .httpError(code):
                        BDLogger.error("❌ HTTP请求失败：状态码 \(code)")
                    case let .serverError(code, message):
                        BDLogger.error("❌ 服务器错误：[\(code)] \(message)")
                    case .invalidResponse:
                        BDLogger.error("❌ 响应数据无效")
                    case let .decodingError(error):
                        BDLogger.error("❌ 数据解析失败：\(error.localizedDescription)")
                    case let .networkError(message):
                        BDLogger.error("❌ 网络错误：\(message)")
                    case .tokenError:
                        BDLogger.error("❌ Token异常")
                    }
                }
            }
            break
        case 1024: // 固件文件下载
            BDLogger.info("=========>固件下载")
            // fileName:7.1.7.0Z3R.bin
            // downloadUrl:https://image.lmyiot.com/FiaeMmw7OwXNwtKWoaQM2HsNhi4z
            // documentDirectory
            let destinationPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            RingNetworkManager.shared.downloadFile(url: "https://image.lmyiot.com/FiaeMmw7OwXNwtKWoaQM2HsNhi4z", fileName: "7.1.7.0Z3R.bin", destinationPath: destinationPath, progress: { progress in
                BDLogger.info("进度 =====>\(progress)")
            }, completion: { result in
                switch result {
                case let .success(filePathUrl):
                    BDLogger.info("固件已保存到 =====>\(filePathUrl)")
                    self.filePathUrl = URL(fileURLWithPath: filePathUrl)
                case let .failure(error):
                    BDLogger.error("固件下载失败 =====>\(error)")
                }
            })

            break

        case 1025: // 实时获取蓝牙设备RSSI值
            BDLogger.info("=========>读取蓝牙设备实时RSSI")
            RingManager.shared.startMonitorRSSI { result in
                switch result {
                case let .success(rssi):
                    BDLogger.info("当前RSSI: \(rssi.intValue)")
                    // 可以根据RSSI值来判断信号强度
                    let rssiValue = rssi.intValue
                case let .failure(error):
                    switch error {
                    case .disconnect:
                        BDLogger.info("设备未连接")
                    case .fail:
                        BDLogger.info("读取RSSI失败")
                    default:
                        BDLogger.info("其他错误: \(error)")
                    }
                }
            }
            break
        case 1026: // 阿波罗固件升级
            BDLogger.info("=========>升级固件")
            guard let fileUrl = filePathUrl else {
                BDLogger.info("请先下载固件")
                return
            }

            //  开始阿波罗升级
            RingManager.shared.startApolloOTA(fileUrl: fileUrl) { status in
                switch status {
                case .preparing:
                    BDLogger.info("OTA: 准备开始升级...")
                case let .progress(progress):
                    let percentage = Int(progress * 100)
                    BDLogger.info("OTA: 升级进度 \(percentage)%")
                case .success:
                    BDLogger.info("OTA: 固件传输成功")
                // 传输成功后自动验证并重启
                case let .error(message, code):
                    BDLogger.error("OTA: 升级失败 - \(message) (错误码: \(code))")
                case .rebootSuccess:
                    BDLogger.info("OTA: 设备重启成功")
                case .rebootFailed:
                    BDLogger.error("OTA: 设备重启失败")
                }
            }
        case 1027: // 自动重连
            autoConnect = !autoConnect
            QMUITips.show(withText: autoConnect ? "自动重连已开启" : "自动重连已关闭")
            break
        case 1028: // 通过mac地址链接戒指
            RingManager.shared.startConnect(mac: "B0:04:70:00:00:0B", timeout: 15) { res in
                switch res {
                case let .success(deviceInfo):
                    BDLogger.info("已连接设备 =========>\(String(describing: deviceInfo.peripheral.name))")
                    BDLogger.info("连接状态 =========>\(RingManager.shared.isDidConnect)")
                case let .failure(error):
                    BDLogger.info("连接失败 ========> \(error)连接状态\(RingManager.shared.isDidConnect)")
                }
            }
            break
        case 1029: // 读取数据库最后一条数据
            let model = RingDBManager.shared.getLatestObject()
            BDLogger.info("数据库最后一条数据：\(String(describing: model?.description))")
            break
        case 1030: // (寿世)读取PPG数据
            RingManager.shared.get_PPG_ShouShi(collectionTime: 30, waveformConfiguration: 1, progressConfiguration: 1, waveformSetting: 0, progressBlock: { progress in
                BDLogger.info("进度：\(progress)")
            }, tableBlock: { index, value, data in
                BDLogger.info("波形：\(index) \(value) \(data)")
            }, resultBlock: { result in
                BDLogger.info("结果：\(result)")
            })
            break
        case 1031: // (寿世)停止PPG采集
            RingManager.shared.stop_PPG_ShouShi { result in
                switch result {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        default:
            break
        }
    }

    //  日志
    @IBAction func log_Action(_ sender: Any) {
        present(logVC, animated: true, completion: nil)
    }

    //  连接设备
    func connectDevice(device: DeviceInfo) {
        BDLogger.info(" ========> 开始连接设备")
        RingManager.shared.startConnect(deviceUUID: device.uuidString, resultBlock: { res in
            switch res {
            case let .success(deviceInfo):
                BDLogger.info("已连接设备 =========>\(String(describing: deviceInfo.peripheral.name))")
                BDLogger.info("连接状态 =========>\(RingManager.shared.isDidConnect)")
            case let .failure(error):
                BDLogger.info("连接失败 ========> \(error)连接状态\(RingManager.shared.isDidConnect)")
            }
        })
    }

    // 校验mac地址是否正确
    func isValidMacAddress(_ mac: String) -> Bool {
        // 只允许冒号分隔，并忽略大小写
        let pattern = "^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        guard let regex = regex else { return false }

        let range = NSRange(location: 0, length: mac.utf16.count)
        let match = regex.firstMatch(in: mac, options: [], range: range)
        return (match != nil)
    }
}
