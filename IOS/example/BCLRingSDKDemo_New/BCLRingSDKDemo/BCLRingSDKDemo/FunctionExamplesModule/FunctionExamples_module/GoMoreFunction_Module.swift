//
//  GoMoreFunction_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/12/15.
//  GoMore功能模块 - 授权状态查询、PKey下发、个人信息设置、获取及睡眠数据（421-450）

import BCLRingSDK
import QMUIKit
import UIKit

/// GoMore功能模块 - (421-450)
class GoMoreFunction_Module: BaseFunction_Module {
    // MARK: - Initialization

    init() {
        super.init(functionIdRange: 421 ... 450)
    }

    // MARK: - FunctionModule Protocol

    override func executeFunction(id: Int) {
        switch id {
        case 421: // 查询GoMore授权状态
            queryGoMoreAuthStatus()
        case 422: // 下发GoMore授权PKey
            presentPKeyInputDialog()
        case 423: // 设置GoMore个人信息
            presentPersonalInfoDialog()
        case 424: // 获取GoMore个人信息
            getGoMorePersonalInformation()
        case 425: // 读取戒指中GoMore睡眠数据
            readGoMoreSleepData()
        case 426: // 提交GoMore睡眠数据到云端
            uploadGoMoreSleepData()
        case 427: // 查询指定日期的GoMore睡眠数据详情
            showGoMoreSleepQueryDialog()
        case 428: // 查询指定时间范围的GoMore睡眠数据
            showGoMoreSleepBatchQueryDialog()
        case 429: // 获取GoMore授权PKey
            presentGoMorePKeyRequestDialog()
        case 430: // 保存GoMore授权设备信息
            presentGoMorePKeySaveDialog()
        case 431: // 通过服务端查询Gomore授权状态
            presentGoMorePKeyStatusQueryDialog()
        case 432: // Gomore授权状态检查并自动授权处理
            presentGoMoreAutoAuthDialog()
        default:
            showError("未知功能ID: \(id)")
        }
    }

    // MARK: - 421: 查询GoMore授权状态

