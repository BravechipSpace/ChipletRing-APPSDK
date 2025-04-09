//
//  BCLRingManager.swift
//  OCRingsSDKDemo
//
//  Created by JianDan on 2025/3/5.
//

import Foundation
import RingsSDK
@objc public class BCLRingManager: NSObject {
    @MainActor @objc public static let shared = BCLRingManager()

    override private init() {
        super.init()
    }

    // 设置蓝牙连接状态监听
    @objc public func setupConnectionStateMonitor(stateChanged: @escaping (Bool) -> Void) {
        RingManager.shared.connectStateChangeBlock = { state in
            if state {
                BDLogger.info("蓝牙设备已连接")
            } else {
                BDLogger.info("蓝牙设备断开连接")
            }
            stateChanged(state)
        }
    }

    // 开始扫描蓝牙设备
    @objc public func startScanDevices(completion: @escaping ([DeviceInfo]?, String?) -> Void) {
        RingManager.shared.startScan { [weak self] devices in
            guard self != nil else { return }
            BDLogger.info("蓝牙扫描设备列表 =========>\(String(describing: devices))")
            if let devices = devices {
                completion(devices, nil)
            } else {
                completion(nil, "未扫描到设备")
            }
        }
    }

    // 停止扫描蓝牙设备
    @objc public func stopScan() {
        RingManager.shared.stopScan()
    }

    // 连接蓝牙设备
    @objc public func connectDevice(withUUID uuid: String, completion: @escaping (_ success: Bool, _ deviceName: String?, _ error: String?) -> Void) {
        RingManager.shared.startConnect(deviceUUID: uuid, resultBlock: { res in
            switch res {
            case let .success(deviceInfo):
                BDLogger.info("已连接设备 =========>\(String(describing: deviceInfo.peripheral.name))")
                BDLogger.info("连接状态 =========>\(RingManager.shared.isDidConnect)")
                completion(true, deviceInfo.peripheral.name, nil)
            case let .failure(error):
                BDLogger.info("连接失败 ========> \(error)连接状态\(RingManager.shared.isDidConnect)")
                completion(false, nil, error.localizedDescription)
            }
        })
    }

    // 通过指定Mac地址连接设备
    @objc public func connectDevice(withMacAddress mac: String, timeout: TimeInterval, completion: @escaping (_ success: Bool, _ deviceName: String?, _ error: String?) -> Void) {
        RingManager.shared.startConnect(mac: mac, timeout: timeout) { res in
            switch res {
            case let .success(deviceInfo):
                BDLogger.info("已连接设备 =========>\(String(describing: deviceInfo.peripheral.name))")
                BDLogger.info("连接状态 =========>\(RingManager.shared.isDidConnect)")
                completion(true, deviceInfo.peripheral.name, nil)
            case let .failure(error):
                BDLogger.info("连接失败 ========> \(error)连接状态\(RingManager.shared.isDidConnect)")
                completion(false, nil, error.localizedDescription)
            }
        }
    }

    // 断开蓝牙设备
    @objc public func disconnect() {
        RingManager.shared.disconnect()
    }

    // 同步设备时间
    @objc public func syncDeviceTime(date: Date, completion: @escaping (_ success: Bool, _ message: String?) -> Void) {
        RingManager.shared.syncTime(date: date) { res in
            switch res {
            case let .success(value):
                BDLogger.info("成功=====>\(value)")
                completion(true, String(describing: value))

            case let .failure(error):
                BDLogger.info("失败=====>\(error)")
                completion(false, error.localizedDescription)
            }
        }
    }

    // 同步设备时间（时区）
    @objc public func syncDeviceTimeWithTimeZone(date: Date, timeZone: RingTimeZone, completion: @escaping (_ success: Bool, _ message: String?) -> Void) {
        RingManager.shared.syncTime(date: date, timeZone: timeZone) { res in
            switch res {
            case let .success(value):
                BDLogger.info("成功=====>\(value)")
                completion(true, String(describing: value))

            case let .failure(error):
                BDLogger.info("失败=====>\(error)")
                completion(false, error.localizedDescription)
            }
        }
    }

    // 读取设备时间
    @objc public func readDeviceTime(completion: @escaping (_ success: Bool, _ timestamp: Double) -> Void) {
        RingManager.shared.readTime { res in
            switch res {
            case let .success(value):
                BDLogger.info("读取时间成功=====>\(value)")
                completion(true, value)

            case let .failure(error):
                BDLogger.info("读取时间失败=====>\(error)")
                completion(false, 0)
            }
        }
    }

    // 读取设备步数
    @objc public func readStepsCount(completion: @escaping (_ success: Bool, _ steps: Int) -> Void) {
        RingManager.shared.readSteps { res in
            switch res {
            case let .success(value):
                BDLogger.info("读取步数成功=====>\(value)步")
                completion(true, value)

            case let .failure(error):
                BDLogger.info("读取步数失败=====>\(error)")
                completion(false, 0)
            }
        }
    }

