//
//  DeviceSystemSettings_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//  设备系统设置功能模块

import BCLRingSDK
import QMUIKit
import UIKit

/// 设备系统设置功能模块
class DeviceSystemSettings_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 61 ... 80)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 61: // 设置采集周期
            showSetCollectperiodDialog()
        case 62: // 读取采集周期
            readCollectPeriod()
        case 63: // 设置蓝牙名称
            showSettingBluetoothNameDialog()
        case 64: // 读取蓝牙名称
            readBluetoothName()
        case 65: // 一键自检
            oneKeySelfCheck()
        case 66: // 恢复出厂设置
            restoreFactorySettings()
        case 67: // 设置个人信息
            showSetUserInfoDialog()
        case 68: // 读取个人信息
            readPersonalInfo()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - Private Methods

    // 显示设置采集周期对话框
    private func showSetCollectperiodDialog() {
        let alert = UIAlertController(title: "设置采集周期", message: "请输入采集周期（秒）,最小值为60。\n 建议为5分钟、20分钟、30分钟", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "采集周期（秒）"
            textField.keyboardType = .numberPad
        }
        let setAction = UIAlertAction(title: "设置", style: .default) { _ in
            if let periodText = alert.textFields?.first?.text,
               let period = Int(periodText) {
                guard period >= 60 else {
                    self.showError("请输入有效的采集周期，最小值为60")
                    return
                }
                self.setCollectPeriod(collectionPeriod: period)
            }
        }
        alert.addAction(setAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    /// 61 - 设置采集周期
    private func setCollectPeriod(collectionPeriod: Int) {
        BCLRingManager.shared.setCollectPeriod(period: collectionPeriod) { result in
            switch result {
            case let .success(response):
                if response.success {
                    BDLogger.info("设置采集周期成功: \(collectionPeriod)秒")
                    self.showSuccess("设置采集周期成功: \(collectionPeriod)秒")
                } else {
                    BDLogger.error("设置采集周期失败")
                    self.showError("设置采集周期失败")
                }
            case let .failure(error):
                BDLogger.error("设置采集周期失败: \(error)")
                self.showError("设置采集周期失败")
            }
        }
    }

    /// 62 - 读取采集周期
    private func readCollectPeriod() {
        BCLRingManager.shared.getCollectPeriod { result in
            switch result {
            case let .success(response):
                BDLogger.info("采集周期: \(response.time)秒")
                self.showSuccess("采集周期: \(response.time)秒")
            case let .failure(error):
                BDLogger.error("读取采集周期失败: \(error)")
                self.showError("读取采集周期失败")
            }
        }
    }

    // 显示设置蓝牙名称对话框
    private func showSettingBluetoothNameDialog() {
        let contentView = UpdateDeviceName_Dialog(x: 15, y: UIScreen.main.bounds.height / 2 - 100, width: UIScreen.main.bounds.width - 30, height: 200)
        contentView.confirmButtonCallback = { name in
            guard name.count > 0 else {
                self.showError("蓝牙名称不能为空")
                return
            }
            self.setBluetoothName(name: name)
        }
        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    /// 63 - 设置蓝牙名称（注意部分固件在设置蓝牙名称后会进行复位操作，会导致蓝牙连接断开，如果已经配置了自动重连，SDK会自动重建蓝牙设备。如果未配置自动重连，则需要注意手动去重新连接蓝牙设备）
    private func setBluetoothName(name: String) {
        BCLRingManager.shared.setBluetoothName(name: name) { res in
            switch res {
            case let .success(res):
                if res.success {
                    BDLogger.info("设置蓝牙名称成功")
                    self.showSuccess("设置蓝牙名称成功: \(name)")
                } else {
                    BDLogger.info("设置蓝牙名称失败")
                    self.showError("设置蓝牙名称失败")
                }
            case let .failure(error):
                BDLogger.error("设置蓝牙名称失败: \(error)")
                self.showError("设置蓝牙名称失败")
            }
        }
    }

    /// 64 - 读取蓝牙名称
    private func readBluetoothName() {
        BCLRingManager.shared.getBluetoothName { res in
            switch res {
            case let .success(response):
                BDLogger.info("蓝牙名称: \(response.name ?? "")")
                self.showSuccess("蓝牙名称: \(response.name ?? "")")
            case let .failure(error):
                BDLogger.error("读取蓝牙名称失败: \(error)")
                self.showError("读取蓝牙名称失败")
            }
        }
    }

    /// 65 - 一键自检
    private func oneKeySelfCheck() {
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
                    self.showError("一键自检发现设备故障: \(response.errorDescription),\n故障码: 0x\(String(format: "%04X", response.errorCode))")
                } else {
                    // 无故障情况
                    BDLogger.info("一键自检成功，设备正常")
                    self.showSuccess("一键自检成功，设备正常")
                }
            case let .failure(error):
                // 自检操作本身失败
                BDLogger.error("一键自检操作失败: \(error)")
                self.showError("一键自检操作失败")
            }
        }
    }

    /// 66 - 恢复出厂设置
    private func restoreFactorySettings() {
        BCLRingManager.shared.restoreFactorySettings { res in
            switch res {
            case .success:
                BDLogger.info("恢复出厂设置成功")
                self.showSuccess("恢复出厂设置成功")
            case let .failure(error):
                BDLogger.error("恢复出厂设置失败: \(error)")
                self.showError("恢复出厂设置失败")
            }
        }
    }

    // 设置用户信息弹窗
    private func showSetUserInfoDialog() {
        let alert = UIAlertController(title: "设置个人信息", message: "请输入个人信息", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "性别（0-女，1-男）"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "年龄（岁）"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "身高（cm）"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "体重（kg）"
            textField.keyboardType = .numberPad
        }
        let setAction = UIAlertAction(title: "设置", style: .default) { _ in
            guard let sexText = alert.textFields?[0].text,
                  let ageText = alert.textFields?[1].text,
                  let heightText = alert.textFields?[2].text,
                  let weightText = alert.textFields?[3].text,
                  let sex = Int(sexText),
                  let age = Int(ageText),
                  let height = Int(heightText),
                  let weight = Int(weightText) else {
                self.showError("请输入有效的个人信息")
                return
            }
            self.setPersonalInfo(sex: sex, age: age, height: height, weight: weight)
        }

        alert.addAction(setAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    // 67 - 设置个人信息（注意：该功能仅部分固件支持，使用前请先确认后再使用）
    private func setPersonalInfo(sex: Int, age: Int, height: Int, weight: Int) {
        BCLRingManager.shared.setPersonalInformation(sex: sex, age: age, height: height, weight: weight) { result in
            switch result {
            case let .success(res):
                if res.status == 0 {
                    BDLogger.info("用户信息设置成功")
                    self.showSuccess("用户信息设置成功")
                } else {
                    BDLogger.info("用户信息设置失败")
                    self.showError("用户信息设置失败：状态码 \(res.status)")
                }
            case let .failure(error):
                // 处理错误
                BDLogger.error("设置失败：\(error)")
                self.showError("设置失败：\(error)")
            }
        }
    }

    /// 68 - 读取个人信息（注意：该功能仅部分固件支持，使用前请先确认后再使用）
    private func readPersonalInfo() {
        BCLRingManager.shared.getPersonalInformation { result in
            switch result {
            case let .success(userInfo):
                BDLogger.info("用户性别为：\(userInfo.sex == 0 ? "女" : "男")")
                BDLogger.info("用户年龄为：\(userInfo.sex)月")
                BDLogger.info("用户身高为：\(userInfo.sex)cm")
                BDLogger.info("用户体重为：\(userInfo.weight)kg")
                self.showSuccess("用户性别为：\(userInfo.sex == 0 ? "女" : "男")\n用户年龄为：\(userInfo.sex)月\n用户身高为：\(userInfo.sex)cm\n用户体重为：\(userInfo.weight)kg")
            case let .failure(error):
                // 处理错误
                BDLogger.error("获取失败：\(error)")
                self.showError("获取失败：\(error)")
            }
        }
    }
}