    private func queryGoMoreAuthStatus() {
        BDLogger.info("📤 查询GoMore授权状态...")
        showLoading("查询授权状态中...", userInteractionEnabled: false)

        BCLRingManager.shared.queryGoMoreAuthStatus { [weak self] result in
            self?.hideLoading()

            switch result {
            case let .success(response):
                BDLogger.info("✅ GoMore授权状态查询成功")
                let authStatusText = response.isAuthorized == true ? "已授权" : "未授权"
                BDLogger.info("授权状态: \(authStatusText)")
                BDLogger.info("MCU ID: \(response.mcuIdHexString ?? "未知")")

            case let .failure(error):
                BDLogger.error("❌ 查询GoMore授权状态失败: \(error)")
                self?.showError("查询失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 422: 下发GoMore授权PKey

    private func presentPKeyInputDialog() {
        let contentView = GoMorePKeyConfig_Dialog(x: 0, y: 0, width: 320, height: 320)
        contentView.confirmButtonCallback = { [weak self] pKey in
            self?.sendGoMorePKey(pKey: pKey)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func sendGoMorePKey(pKey: String) {
        BDLogger.info("📤 下发GoMore授权PKey...")
        BDLogger.info("PKey长度: \(pKey.count) 字符")
        showLoading("下发PKey中...", userInteractionEnabled: false)

        BCLRingManager.shared.sendGoMorePKey(pKey: pKey) { [weak self] result in
            self?.hideLoading()

            switch result {
            case let .success(response):
                BDLogger.info("✅ GoMore PKey下发成功")
                let authStatusText = response.isAuthorized == true ? "已授权" : "未授权"
                BDLogger.info("授权状态: \(authStatusText)")
                BDLogger.info("MCU ID: \(response.mcuIdHexString ?? "未知")")

            case let .failure(error):
                BDLogger.error("❌ 下发GoMore PKey失败: \(error)")
                self?.showError("下发失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 429: 获取GoMore授权PKey

    private func presentGoMorePKeyRequestDialog() {
        let contentView = GoMorePKeyRequestConfig_Dialog(x: 0, y: 0, width: 320, height: 300)
        contentView.confirmButtonCallback = { [weak self] deviceId, apiKey in
            self?.requestGoMorePKey(deviceId: deviceId, apiKey: apiKey)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func requestGoMorePKey(deviceId: String, apiKey: String) {
        let trimmedDeviceId = deviceId.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedDeviceId.isEmpty else {
            showError("deviceId不能为空")
            return
        }

        guard !trimmedApiKey.isEmpty else {
            showError("apiKey不能为空")
            return
        }

        BDLogger.info("📤 请求GoMore PKey...")
        showLoading("请求PKey中...", userInteractionEnabled: false)

        BCLRingManager.shared.requestGomorePKey(deviceId: trimmedDeviceId, apiKey: trimmedApiKey) { [weak self] result in
            self?.hideLoading()

            switch result {
            case .success(let pKey):
                guard let PKey = pKey else {
                    BDLogger.info("未查询到该设备的授权信息，请重新进行授权")
                    return
                }
                BDLogger.info("✅ 获取Gomore pKey成功：\(PKey)")
            case let .failure(error):
                BDLogger.error("❌ 获取GoMore PKey失败: \(error)")
                self?.showError("获取失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 430: 保存GoMore授权设备信息

    private func presentGoMorePKeySaveDialog() {
        let contentView = GoMorePKeySaveConfig_Dialog(x: 0, y: 0, width: 320, height: 420)
        contentView.confirmButtonCallback = { [weak self] companyApiKey, deviceId, mac, pkey in
            self?.saveGoMorePKey(companyApiKey: companyApiKey, deviceId: deviceId, mac: mac, pkey: pkey)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func saveGoMorePKey(companyApiKey: String, deviceId: String, mac: String, pkey: String) {
        let trimmedCompanyApiKey = companyApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDeviceId = deviceId.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMac = mac.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPkey = pkey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedCompanyApiKey.isEmpty else {
            showError("companyApiKey不能为空")
            return
        }

        guard !trimmedDeviceId.isEmpty else {
            showError("deviceId不能为空")
            return
        }

        guard !trimmedMac.isEmpty else {
            showError("mac不能为空")
            return
        }

        guard !trimmedPkey.isEmpty else {
            showError("pkey不能为空")
            return
        }

        BDLogger.info("📤 保存GoMore授权设备信息...")
        showLoading("保存设备信息中...", userInteractionEnabled: false)

        BCLRingManager.shared.saveGomorePKey(companyApiKey: trimmedCompanyApiKey, deviceId: trimmedDeviceId, mac: trimmedMac, pkey: trimmedPkey) { [weak self] result in
            self?.hideLoading()

            switch result {
            case .success:
                BDLogger.info("✅ 保存GoMore设备信息成功")
                self?.showSuccess("保存成功")
            case let .failure(error):
                BDLogger.error("❌ 保存GoMore设备信息失败: \(error)")
                self?.showError("保存失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 423: 设置GoMore个人信息

    private func presentPersonalInfoDialog() {
        let contentView = SettingGoMorePersonalInformation_Dialog(x: 0, y: 0, width: 320, height: 480)
        contentView.confirmButtonCallback = { [weak self] age, gender, height, weight, maxHeartRate, normalHeartRate, maxOxygenUptake in
            self?.setGoMorePersonalInformation(
                age: age,
                gender: gender,
                height: height,
                weight: weight,
                maxHeartRate: maxHeartRate,
                normalHeartRate: normalHeartRate,
                maxOxygenUptake: maxOxygenUptake
            )
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func setGoMorePersonalInformation(age: UInt8, gender: UInt8, height: UInt8, weight: UInt8, maxHeartRate: Int16?, normalHeartRate: Int8?, maxOxygenUptake: Int8?) {
        BDLogger.info("📤 设置GoMore个人信息...")
        BDLogger.info("参数: 年龄=\(age), 性别=\(gender), 身高=\(height)cm, 体重=\(weight)kg")
        BDLogger.info("可选参数: 最大心率=\(String(describing: maxHeartRate)), 常态心率=\(String(describing: normalHeartRate)), 最大摄氧量=\(String(describing: maxOxygenUptake))")
        showLoading("设置个人信息中...", userInteractionEnabled: false)

        BCLRingManager.shared.goMoreSetPersonalInformation(age: age, gender: gender, height: height, weight: weight, maxHeartRate: maxHeartRate, normalHeartRate: normalHeartRate, maxOxygenUptake: maxOxygenUptake) { [weak self] result in
            self?.hideLoading()

            switch result {
            case let .success(response):
                BDLogger.info("✅ GoMore个人信息设置成功")
                BDLogger.info("设置结果: \(response.success)")

                let resultText = response.success ? "成功" : "失败"
                self?.showAlert(title: "设置结果", message: "个人信息设置: \(resultText)")

            case let .failure(error):
                BDLogger.error("❌ 设置GoMore个人信息失败: \(error)")
                self?.showError("设置失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 424: 获取GoMore个人信息

    private func getGoMorePersonalInformation() {
        BDLogger.info("📤 获取GoMore个人信息...")
        showLoading("获取个人信息中...", userInteractionEnabled: false)

        BCLRingManager.shared.goMoreGetPersonalInformation { [weak self] result in
            self?.hideLoading()

            switch result {
            case let .success(response):
                BDLogger.info("✅ GoMore个人信息获取成功")
                BDLogger.info("年龄: \(response.age)")
                BDLogger.info("性别: \(response.gender)")
                BDLogger.info("身高: \(response.height) cm")
                BDLogger.info("体重: \(response.weight) kg")
                BDLogger.info("最大心率: \(String(describing: response.maxHeartRate))")
                BDLogger.info("常态心率: \(String(describing: response.normalHeartRate))")
                BDLogger.info("最大摄氧量: \(String(describing: response.maxOxygenUptake))")

                let genderText = response.gender == 0 ? "女性" : "男性"
                let message = """
                年龄: \(response.age)岁
                性别: \(genderText)
                身高: \(response.height) cm
                体重: \(response.weight) kg
                最大心率: \(String(describing: response.maxHeartRate))
                常态心率: \(String(describing: response.normalHeartRate))
                最大摄氧量: \(String(describing: response.maxOxygenUptake))
                """
                self?.showAlert(title: "GoMore个人信息", message: message)

            case let .failure(error):
                BDLogger.error("❌ 获取GoMore个人信息失败: \(error)")
                self?.showError("获取失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 425: 读取戒指中GoMore睡眠数据

    private func readGoMoreSleepData() {
        BDLogger.info("开始读取戒指中GoMore睡眠数据")
        showLoading("读取睡眠数据中...", userInteractionEnabled: false)

        BCLRingManager.shared.readGoMoreSleepData { [weak self] result in
            self?.hideLoading()

            switch result {
            case let .success(response):
                self?.handleGoMoreSleepDataResponse(response)
            case let .failure(error):
                BDLogger.error("❌ 读取GoMore睡眠数据失败: \(error)")
                self?.showError("读取失败: \(error.localizedDescription)")
            }
        }
    }

    /// 处理GoMore睡眠数据响应
    private func handleGoMoreSleepDataResponse(_ response: BCLGoMoreSleepDataResponse) {
        let sleepModels = response.sleepModels

        if sleepModels.isEmpty {
            BDLogger.info("⚠️ 设备中没有GoMore睡眠数据")
            showError("无睡眠数据")
            return
        }

        BDLogger.info("\n========== GoMore睡眠数据读取成功 ==========")
        BDLogger.info("📊 共读取到 \(sleepModels.count) 个数据包")
        BDLogger.info("=========================================\n")

        // 统计总览和分期数据包数量
        let overviewCount = sleepModels.filter { $0.isOverview }.count
        let stagesCount = sleepModels.filter { $0.isStagesData }.count
        BDLogger.info("睡眠总览包: \(overviewCount) 个")
        BDLogger.info("睡眠分期包: \(stagesCount) 个")

        // 遍历处理每个数据包
        for (index, model) in sleepModels.enumerated() {
            BDLogger.info("\n########## 第 \(index + 1) 个数据包 ##########")
            handleSleepModelData(model, index: index + 1)
        }

        BDLogger.info("\n✅ 所有GoMore睡眠数据处理完成\n")
    }

    /// 处理单个睡眠数据模型
    private func handleSleepModelData(_ model: BCLGoMoreSleepModel, index: Int) {
        if model.isOverview {
            // 睡眠总览数据
            handleSleepOverviewModel(model, recordIndex: index)
        } else if model.isStagesData {
            // 睡眠分期数据
            handleSleepStagesModel(model, recordIndex: index)
        }
    }

    /// 处理睡眠总览数据
    private func handleSleepOverviewModel(_ model: BCLGoMoreSleepModel, recordIndex: Int) {
        BDLogger.info("\n========== 睡眠总览 [包 \(recordIndex)] ==========")

        // 时间信息
        let startDate = Date(timeIntervalSince1970: TimeInterval(model.startTs))
        let endDate = Date(timeIntervalSince1970: TimeInterval(model.endTs))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current

        BDLogger.info("📅 睡眠时间: \(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))")
        BDLogger.info("⏱ 睡眠时长: \(model.sleepPeriod) 分钟")
        BDLogger.info("💤 睡眠类型: \(model.isLongSleep ? "长睡" : "短睡")")

        // 睡眠质量
        BDLogger.info("\n--- 睡眠质量 ---")
        BDLogger.info("⭐️ 睡眠评分: \(model.score) / 100")
        BDLogger.info("📊 睡眠效率: \(String(format: "%.1f", model.efficiencyPercent))%")
        BDLogger.info("⏰ 睡眠潜伏期: \(model.latency) 分钟")
        BDLogger.info("🔄 入睡后清醒时间(WASO): \(model.waso) 分钟")
        BDLogger.info("⏱ 总睡眠时间: \(model.totalSleepTime) 分钟")

        // 各阶段时长和比例
        BDLogger.info("\n--- 各睡眠阶段 ---")
        BDLogger.info("😴 深睡: \(model.deepNumMinutes) 分钟 (\(String(format: "%.1f", Double(model.deepRatio) / 100))%)")
        BDLogger.info("💤 浅睡: \(model.lightNumMinutes) 分钟 (\(String(format: "%.1f", Double(model.lightRatio) / 100))%)")
        BDLogger.info("👁 眼动(REM): \(model.remNumMinutes) 分钟 (\(String(format: "%.1f", Double(model.remRatio) / 100))%)")
        BDLogger.info("⏰ 清醒: \(model.wakeNumMinutes) 分钟 (\(String(format: "%.1f", Double(model.wakeRatio) / 100))%)")

        BDLogger.info("\n📊 有效数据点数: \(model.numEpochs) 个")
        BDLogger.info("===============================\n")
    }

    /// 处理睡眠分期数据
    private func handleSleepStagesModel(_ model: BCLGoMoreSleepModel, recordIndex: Int) {
        BDLogger.info("\n========== 睡眠分期数据 [包 \(recordIndex)] ==========")
        BDLogger.info("📦 包序号: \(model.packNo + 1) / \(model.packNum)")
        BDLogger.info("📊 当前包分期数据长度: \(model.stageNum)")

        if model.stages.isEmpty {
            BDLogger.info("⚠️ 该包没有睡眠分期数据")
            BDLogger.info("===============================\n")
            return
        }

        BDLogger.info("分期说明: 0=唤醒, 1=眼动(REM), 2=浅睡, 3=深睡")

        // 统计各阶段数量
        var stageCounts: [Int16: Int] = [0: 0, 1: 0, 2: 0, 3: 0]
        for stage in model.stages {
            stageCounts[stage, default: 0] += 1
        }

        BDLogger.info("\n--- 分期统计 ---")
        BDLogger.info("⏰ 唤醒: \(stageCounts[0] ?? 0) 个点")
        BDLogger.info("👁 眼动(REM): \(stageCounts[1] ?? 0) 个点")
        BDLogger.info("💤 浅睡: \(stageCounts[2] ?? 0) 个点")
        BDLogger.info("😴 深睡: \(stageCounts[3] ?? 0) 个点")

        let preview = model.stages.prefix(20).map { String($0) }.joined(separator: ", ")
        BDLogger.info("\n--- 数据预览(前20个) ---")
        BDLogger.info("[\(preview)\(model.stages.count > 20 ? "..." : "")]")

        BDLogger.info("===============================\n")
    }

    private func handleGoMoreSleepDataError(_ error: BCLError) {
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

    // MARK: - 426: 提交GoMore睡眠数据到云端

    private func uploadGoMoreSleepData() {
        BDLogger.info("📤 提交GoMore睡眠数据到云端")
        showLoading("读取睡眠数据中...", userInteractionEnabled: false)

        BCLRingManager.shared.readGoMoreSleepData { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(response):
                let sleepModels = response.sleepModels
                guard !sleepModels.isEmpty else {
                    self.hideLoading()
                    BDLogger.info("⚠️ 无睡眠数据可提交")
                    self.showError("无睡眠数据可提交")
                    return
                }

                BDLogger.info("📦 读取到 \(sleepModels.count) 个数据包，开始上传")
                self.showLoading("上传睡眠数据中...", userInteractionEnabled: false)

                BCLRingManager.shared.uploadGoMoreSleepData(sleepModels: sleepModels) { [weak self] uploadResult in
                    guard let self = self else { return }
                    self.hideLoading()

                    switch uploadResult {
                    case .success:
                        BDLogger.info("✅ GoMore睡眠数据上传成功，共\(sleepModels.count)个数据包")
                        self.showSuccess("上传成功：\(sleepModels.count)个数据包")
                    case let .failure(error):
                        self.handleGoMoreSleepUploadError(error)
                    }
                }
            case let .failure(error):
                self.hideLoading()
                BDLogger.error("❌ 读取GoMore睡眠数据失败: \(error)")
                self.showError("读取失败: \(error.localizedDescription)")
            }
        }
    }

    private func handleGoMoreSleepUploadError(_ error: BCLError) {
        BDLogger.error("❌ GoMore睡眠数据上传失败: \(error)")

        switch error {
        case let .network(.invalidParameters(message)):
            showError("参数无效: \(message)")
        case let .network(.httpError(code)):
            showError("HTTP错误：\(code)")
        case let .network(.serverError(code, message)):
            showError("服务器错误[\(code)]: \(message)")
        case .network(.invalidResponse):
            showError("响应数据无效")
        case let .network(.decodingError(decodingError)):
            showError("数据解析失败: \(decodingError.localizedDescription)")
        case let .network(.networkError(message)):
            showError("网络错误: \(message)")
        case let .network(.tokenError(message)):
            showError("Token异常: \(message)")
        default:
            showError("上传失败: \(error.localizedDescription)")
        }
    }

    // MARK: - 427: 查询指定日期的GoMore睡眠数据详情

    private func showGoMoreSleepQueryDialog() {
        let contentView = GoMoreSleepQueryConfig_Dialog(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 300)
        contentView.confirmButtonCallback = { [weak self] date in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.timeZone = TimeZone.current
            BDLogger.info("开始查询GoMore睡眠详情 - 日期:\(formatter.string(from: date))")
            self?.fetchGoMoreSleepData(date: date)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func fetchGoMoreSleepData(date: Date) {
        showLoading("查询睡眠数据中...", userInteractionEnabled: false)

        BCLRingManager.shared.getGoMoreSleepData(date: date) { [weak self] result in
            self?.hideLoading()

            switch result {
            case let .success(sleepModel):
                self?.handleGoMoreSleepQuerySuccess(sleepModel)
            case let .failure(error):
                self?.handleGoMoreSleepQueryError(error)
            }
        }
    }

    private func handleGoMoreSleepQuerySuccess(_ sleepModel: BCLRingSleepModel) {
        BDLogger.info("✅ GoMore睡眠详情查询成功")
        BDLogger.info("睡眠时长: \(sleepModel.hours)小时\(sleepModel.minutes)分钟, 数据条数: \(sleepModel.sleepDataList.count)")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current

        let startDate = Date(timeIntervalSince1970: TimeInterval(sleepModel.startTime))
        let endDate = Date(timeIntervalSince1970: TimeInterval(sleepModel.endTime))

        let message = """
        睡眠时长: \(sleepModel.hours)小时\(sleepModel.minutes)分钟
        睡眠评分: \(sleepModel.score)
        开始时间: \(formatter.string(from: startDate))
        结束时间: \(formatter.string(from: endDate))
        数据条数: \(sleepModel.sleepDataList.count)
        """
        showAlert(title: "GoMore睡眠详情", message: message)
    }

    private func handleGoMoreSleepQueryError(_ error: BCLError) {
        BDLogger.error("❌ GoMore睡眠详情查询失败: \(error)")

        switch error {
        case let .network(.invalidParameters(message)):
            showError("参数无效: \(message)")
        case let .network(.httpError(code)):
            showError("HTTP错误：\(code)")
        case let .network(.serverError(code, message)):
            showError("服务器错误[\(code)]: \(message)")
        case .network(.invalidResponse):
            showError("响应数据无效")
        case let .network(.decodingError(decodingError)):
            showError("数据解析失败: \(decodingError.localizedDescription)")
        case let .network(.networkError(message)):
            showError("网络错误: \(message)")
        case let .network(.tokenError(message)):
            showError("Token异常: \(message)")
        default:
            showError("查询失败: \(error.localizedDescription)")
        }
    }

    // MARK: - 428: 查询指定时间范围的GoMore睡眠数据

    private func showGoMoreSleepBatchQueryDialog() {
        let contentView = SleepDataRangeConfig_Dialog(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 360)
        contentView.confirmButtonCallback = { [weak self] dates in
            let dateList = dates.joined(separator: ", ")
            BDLogger.info("开始批量查询GoMore睡眠数据 - 日期列表:\(dateList)")
            self?.fetchGoMoreSleepDataBatch(dates: dates)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func fetchGoMoreSleepDataBatch(dates: [String]) {
        guard !dates.isEmpty else {
            showError("日期范围为空")
            return
        }

        showLoading("查询睡眠数据中...", userInteractionEnabled: false)

        BCLRingManager.shared.getGoMoreSleepDataBatch(dates: dates) { [weak self] result in
            self?.hideLoading()

            switch result {
            case let .success(models):
                self?.handleGoMoreSleepBatchQuerySuccess(models)
            case let .failure(error):
                self?.handleGoMoreSleepBatchQueryError(error)
            }
        }
    }

    private func handleGoMoreSleepBatchQuerySuccess(_ models: [BCLRingSleepDayModel]) {
        BDLogger.info("✅ GoMore睡眠数据批量查询成功，共\(models.count)条记录")
        if models.isEmpty {
            showSuccess("未查询到睡眠数据")
            return
        }

        var messageLines: [String] = []
        for model in models {
            let dateText = model.dayString ?? "-"
            let sleepSeconds = model.dayCount ?? model.time ?? 0
            let durationText = formatSleepDuration(seconds: sleepSeconds)
            BDLogger.info("日期: \(dateText), 睡眠时长: \(durationText)")
            messageLines.append("日期: \(dateText) 睡眠时长: \(durationText)")
        }

        let message = messageLines.joined(separator: "\n")
        showAlert(title: "GoMore睡眠汇总", message: message)
    }

    private func handleGoMoreSleepBatchQueryError(_ error: BCLError) {
        BDLogger.error("❌ GoMore睡眠数据批量查询失败: \(error)")

        switch error {
        case let .network(.invalidParameters(message)):
            showError("参数无效: \(message)")
        case let .network(.httpError(code)):
            showError("HTTP错误：\(code)")
        case let .network(.serverError(code, message)):
            showError("服务器错误[\(code)]: \(message)")
        case .network(.invalidResponse):
            showError("响应数据无效")
        case let .network(.decodingError(decodingError)):
            showError("数据解析失败: \(decodingError.localizedDescription)")
        case let .network(.networkError(message)):
            showError("网络错误: \(message)")
        case let .network(.tokenError(message)):
            showError("Token异常: \(message)")
        default:
            showError("查询失败: \(error.localizedDescription)")
        }
    }

    // MARK: - 431: 通过服务端查询Gomore授权状态

    private func presentGoMorePKeyStatusQueryDialog() {
        let contentView = GoMorePKeyStatusQueryConfig_Dialog(x: 0, y: 0, width: 320, height: 260)
        contentView.confirmButtonCallback = { [weak self] deviceId in
            self?.queryGoMorePKeyStatusFromServer(deviceId: deviceId)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func queryGoMorePKeyStatusFromServer(deviceId: String) {
        let trimmedDeviceId = deviceId.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedDeviceId.isEmpty else {
            showError("deviceId不能为空")
            return
        }

        BDLogger.info("📤 查询Gomore授权状态（服务端）...")
        BDLogger.info("Device ID: \(trimmedDeviceId)")
        showLoading("查询授权状态中...", userInteractionEnabled: false)

        BCLRingManager.shared.getGomorePKeyStatus(deviceId: trimmedDeviceId) { [weak self] result in
            self?.hideLoading()

            switch result {
            case let .success(pKey):
                if let pKey = pKey {
                    // 已授权
                    BDLogger.info("✅ Gomore授权状态查询成功")
                    BDLogger.info("授权状态: 已授权")
                    BDLogger.info("授权密钥(pKey): \(pKey)")
                    self?.showAlert(title: "查询结果", message: "设备已授权")
                } else {
                    // 未授权
                    BDLogger.info("✅ Gomore授权状态查询成功")
                    BDLogger.info("授权状态: 未授权")
                    self?.showAlert(title: "查询结果", message: "设备未授权，请先进行授权")
                }
            case let .failure(error):
                BDLogger.error("❌ 查询Gomore授权状态失败: \(error)")
                self?.showError("查询失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Helper Methods

    private func formatSleepDuration(seconds: Int) -> String {
        let totalSeconds = max(0, seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return "\(hours)小时\(minutes)分钟"
    }

    /// 显示Alert弹窗
    private func showAlert(title: String, message: String) {
        guard let vc = viewController else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        vc.present(alert, animated: true)
    }

    // MARK: - 432: Gomore授权状态检查并自动授权处理

    private func presentGoMoreAutoAuthDialog() {
        let contentView = GoMoreAutoAuthConfig_Dialog(x: 0, y: 0, width: 320, height: 300)
        contentView.confirmButtonCallback = { [weak self] companyKey in
            self?.checkAndAuthorizeGoMore(companyKey: companyKey)
        }

        let modalPresentation_VC = QMUIModalPresentationViewController()
        modalPresentation_VC.isModal = true
        modalPresentation_VC.contentView = contentView
        modalPresentation_VC.showWith(animated: true)
    }

    private func checkAndAuthorizeGoMore(companyKey: String) {
        let trimmedCompanyKey = companyKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedCompanyKey.isEmpty else {
            showError("公司密钥不能为空")
            return
        }

        BDLogger.info("📤 开始GoMore授权状态检查并自动授权处理...")
        BDLogger.info("Company Key: \(trimmedCompanyKey)")
        showLoading("检查授权状态中...", userInteractionEnabled: false)

        BCLRingManager.shared.checkAndAuthorizeGoMore(companyKey: trimmedCompanyKey) { [weak self] step in
            // 更新进度提示
            DispatchQueue.main.async {
                BDLogger.info("当前步骤: \(step.description), 进度: \(step.progressPercentage)%")
                self?.showLoading("[\(step.progressPercentage)%] \(step.description)")
                if step.progressPercentage == 100 {
                    self?.hideLoading()
                }
            }
        } completion: { [weak self] result in
            switch result {
            case .success(let authResult):
                BDLogger.info("✅ GoMore授权成功")
                BDLogger.info("授权结果: \(authResult)")
                self?.showSuccess("授权成功")
            case .failure(let error):
                self?.handleGoMoreAutoAuthError(error)
            }
        }
    }

    private func handleGoMoreAutoAuthError(_ error: BCLError) {
        BDLogger.error("❌ GoMore自动授权失败: \(error)")

        switch error {
        // 1. 连接相关错误
        case .connection(let connectionError):
            switch connectionError {
            case .disconnected:
                showError("设备未连接，请先连接设备")
            default:
                showError("连接错误: \(connectionError.localizedDescription)")
            }

        // 2. GoMore授权相关错误
        case .goMoreAuth(let goMoreError):
            switch goMoreError {
            case .invalidParameter:
                showError("参数无效：请检查companyKey是否正确")
            case .invalidPKeyLength:
                showError("PKey长度错误：服务端返回的PKey格式不正确")
            case .authorizationFailed:
                showError("授权失败：设备拒绝授权或PKey无效")
            case .unauthorized:
                showError("设备未授权")
            case .dataFormatError:
                showError("数据格式错误：无法获取MCU ID")
            case .unknown:
                showError("未知GoMore错误")
            }

        // 3. 网络相关错误
        case .network(let networkError):
            switch networkError {
            case .networkError(let message):
                showError("网络错误: \(message)")
            case .serverError(let code, let message):
                showError("服务器错误[\(code)]: \(message)")
            case .tokenError(let message):
                showError("Token失效，需要重新登录: \(message)")
            case .invalidParameters(let message):
                showError("请求参数错误: \(message)")
            case .invalidResponse:
                showError("服务端响应数据无效")
            default:
                showError("网络错误: \(networkError.localizedDescription ?? "未知")")
            }

        // 4. 蓝牙命令发送错误
        case .commandSending(let cmdError):
            switch cmdError {
            case .timeout:
                showError("命令超时：设备响应超时，请检查设备状态")
            case .invalidCommandFormat:
                showError("命令格式错误")
            case .characteristicNotFound:
                showError("蓝牙特征值未找到，请重新连接设备")
            default:
                showError("命令发送错误: \(cmdError.localizedDescription)")
            }

        // 5. 其他错误
        default:
            showError("其他错误: \(error.localizedDescription)")
        }
    }

    private func updateLoadingMessage(_ message: String) {
        // 更新loading提示文字
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            QMUITips.hideAllTips(in: window)
            QMUITips.showLoading(message, in: window)
        }
    }
}