    // 清除设备步数
    @objc public func clearStepsCount(completion: @escaping (_ success: Bool) -> Void) {
        RingManager.shared.clearSteps { res in
            switch res {
            case let .success(value):
                BDLogger.info("清除步数成功=====>\(value)")
                completion(true)

            case let .failure(error):
                BDLogger.info("清除步数失败=====>\(error)")
                completion(false)
            }
        }
    }

    // 读取电池电量
    @objc public func readBatteryLevel(completion: @escaping (_ success: Bool, _ level: Int) -> Void) {
        RingManager.shared.readBattery { res in
            switch res {
            case let .success(value):
                BDLogger.info("读取电量成功=====>\(value)")
                completion(true, value)

            case let .failure(error):
                BDLogger.info("读取电量失败=====>\(error)")
                completion(false, 0)
            }
        }
    }

    // 定义充电状态枚举
    @objc public enum ChargeStatus: Int {
        case notCharging = 0
        case charging = 1
        case full = 2
    }

    // 读取充电状态
    @objc public func readChargeStatus(completion: @escaping (_ success: Bool, _ status: ChargeStatus) -> Void) {
        RingManager.shared.readChargeStatus { res in
            switch res {
            case let .success(status):
                switch status {
                case .full:
                    BDLogger.info("充电状态=====>充满")
                    completion(true, .full)
                case .charging:
                    BDLogger.info("充电状态=====>充电中")
                    completion(true, .charging)
                default:
                    BDLogger.info("充电状态=====>未充电")
                    completion(true, .notCharging)
                }

            case let .failure(error):
                BDLogger.info("读取充电状态失败=====>\(error)")
                completion(false, .notCharging)
            }
        }
    }

    // 读取温度
    @objc public func readTemperature(completion: @escaping (_ success: Bool, _ temperature: Int) -> Void) {
        RingManager.shared.readTemperature { res in
            switch res {
            case let .success(value):
                BDLogger.info("读取温度成功=====>\(value)")
                completion(true, value)

            case let .failure(error):
                BDLogger.info("读取温度失败=====>\(error)")
                completion(false, 0)
            }
        }
    }

    // MARK: - 血氧测量

    @objc public func startO2Measurement(
        progress: @escaping (_ progress: Double) -> Void,
        waveData: @escaping (_ sequence: Int, _ count: Int, _ data: [UInt8]) -> Void,
        completion: @escaping (_ success: Bool, _ value: Int) -> Void
    ) {
        RingManager.shared.readO2(progressBlock: { progressValue in
            BDLogger.info("血氧测量进度 =====>\(progressValue)")
            progress(progressValue)
        }, isOpenWave: true) { seq, num, datas in
            BDLogger.info("血氧波形数据：序号\(seq), 个数\(num)")
            waveData(seq, num, datas)
        } resultBlock: { res in
            switch res {
            case let .success(value):
                BDLogger.info("血氧测量成功=====>\(value)")
                completion(true, value)
            case let .failure(error):
                BDLogger.info("血氧测量失败=====>\(error)")
                completion(false, 0)
            }
        }
    }

    // MARK: - HRV测量

    @objc public func startHRVMeasurement(
        progress: @escaping (_ progress: Double) -> Void,
        waveData: @escaping (_ sequence: Int, _ count: Int, _ data: [UInt8]) -> Void,
        completion: @escaping (_ success: Bool, _ value: Int) -> Void
    ) {
        RingManager.shared.readHRV(progressBlock: { progressValue in
            BDLogger.info("HRV测量进度 =====>\(progressValue)")
            progress(progressValue)
        }, isOpenWave: true) { seq, num, datas in
            BDLogger.info("HRV波形数据：序号\(seq), 个数\(num)")
            waveData(seq, num, datas)
        } resultBlock: { res in
            switch res {
            case let .success(value):
                BDLogger.info("HRV测量成功=====>\(value)")
                completion(true, value)
            case let .failure(error):
                BDLogger.info("HRV测量失败=====>\(error)")
                completion(false, 0)
            }
        }
    }

    // MARK: - 心率测量

    @objc public func startHeartRateMeasurement(
        rrTime: UInt8,
        progress: @escaping (_ progress: Double) -> Void,
        rrData: @escaping (_ sequence: Int, _ count: Int, _ data: [Int]) -> Void,
        heartRate: @escaping (_ value: Int) -> Void,
        completion: @escaping (_ success: Bool, _ value: Int) -> Void
    ) {
        RingManager.shared.readHeartRateWithRR(rrTime: rrTime, progressBlock: { progressValue in
            BDLogger.info("心率测量进度 =====>\(progressValue)")
            progress(progressValue)
        }, inHeartRRBlock: { seq, num, datas in
            BDLogger.info("RR数据：序号\(seq), 个数\(num)")
            rrData(seq, num, datas)
        }, inHeartBlock: { heartValue in
            BDLogger.info("测量中的心率:\(heartValue)")
            heartRate(heartValue)
        }, resultBlock: { res in
            switch res {
            case let .success(value):
                BDLogger.info("心率测量成功=====>\(value)")
                completion(true, value)
            case let .failure(error):
                BDLogger.info("心率测量失败=====>\(error)")
                completion(false, 0)
            }
        })
    }

