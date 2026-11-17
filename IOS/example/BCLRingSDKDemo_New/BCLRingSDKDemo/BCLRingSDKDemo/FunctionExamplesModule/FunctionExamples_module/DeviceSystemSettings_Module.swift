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
        case 69: // 设置客户定制自动采集配置
            showCustomerAutoCollectionConfigDialog()
        case 70: // 读取客户定制自动采集配置
            getCustomerAutoCollectionConfig()
        case 71: // 设置血氧采集周期
            showBloodOxygenCollectionPeriodDialog()
        case 72: // 读取血氧采集周期
            getBloodOxygenCollectionPeriod()
        case 73: // 设置系统功能开关
            showSetSystemFeatureSwitchDialog()
        case 75: // 设置算法相关参数
            showAlgorithmParameterConfigDialog()
        case 76: // 读取算法相关参数
            getAlgorithmParameterConfig()
        case 74: // 查询系统功能开关
            showReadSystemFeatureSwitchDialog()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    /// 读取设备实际算法配置，不触发设置操作。
    private func getAlgorithmParameterConfig() {
        BCLRingManager.shared.getAlgorithmParameterConfig { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(response):
                    guard let config = response.config else {
                        self.showError("读取算法参数失败：设备未返回有效配置")
                        return
                    }
                    let message = """
                    长睡开始：\(config.longSleepStartHour)时
                    长睡结束：\(config.longSleepEndHour)时
                    计步初始阈值：\(config.stepCountInitialThresholdSeconds)秒
                    PPG周期测量时长：\(config.ppgPeriodicMeasurementDurationSeconds)秒
                    """
                    BDLogger.info("算法参数读取成功：\n\(message)")
                    self.showInfoAlert(title: "算法相关参数", message: message)
                case let .failure(error):
                    BDLogger.error("算法参数读取失败：\(error.localizedDescription)")
                    self.showError("读取算法参数失败：\(error.localizedDescription)")
                }
            }
        }
    }

    /// 展示算法参数配置，确认后将四个参数一次写入设备。
    private func showAlgorithmParameterConfigDialog() {
        let dialog = AlgorithmParameterConfig_Dialog(frame: CGRect(
            x: 0, y: 0, width: UIScreen.main.bounds.width - 30,
            height: min(600, UIScreen.main.bounds.height - 80)))
        dialog.confirmButtonCallback = { [weak self] config in
            BDLogger.info("设置算法参数：长睡=\(config.longSleepStartHour)-\(config.longSleepEndHour)时，计步阈值=\(config.stepCountInitialThresholdSeconds)秒，PPG时长=\(config.ppgPeriodicMeasurementDurationSeconds)秒")
            BCLRingManager.shared.setAlgorithmParameterConfig(config) { result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case let .success(response):
                        BDLogger.info("算法参数设置状态：\(response.statusRawValue)")
                        if response.isSuccess {
                            self.showSuccess("算法参数设置成功")
                        } else {
                            self.showError("设备设置失败，状态：\(response.statusRawValue)")
                        }
                    case let .failure(error):
                        BDLogger.error("算法参数设置失败：\(error)")
                        self.showError("算法参数设置失败：\(error.localizedDescription)")
                    }
                }
            }
        }
        let modal = QMUIModalPresentationViewController()
        modal.isModal = true
        modal.contentView = dialog
        modal.showWith(animated: true)
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

    /// 显示客户定制自动采集配置弹窗
    private func showCustomerAutoCollectionConfigDialog() {
        let alert = UIAlertController(title: "设置客户定制自动采集配置",
                                      message: "请输入 0 或 1，0=禁止，1=允许",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "夜间自动采集（0/1）"
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        alert.addTextField { textField in
            textField.placeholder = "上午自动采集（0/1）"
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        alert.addTextField { textField in
            textField.placeholder = "下午自动采集（0/1）"
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        let setAction = UIAlertAction(title: "设置", style: .default) { _ in
            guard let nightText = alert.textFields?[0].text,
                  let morningText = alert.textFields?[1].text,
                  let afternoonText = alert.textFields?[2].text,
                  let nightValue = Int(nightText),
                  let morningValue = Int(morningText),
                  let afternoonValue = Int(afternoonText),
                  [0, 1].contains(nightValue),
                  [0, 1].contains(morningValue),
                  [0, 1].contains(afternoonValue) else {
                self.showError("请输入有效配置：0=禁止，1=允许")
                return
            }
            self.setCustomerAutoCollectionConfig(nightAllowed: nightValue == 1,
                                                 morningAllowed: morningValue == 1,
                                                 afternoonAllowed: afternoonValue == 1)
        }
        alert.addAction(setAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    /// 69 - 设置客户定制自动采集配置
    private func setCustomerAutoCollectionConfig(nightAllowed: Bool,
                                                 morningAllowed: Bool,
                                                 afternoonAllowed: Bool) {
        BCLRingManager.shared.setCustomerAutoCollectionConfig(nightAllowed: nightAllowed,
                                                              morningAllowed: morningAllowed,
                                                              afternoonAllowed: afternoonAllowed) { result in
            switch result {
            case let .success(response):
                let message = self.customerAutoCollectionConfigMessage(response)
                BDLogger.info("设置客户定制自动采集配置成功: \(message)")
                self.showSuccess("设置成功\n\(message)")
            case let .failure(error):
                BDLogger.error("设置客户定制自动采集配置失败: \(error)")
                self.showError("设置客户定制自动采集配置失败")
            }
        }
    }

    /// 70 - 读取客户定制自动采集配置
    private func getCustomerAutoCollectionConfig() {
        BCLRingManager.shared.getCustomerAutoCollectionConfig { result in
            switch result {
            case let .success(response):
                let message = self.customerAutoCollectionConfigMessage(response)
                BDLogger.info("读取客户定制自动采集配置成功: \(message)")
                self.showSuccess(message)
            case let .failure(error):
                BDLogger.error("读取客户定制自动采集配置失败: \(error)")
                self.showError("读取客户定制自动采集配置失败")
            }
        }
    }

    private func customerAutoCollectionConfigMessage(_ response: BCLCustomerAutoCollectionConfigResponse) -> String {
        return """
        夜间：\(autoCollectionAllowedDescription(response.nightAllowed))(\(response.nightStatus))
        上午：\(autoCollectionAllowedDescription(response.morningAllowed))(\(response.morningStatus))
        下午：\(autoCollectionAllowedDescription(response.afternoonAllowed))(\(response.afternoonStatus))
        """
    }

    private func autoCollectionAllowedDescription(_ allowed: Bool) -> String {
        return allowed ? "允许" : "禁止"
    }

    /// 显示设置血氧采集周期弹窗
    private func showBloodOxygenCollectionPeriodDialog() {
        let alert = UIAlertController(title: "设置血氧采集周期",
                                      message: "请输入血氧采集周期倍数",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "非睡眠时周期倍数"
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        alert.addTextField { textField in
            textField.placeholder = "睡眠时周期倍数"
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        let setAction = UIAlertAction(title: "设置", style: .default) { _ in
            guard let nonSleepText = alert.textFields?[0].text,
                  let sleepText = alert.textFields?[1].text,
                  let nonSleepValue = Int(nonSleepText),
                  let sleepValue = Int(sleepText),
                  (0 ... Int(UInt16.max)).contains(nonSleepValue),
                  (0 ... Int(UInt16.max)).contains(sleepValue) else {
                self.showError("请输入有效周期倍数，范围 0-65535")
                return
            }
            self.setBloodOxygenCollectionPeriod(nonSleepPeriodMultiplier: UInt16(nonSleepValue),
                                                sleepPeriodMultiplier: UInt16(sleepValue))
        }
        alert.addAction(setAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    /// 71 - 设置血氧采集周期
    private func setBloodOxygenCollectionPeriod(nonSleepPeriodMultiplier: UInt16,
                                                sleepPeriodMultiplier: UInt16) {
        BCLRingManager.shared.setBloodOxygenCollectionPeriod(nonSleepPeriodMultiplier: nonSleepPeriodMultiplier,
                                                             sleepPeriodMultiplier: sleepPeriodMultiplier) { result in
            switch result {
            case let .success(response):
                if response.isSuccess {
                    BDLogger.info("设置血氧采集周期成功: 非睡眠=\(nonSleepPeriodMultiplier), 睡眠=\(sleepPeriodMultiplier)")
                    self.showSuccess("设置血氧采集周期成功\n非睡眠：\(nonSleepPeriodMultiplier)\n睡眠：\(sleepPeriodMultiplier)")
                } else {
                    BDLogger.error("设置血氧采集周期失败: \(response.statusRawValue)")
                    self.showError("设置血氧采集周期失败：状态码 \(response.statusRawValue)")
                }
            case let .failure(error):
                BDLogger.error("设置血氧采集周期失败: \(error)")
                self.showError("设置血氧采集周期失败")
            }
        }
    }

    /// 72 - 读取血氧采集周期
    private func getBloodOxygenCollectionPeriod() {
        BCLRingManager.shared.getBloodOxygenCollectionPeriod { result in
            switch result {
            case let .success(response):
                let message = """
                非睡眠时周期倍数：\(response.nonSleepPeriodMultiplier)
                睡眠时周期倍数：\(response.sleepPeriodMultiplier)
                """
                BDLogger.info("读取血氧采集周期成功: 非睡眠=\(response.nonSleepPeriodMultiplier), 睡眠=\(response.sleepPeriodMultiplier)")
                self.showSuccess(message)
            case let .failure(error):
                BDLogger.error("读取血氧采集周期失败: \(error)")
                self.showError("读取血氧采集周期失败")
            }
        }
    }

    /// 73 - 显示系统功能开关设置弹窗。
    ///
    /// 类型支持十进制或`0x`前缀的十六进制输入，便于直接验证固件后续新增类型。
    private func showSetSystemFeatureSwitchDialog() {
        let alert = UIAlertController(title: "设置系统功能开关",
                                      message: "请输入类型原始值（0...255）。\n当前已知：0x01=充电时停止全部功能",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "类型，如 0x01 或 1"
            textField.keyboardType = .asciiCapable
            textField.text = "0x01"
        }
        alert.addAction(UIAlertAction(title: "开启", style: .default) { _ in
            self.handleSetSystemFeatureSwitch(typeText: alert.textFields?.first?.text,
                                              data: BCLSystemFeatureSwitchData.enabled)
        })
        alert.addAction(UIAlertAction(title: "关闭", style: .default) { _ in
            self.handleSetSystemFeatureSwitch(typeText: alert.textFields?.first?.text,
                                              data: BCLSystemFeatureSwitchData.disabled)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    /// 执行系统功能开关设置。
    private func handleSetSystemFeatureSwitch(typeText: String?, data: Int) {
        guard let type = parseProtocolByte(typeText) else {
            BDLogger.error("设置系统功能开关失败：类型必须是0...255的十进制或十六进制数")
            showError("请输入有效类型，范围0...255")
            return
        }
        BCLRingManager.shared.setSystemFeatureSwitch(type: type, data: data) { result in
            let requestDescription = "type=\(self.hexByte(type)), data=\(self.hexByte(data))"
            switch result {
            case let .success(response):
                let responseDescription = "length=\(response.length), type=\(self.hexByte(response.typeRawValue)), status=\(self.hexByte(response.statusRawValue))"
                if response.isSuccess {
                    BDLogger.info("设置系统功能开关成功：\(requestDescription)，\(responseDescription)")
                    self.showSuccess("设置成功\n\(requestDescription)\n\(responseDescription)")
                } else {
                    BDLogger.error("设备设置系统功能开关失败：\(requestDescription)，\(responseDescription)")
                    self.showError("设备设置失败\n\(requestDescription)\n\(responseDescription)")
                }
            case let .failure(error):
                BDLogger.error("设置系统功能开关失败：\(requestDescription)，error=\(error)")
                self.showError("设置系统功能开关失败：\(error)")
            }
        }
    }

    /// 74 - 显示系统功能开关查询弹窗。
    private func showReadSystemFeatureSwitchDialog() {
        let alert = UIAlertController(title: "查询系统功能开关",
                                      message: "请输入类型原始值（0...255）。\n支持0x前缀的十六进制输入",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "类型，如 0x01 或 1"
            textField.keyboardType = .asciiCapable
            textField.text = "0x01"
        }
        alert.addAction(UIAlertAction(title: "查询", style: .default) { _ in
            guard let type = self.parseProtocolByte(alert.textFields?.first?.text) else {
                BDLogger.error("查询系统功能开关失败：类型必须是0...255的十进制或十六进制数")
                self.showError("请输入有效类型，范围0...255")
                return
            }
            self.readSystemFeatureSwitch(type: type)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        viewController?.present(alert, animated: true)
    }

    /// 查询系统功能开关并展示协议原始字段。
    private func readSystemFeatureSwitch(type: Int) {
        BCLRingManager.shared.readSystemFeatureSwitch(type: type) { result in
            switch result {
            case let .success(response):
                let stateDescription: String
                switch response.isEnabled {
                case true?:
                    stateDescription = "开启"
                case false?:
                    stateDescription = "关闭"
                case nil:
                    stateDescription = "未知"
                }
                let message = """
                length：\(response.length)
                type：\(self.hexByte(response.typeRawValue))
                state：\(self.hexByte(response.stateRawValue))（\(stateDescription)）
                """
                BDLogger.info("查询系统功能开关成功：\(message.replacingOccurrences(of: "\n", with: "，"))")
                self.showSuccess(message)
            case let .failure(error):
                BDLogger.error("查询系统功能开关失败：type=\(self.hexByte(type))，error=\(error)")
                self.showError("查询系统功能开关失败：\(error)")
            }
        }
    }

    /// 将十进制或`0x`前缀的十六进制文本解析为协议单字节整数。
    private func parseProtocolByte(_ text: String?) -> Int? {
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return nil
        }
        let value: Int?
        if text.lowercased().hasPrefix("0x") {
            value = Int(text.dropFirst(2), radix: 16)
        } else {
            value = Int(text)
        }
        guard let value = value, (0 ... Int(UInt8.max)).contains(value) else {
            return nil
        }
        return value
    }

    /// 将协议单字节整数格式化为两位十六进制文本。
    private func hexByte(_ value: Int) -> String {
        return String(format: "0x%02X", value)
    }
}
