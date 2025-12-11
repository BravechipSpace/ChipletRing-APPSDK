//
//  SceneDemo_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  场景示例页 - 展示特定业务场景的完整流程
//

import UIKit
import SnapKit
import BCLRingSDK
import QMUIKit

/// 场景类型
enum ScenarioType: String, CaseIterable {
    case deviceBinding = "设备首次绑定流程"
    case deviceContent = "设备连接流程"
    case deviceRefresh = "刷新数据流程"
    case dataSync = "数据同步流程"
    case firmwareUpgrade = "固件升级流程"

    var description: String {
        switch self {
        case .deviceBinding:
            return "设备首次绑定流程：扫描蓝牙 → 连接指定设备 → 复合指令-绑定指令 → 更新蓝牙设备信息到UI"
        case .deviceContent:
            return "设备连接流程：通过Mac地址连接蓝牙设备 → 复合指令-连接指令 → 更新蓝牙信息到UI上 → 接收蓝牙推送的历史数据"
        case .deviceRefresh:
            return "刷新数据流程：复合指令-刷新指令 → 更新蓝牙信息到UI上 → 接收蓝牙推送的历史数据"
        case .dataSync:
            return "数据同步流程：检查连接 → 获取服务端用户最后一条历史数据的时间 -> 读取蓝牙历史数据 -> 将此次同步的数据打包上传到服务端"
        case .firmwareUpgrade:
            return "固件升级流程：检查版本 → 下载固件 → 检查升级类型 → 根据类型执行升级"
        }
    }
}

class SceneDemo_VC: UIViewController {

    // MARK: - Properties

    private var scenarios: [ScenarioType] = ScenarioType.allCases

    /// TableView
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.delegate = self
        tv.dataSource = self
        tv.register(ScenarioCell.self, forCellReuseIdentifier: ScenarioCell.reuseIdentifier)
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        title = "场景示例"
        view.backgroundColor = UIColor.systemGroupedBackground

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Scenario Execution

    /// 执行场景流程
    private func executeScenario(_ scenario: ScenarioType) {
        BDLogger.info("开始执行场景: \(scenario.rawValue)")

        switch scenario {
        case .deviceBinding:
            executeDeviceBindingScenario()
        case .deviceContent:
            executeDeviceContentScenario()
        case .deviceRefresh:
            executeDeviceRefreshScenario()
        case .dataSync:
            executeDataSyncScenario()
        case .firmwareUpgrade:
            executeFirmwareUpgradeScenario()
        }
    }

    // MARK: - Scenario Implementations

    /// 1. 设备绑定流程
    private func executeDeviceBindingScenario() {
        // 打开设备列表
        let deviceTableVC = DeviceTableVC()
        navigationController?.pushViewController(deviceTableVC, animated: true)

        // 提示后续流程
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let alert = UIAlertController(
                title: "设备绑定流程",
                message: "1. 选择设备进行连接\n2. 连接成功后自动同步时间\n3. 设置采集周期\n4. 完成绑定",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "知道了", style: .default))
            deviceTableVC.present(alert, animated: true)
        }
    }

    /// 2. 设备连接流程
    private func executeDeviceContentScenario() {
        
    }

    /// 执行复合指令-连接指令
    private func executeConnectCompositeCommand(_ deviceInfo: BCLDeviceInfoModel) {
    
    }

    /// 3. 刷新数据流程
    private func executeDeviceRefreshScenario() {
        
    }

    /// 4. 数据同步流程
    private func executeDataSyncScenario() {
        
    }

    /// 5. 固件升级流程
    private func executeFirmwareUpgradeScenario() {
        
    }

    // MARK: - Helper Methods

    private func showLoading(_ message: String) {
        QMUITips.showLoading(message, in: view)
    }

    private func hideLoading() {
        QMUITips.hideAllTips(in: view)
    }

    private func showSuccess(_ message: String) {
        QMUITips.showSucceed(message, in: view)
    }

    private func showError(_ message: String) {
        QMUITips.showError(message, in: view)
    }
}

// MARK: - UITableViewDataSource

extension SceneDemo_VC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenarios.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ScenarioCell.reuseIdentifier,
            for: indexPath
        ) as! ScenarioCell

        let scenario = scenarios[indexPath.row]
        cell.configure(with: scenario)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SceneDemo_VC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let scenario = scenarios[indexPath.row]
        executeScenario(scenario)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - ScenarioCell

class ScenarioCell: UITableViewCell {

    static let reuseIdentifier = "ScenarioCell"

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.label
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        accessoryType = .disclosureIndicator

        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-40)
            make.top.equalToSuperview().offset(12)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }

    func configure(with scenario: ScenarioType) {
        titleLabel.text = scenario.rawValue
        descriptionLabel.text = scenario.description

        // 设置图标
        let iconName: String
        switch scenario {
        case .deviceBinding:
            iconName = "link.circle.fill"
        case .deviceContent:
            iconName = "antenna.radiowaves.left.and.right.circle.fill"
        case .deviceRefresh:
            iconName = "arrow.clockwise.circle.fill"
        case .dataSync:
            iconName = "arrow.triangle.2.circlepath.circle.fill"
        case .firmwareUpgrade:
            iconName = "arrow.up.circle.fill"
        }
        iconImageView.image = UIImage(systemName: iconName)
    }
}