    @objc public func clearRingData(completion: @escaping (_ success: Bool) -> Void) {
        RingManager.shared.clearRingData { res in
            switch res {
            case let .success(value):
                BDLogger.info("清除数据成功=====>\(value)")
                completion(true)
            case let .failure(error):
                BDLogger.info("清除数据失败=====>\(error)")
                completion(false)
            }
        }
    }

    // MARK: - 读取所有历史数据

    @objc public func readAllHistoryData(
        progress: @escaping (_ progress: Double, _ data: RingDataModel) -> Void,
        completion: @escaping (_ success: Bool) -> Void
    ) {
        RingManager.shared.readAllHistoryDatas { progressValue, dataModel in
            BDLogger.info("读取进度 =====>\(progressValue)")
            if let model = dataModel as? RingDataModel {
                progress(progressValue, model)
            }
        } resultBlock: { res in
            switch res {
            case .success:
                BDLogger.info("读取所有历史数据成功")
                completion(true)
            case let .failure(error):
                BDLogger.info("读取所有历史数据失败====>\(error)")
                completion(false)
            }
        }
    }

    // MARK: - 读取新的历史数据

    @objc public func readNewHistoryData(
        progress: @escaping (_ progress: Double, _ data: RingDataModel) -> Void,
        completion: @escaping (_ success: Bool) -> Void
    ) {
        RingManager.shared.readNewHistoryDatas { progressValue, dataModel in
            BDLogger.info("读取进度 =====>\(progressValue)")
            if let model = dataModel as? RingDataModel {
                progress(progressValue, model)
            }
        } resultBlock: { res in
            switch res {
            case .success:
                BDLogger.info("读取新历史数据成功")
                completion(true)
            case let .failure(error):
                BDLogger.info("读取新历史数据失败====>\(error)")
                completion(false)
            }
        }
    }

    // MARK: - 读取App版本

    @objc public func readAppVersion(completion: @escaping (_ success: Bool, _ version: String?) -> Void) {
        RingManager.shared.readAppVersion { res in
            switch res {
            case let .success(version):
                BDLogger.info("读取App版本成功=====>\(version)")
                completion(true, version)
            case let .failure(error):
                BDLogger.info("读取App版本失败=====>\(error)")
                completion(false, nil)
            }
        }
    }

    // MARK: - 读取硬件版本

    @objc public func readHardwareVersion(completion: @escaping (_ success: Bool, _ version: String?) -> Void) {
        RingManager.shared.readHardWareVersion { res in
            switch res {
            case let .success(version):
                BDLogger.info("读取硬件版本成功=====>\(version)")
                completion(true, version)
            case let .failure(error):
                BDLogger.info("读取硬件版本失败=====>\(error)")
                completion(false, nil)
            }
        }
    }

    // MARK: - 计算睡眠数据

    @objc public func calculateSleep(forDate date: Date) -> RingSleepModel? {
        let sleepModel = RingManager.shared.caculateSleep(targetDate: date)
        BDLogger.info("计算睡眠数据成功")
        return sleepModel
    }

    /// 设置采集周期
    /// - Parameters:
    ///   - time: 时间单位秒(最小值60s)
    ///   - completion: 结果回调
    @objc public func setFrequency(time: Int, completion: @escaping (_ success: Bool) -> Void) {
        RingManager.shared.setFrequency(time: time) { res in
            switch res {
            case let .success(value):
                BDLogger.info("设置采集频率成功=====>\(value)")
                completion(true)
            case let .failure(error):
                BDLogger.info("设置采集频率失败=====>\(error)")
                completion(false)
            }
        }
    }

    // MARK: - 读取采集频率

    @objc public func readFrequency(completion: @escaping (_ success: Bool, _ frequency: Int) -> Void) {
        RingManager.shared.readFrequency { res in
            switch res {
            case let .success(value):
                BDLogger.info("读取采集频率成功=====>\(value)秒")
                completion(true, value)
            case let .failure(error):
                BDLogger.info("读取采集频率失败=====>\(error)")
                completion(false, 0)
            }
        }
    }

    // MARK: - 重置设备

    @objc public func resetDevice(completion: @escaping (_ success: Bool) -> Void) {
        RingManager.shared.reset { res in
            switch res {
            case let .success(value):
                BDLogger.info("重置设备成功=====>\(value)")
                completion(true)
            case let .failure(error):
                BDLogger.info("重置设备失败=====>\(error)")
                completion(false)
            }
        }
    }
}
