//
//  FunctionDemo_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  功能示例页 - 使用CollectionView展示所有SDK功能
//

import BCLRingSDK
import SnapKit
import UIKit

class FunctionDemo_VC: UIViewController {
    // MARK: - Properties

    /// 功能执行器
    private let executor = FunctionExecutor.shared

    /// 所有功能分组数据
    private var sections: [FunctionSection] = []

    /// CollectionView
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.systemGroupedBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(FunctionDemoCell.self, forCellWithReuseIdentifier: FunctionDemoCell.reuseIdentifier)
        cv.register(
            FunctionSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: FunctionSectionHeader.reuseIdentifier
        )
        return cv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFunctionData()
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        executor.currentViewController = self
        // 刷新数据以更新动态标题（如功能ID 126的订阅状态）
        loadFunctionData()
    }

    // MARK: - UI Setup

    private func setupUI() {
        title = "功能示例"
        view.backgroundColor = UIColor.systemGroupedBackground

        // 添加子视图
        view.addSubview(collectionView)

        // 约束布局
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - CollectionView Layout

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            // Item大小 (每行2个)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), // item 占 group 的 100% 宽度
                heightDimension: .estimated(100) // 使用 estimated 允许动态高度
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            // 只在垂直方向使用 edgeSpacing
            item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
                leading: .fixed(0),
                top: .fixed(4),
                trailing: .fixed(0),
                bottom: .fixed(4)
            )

            // Group大小 - 包含2个 item
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100) // 使用 estimated 允许动态高度
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            // 使用 interItemSpacing 设置 item 之间的水平间距
            group.interItemSpacing = .fixed(8)

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

            // Section Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

            return section
        }
    }

    // MARK: - Data Loading

    private func loadFunctionData() {
        sections = generateFunctionSections()
        collectionView.reloadData()
    }

    /// 设置通知监听
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefreshFunctionList),
            name: NSNotification.Name("RefreshFunctionList"),
            object: nil
        )
    }

    /// 处理刷新功能列表通知
    @objc private func handleRefreshFunctionList() {
        loadFunctionData()
    }

    /// 生成所有功能分组数据
    private func generateFunctionSections() -> [FunctionSection] {
        var sectionsDict: [FunctionCategory: [FunctionDemoModel]] = [:]

        // 获取所有功能数据
        let allFunctions = getAllFunctions()

        // 按分类分组
        for function in allFunctions {
            if sectionsDict[function.category] == nil {
                sectionsDict[function.category] = []
            }
            sectionsDict[function.category]?.append(function)
        }

        // 按照displayOrder排序
        let sortedSections = FunctionCategory.displayOrder.compactMap { category -> FunctionSection? in
            guard let items = sectionsDict[category], !items.isEmpty else { return nil }
            return FunctionSection(category: category, items: items)
        }

        return sortedSections
    }

    /// 获取HID服务订阅状态的动态标题
    private func getHIDServiceSubscriptionTitle() -> String {
        let isSubscribed = BCLRingManager.shared.gesturePairingPushBlock != nil
        return isSubscribed ? "订阅HID服务状态-开(Z4I定制)" : "订阅HID服务状态-关(Z4I定制)"
    }

    /// 获取所有功能数据 (216个功能)
    private func getAllFunctions() -> [FunctionDemoModel] {
        return [
            // 蓝牙设备搜索
            FunctionDemoModel(id: 1, title: "蓝牙设备搜索", category: .bluetoothDeviceSearch, requiresConnection: false),
            FunctionDemoModel(id: 2, title: "停止蓝牙设备搜索", category: .bluetoothDeviceSearch, requiresConnection: false),

            // 基础连接功能 (11-10)
            FunctionDemoModel(id: 11, title: "搜索蓝牙设备列表", category: .bluetoothConnection, requiresConnection: false),
            FunctionDemoModel(id: 12, title: "断开连接", category: .bluetoothConnection, requiresConnection: false),
            FunctionDemoModel(id: 13, title: "切换自动重连", category: .bluetoothConnection),
            FunctionDemoModel(id: 14, title: "实时RSSI读取", category: .bluetoothConnection),
            FunctionDemoModel(id: 15, title: "停止RSSI读取", category: .bluetoothConnection),

            // 二代协议-App复合指令（绑定指令、连接指令、刷新指令）（21-30）
            FunctionDemoModel(id: 21, title: "App复合指令-绑定指令", category: .appEvent),
            FunctionDemoModel(id: 22, title: "App复合指令-连接指令", category: .appEvent),
            FunctionDemoModel(id: 23, title: "App复合指令-刷新指令", category: .appEvent),

            // 时间同步 (31-40)
            FunctionDemoModel(id: 31, title: "同步时间", category: .timeSync),
            FunctionDemoModel(id: 32, title: "读取时间", category: .timeSync),
            FunctionDemoModel(id: 33, title: "城市时区列表", category: .timeSync, requiresConnection: false),

            // 版本信息 (31-40)
            FunctionDemoModel(id: 41, title: "获取硬件版本", category: .versionInfo),
            FunctionDemoModel(id: 42, title: "获取固件版本", category: .versionInfo),

            // 电量管理 （51-60）
            FunctionDemoModel(id: 51, title: "获取电量信息", category: .batteryManagement),
            FunctionDemoModel(id: 52, title: "获取充电状态", category: .batteryManagement),
            FunctionDemoModel(id: 53, title: "开启监听充电状态变化", category: .batteryManagement),

            // 设备系统设置 (61-80)
            FunctionDemoModel(id: 61, title: "设置采集周期", category: .deviceSystemSettings),
            FunctionDemoModel(id: 62, title: "读取采集周期信息", category: .deviceSystemSettings),
            FunctionDemoModel(id: 63, title: "设置蓝牙名称", category: .deviceSystemSettings),
            FunctionDemoModel(id: 64, title: "读取蓝牙名称", category: .deviceSystemSettings),
            FunctionDemoModel(id: 65, title: "一键自检", category: .deviceSystemSettings),
            FunctionDemoModel(id: 66, title: "恢复出厂设置", category: .deviceSystemSettings),
            FunctionDemoModel(id: 67, title: "设置个人信息", category: .deviceSystemSettings),
            FunctionDemoModel(id: 68, title: "读取个人信息", category: .deviceSystemSettings),

            // 主动测量-温度 (81-85)
            FunctionDemoModel(id: 81, title: "温度读取", category: .measurementTemperature),

            // 主动测量-血氧 (86-90)
            FunctionDemoModel(id: 86, title: "开始血氧测量", category: .measurementBloodOxygen),
            FunctionDemoModel(id: 87, title: "停止血氧测量", category: .measurementBloodOxygen),

            // 主动测量-心率 (91-95)
            FunctionDemoModel(id: 91, title: "开始心率测量", category: .measurementHeartRate),
            FunctionDemoModel(id: 92, title: "停止心率测量", category: .measurementHeartRate),

            // 主动测量-血压 (96-100)
            FunctionDemoModel(id: 96, title: "开始血压测量", category: .measurementBloodPressure),
            FunctionDemoModel(id: 97, title: "停止血压测量", category: .measurementBloodPressure),

            // 主动测量-血糖 (101-105)
            FunctionDemoModel(id: 101, title: "开始血糖测量", category: .measurementBloodGlucose),
            FunctionDemoModel(id: 102, title: "停止血糖测量", category: .measurementBloodGlucose),

            // 主动测量-心电功能 (106-110)
            FunctionDemoModel(id: 106, title: "开始ECG采集人体心电信号", category: .measurementECG),
            FunctionDemoModel(id: 107, title: "ECG采集模拟信号", category: .measurementECG),
            FunctionDemoModel(id: 108, title: "停止心电测量", category: .measurementECG),

            // 记步功能 (111-115)
            FunctionDemoModel(id: 111, title: "实时步数", category: .stepCount),
            FunctionDemoModel(id: 112, title: "清除步数", category: .stepCount),
            FunctionDemoModel(id: 113, title: "订阅步数变化通知（Z5I）", category: .stepCount),

            // 运动模式（351-360）
            FunctionDemoModel(id: 351, title: "运动模式-开始", category: .sportMode),
            FunctionDemoModel(id: 352, title: "运动模式-停止", category: .sportMode),
            FunctionDemoModel(id: 353, title: "运动模式-数据漏点续传", category: .sportMode),

            // 数据同步 (116-120)
            FunctionDemoModel(id: 116, title: "同步全部历史数据", category: .ringData),
            FunctionDemoModel(id: 117, title: "同步未上传历史数据", category: .ringData),
            FunctionDemoModel(id: 118, title: "删除戒指内全部历史数据", category: .ringData),

            // HID功能 (121-130)
            FunctionDemoModel(id: 121, title: "获取HID功能码", category: .hidControl),
            FunctionDemoModel(id: 122, title: "获取当前HID模式", category: .hidControl),
            FunctionDemoModel(id: 129, title: "手势功能开启(Z4I定制)", category: .hidControl),
            FunctionDemoModel(id: 130, title: "手势功能配置读取(Z4I定制)", category: .hidControl),
            FunctionDemoModel(id: 128, title: "刷新蓝牙服务相关信息(Z4I定制)", category: .hidControl),
            FunctionDemoModel(id: 127, title: "手动临时断开连接(Z4I定制)", category: .hidControl),
            FunctionDemoModel(id: 126, title: getHIDServiceSubscriptionTitle(), category: .hidControl),

            // 网络相关API功能 (201-300)
            FunctionDemoModel(id: 201, title: "切换服务器-国内", category: .sdkNetwork, requiresConnection: false),
            FunctionDemoModel(id: 202, title: "切换服务器-海外", category: .sdkNetwork, requiresConnection: false),
            FunctionDemoModel(id: 203, title: "获取Token", category: .sdkNetwork, requiresConnection: false),
            FunctionDemoModel(id: 204, title: "刷新Token", category: .sdkNetwork, requiresConnection: false),
            FunctionDemoModel(id: 205, title: "提交历史数据到云端", category: .sdkNetwork),
            FunctionDemoModel(id: 206, title: "提交波形数据，获取血压结果", category: .sdkNetwork, requiresConnection: false),
            FunctionDemoModel(id: 207, title: "提交波形数据，获取血糖结果", category: .sdkNetwork, requiresConnection: false),
            FunctionDemoModel(id: 208, title: "固件版本更新检查", category: .sdkNetwork, requiresConnection: false),
            FunctionDemoModel(id: 209, title: "查询固件版本历史列表", category: .sdkNetwork, requiresConnection: false),
            FunctionDemoModel(id: 210, title: "下载特定固件文件", category: .sdkNetwork, requiresConnection: false),
            FunctionDemoModel(id: 211, title: "时间线数据", category: .sdkNetwork, requiresConnection: false),
            FunctionDemoModel(id: 212, title: "获取用户最新一条历史数据", category: .sdkNetwork, requiresConnection: false),
            
            // 六轴传感器数据 (301-320)
            FunctionDemoModel(id: 301, title: "设置六轴传感器工作频率", category: .sixAxisProtocol),
            FunctionDemoModel(id: 302, title: "获取六轴传感器工作频率", category: .sixAxisProtocol),
            FunctionDemoModel(id: 303, title: "获取六轴传感器-加速度数据(单次)", category: .sixAxisProtocol),
            FunctionDemoModel(id: 304, title: "获取六轴传感器-陀螺仪数据(单次)", category: .sixAxisProtocol),
            FunctionDemoModel(id: 305, title: "获取六轴传感器-加速度和陀螺仪数据(单次)", category: .sixAxisProtocol),
            FunctionDemoModel(id: 306, title: "获取六轴传感器-加速度数据(开启后一直上传直至接收到停止指令)", category: .sixAxisProtocol),
            FunctionDemoModel(id: 307, title: "获取六轴传感器-加速度和陀螺仪数据(开启后一直上传直至接收到停止指令)", category: .sixAxisProtocol),
            FunctionDemoModel(id: 308, title: "停止六轴传感器数据上传", category: .sixAxisProtocol),
            FunctionDemoModel(id: 309, title: "设置六轴传感器省电模式", category: .sixAxisProtocol),

            // 十米游戏：六轴、三轴协议功能模块 (321-325)
            FunctionDemoModel(id: 321, title: "十米游戏-六轴开始", category: .tenMeterSixAxisThreeAxisProtocol),
            FunctionDemoModel(id: 322, title: "十米游戏-三轴开始", category: .tenMeterSixAxisThreeAxisProtocol),
            FunctionDemoModel(id: 323, title: "十米游戏-停止", category: .tenMeterSixAxisThreeAxisProtocol),
            FunctionDemoModel(id: 324, title: "十米游戏-加速度计校准", category: .tenMeterSixAxisThreeAxisProtocol),

            // 闹钟配置（326-330）
            FunctionDemoModel(id: 326, title: "设置闹钟", category: .alarmSettings),
            FunctionDemoModel(id: 327, title: "读取闹钟配置", category: .alarmSettings),
            FunctionDemoModel(id: 328, title: "设置节假日日期-闹钟", category: .alarmSettings),
            FunctionDemoModel(id: 329, title: "读取节假日日期-闹钟", category: .alarmSettings),

            // 马达震动（331-340）
            FunctionDemoModel(id: 331, title: "马达震动-立刻", category: .vibrationMotor),
            FunctionDemoModel(id: 332, title: "马达震动-延迟", category: .vibrationMotor),

            // 固件升级（341-350）
            FunctionDemoModel(id: 341, title: "Apollo固件升级", category: .firmwareUpgrade),
            FunctionDemoModel(id: 342, title: "Nordic固件升级", category: .firmwareUpgrade),
            FunctionDemoModel(id: 343, title: "Phy固件升级", category: .firmwareUpgrade),
            FunctionDemoModel(id: 344, title: "Phy Boot Mode固件升级", category: .firmwareUpgrade),
//            FunctionDemoModel(id: 345, title: "PhyBootMode测试升级", category: .firmwareUpgrade, requiresConnection: false),
            FunctionDemoModel(id: 345, title: "获取固件升级类型", category: .firmwareUpgrade, requiresConnection: false),

            // 音频功能（361-380）
            FunctionDemoModel(id: 361, title: "开始音频传输-pcm格式", category: .audioTransmission),
            FunctionDemoModel(id: 362, title: "停止音频传输-pcm格式", category: .audioTransmission),
            FunctionDemoModel(id: 363, title: "开始音频传输-adpcm格式", category: .audioTransmission),
            FunctionDemoModel(id: 364, title: "停止音频传输-adpcm格式", category: .audioTransmission),
            FunctionDemoModel(id: 365, title: "配置主动推送音频格式", category: .audioTransmission),
            FunctionDemoModel(id: 366, title: "获取主动推送音频数据", category: .audioTransmission),
            FunctionDemoModel(id: 367, title: "开始录音（Z5J定制）", category: .audioTransmission),
            FunctionDemoModel(id: 368, title: "结束录音（Z5J定制）", category: .audioTransmission),
            FunctionDemoModel(id: 369, title: "立体双声道解码-adpcm格式（Z5J定制）", category: .audioTransmission),
            FunctionDemoModel(id: 370, title: "单声道解码-adpcm格式（Z5J定制）", category: .audioTransmission),

            // 文件系统（381-400）
            FunctionDemoModel(id: 381, title: "获取文件系统空间信息", category: .fileSystem),
            FunctionDemoModel(id: 382, title: "获取文件系统状态", category: .fileSystem),
            FunctionDemoModel(id: 383, title: "格式化文件系统", category: .fileSystem),
            FunctionDemoModel(id: 384, title: "获取文件列表", category: .fileSystem),
            FunctionDemoModel(id: 385, title: "获取指定文件数据", category: .fileSystem),
            FunctionDemoModel(id: 386, title: "删除指定文件数据", category: .fileSystem),
            FunctionDemoModel(id: 387, title: "获取全部文件数据", category: .fileSystem),

            // 睡眠数据获取（401-420）
            FunctionDemoModel(id: 401, title: "查询指定日期下的详细睡眠数据", category: .sleepData, requiresConnection: false),
            FunctionDemoModel(id: 402, title: "查询指定时间范围的睡眠数据", category: .sleepData, requiresConnection: false),
            
            // GoMore功能（421-450）
            FunctionDemoModel(id: 421, title: "查询GoMore授权状态", category: .goMoreFunction),
            FunctionDemoModel(id: 422, title: "下发GoMore授权PKey", category: .goMoreFunction),
            FunctionDemoModel(id: 423, title: "设置GoMore个人信息", category: .goMoreFunction),
            FunctionDemoModel(id: 424, title: "获取GoMore个人信息", category: .goMoreFunction),
            FunctionDemoModel(id: 425, title: "读取戒指中GoMore睡眠数据", category: .goMoreFunction),
            FunctionDemoModel(id: 426, title: "提交GoMore睡眠数据", category: .goMoreFunction),
            FunctionDemoModel(id: 427, title: "查询指定日期的GoMore睡眠数据详情", category: .goMoreFunction, requiresConnection: false),
            FunctionDemoModel(id: 428, title: "查询指定时间范围的GoMore睡眠数据", category: .goMoreFunction, requiresConnection: false),
            FunctionDemoModel(id: 429, title: "获取Gomore授权PKey", category: .goMoreFunction, requiresConnection: false),
            FunctionDemoModel(id: 430, title: "保存Gomore授权设备信息", category: .goMoreFunction, requiresConnection: false),
            FunctionDemoModel(id: 431, title: "通过服务端查询Gomore授权状态", category: .goMoreFunction, requiresConnection: false),
            FunctionDemoModel(id: 432, title: "Gomore授权状态检查并自动授权处理", category: .goMoreFunction),

            // 自定义指令 (1001-1100)
            FunctionDemoModel(id: 1001, title: "发送自定义指令（开启）", category: .customCommand),
            FunctionDemoModel(id: 1002, title: "发送自定义指令（结束）", category: .customCommand),
            FunctionDemoModel(id: 1003, title: "分享Log日志", category: .customCommand, requiresConnection: false),

            // 测试功能，需要调整。
//            FunctionDemoModel(id: 202, title: "PWTT", category: .measurementBloodPressure),

//
//            // TODO: 继续添加其余功能 (142-216)
//            // 用户可以根据Main_VC.swift中的btnAction switch语句继续添加
        ]
    }
}

// MARK: - UICollectionViewDataSource

extension FunctionDemo_VC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FunctionDemoCell.reuseIdentifier,
            for: indexPath
        ) as! FunctionDemoCell

        let model = sections[indexPath.section].items[indexPath.item]
        cell.configure(with: model)

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: FunctionSectionHeader.reuseIdentifier,
                for: indexPath
            ) as! FunctionSectionHeader

            header.configure(with: sections[indexPath.section].title)
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate

extension FunctionDemo_VC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = sections[indexPath.section].items[indexPath.item]

        // 检查是否需要连接设备
        if model.requiresConnection && BCLRingManager.shared.currentConnectedDevice == nil {
            let alert = UIAlertController(
                title: "提示",
                message: "该功能需要先连接设备",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }

        // 执行功能
        executor.executeFunction(id: model.id)

        // 延迟取消选中效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}

// MARK: - FunctionSectionHeader

class FunctionSectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "FunctionSectionHeader"

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.systemGroupedBackground
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String) {
        titleLabel.text = title
    }
}
