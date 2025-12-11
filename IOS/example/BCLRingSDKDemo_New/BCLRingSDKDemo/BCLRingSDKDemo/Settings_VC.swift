//
//  Settings_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  设置页 - 提供设备管理、日志查看等辅助功能
//

import UIKit
import SnapKit
import BCLRingSDK

/// 设置项类型
enum SettingItemType {
    case deviceList
    case logViewer
    case about
    case clearCache
    case sdkVersion
    case appVersion
}

/// 设置项模型
struct SettingItem {
    let type: SettingItemType
    let title: String
    let subtitle: String?
    let icon: String
    let accessoryType: UITableViewCell.AccessoryType

    init(
        type: SettingItemType,
        title: String,
        subtitle: String? = nil,
        icon: String,
        accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator
    ) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.accessoryType = accessoryType
    }
}

class Settings_VC: UIViewController {

    // MARK: - Properties

    private var settingSections: [[SettingItem]] = []

    /// TableView
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.delegate = self
        tv.dataSource = self
        tv.register(SettingCell.self, forCellReuseIdentifier: SettingCell.reuseIdentifier)
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettingItems()
    }

    // MARK: - UI Setup

    private func setupUI() {
        title = "设置"
        view.backgroundColor = UIColor.systemGroupedBackground

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Data Loading

    private func loadSettingItems() {
//        // 获取SDK版本
//        let sdkVersion = "1.0.0" // TODO: 从SDK获取实际版本号
//
//        // 获取App版本
//        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
//        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
//
//        settingSections = [
//            // 第一组: 设备管理
//            [
//                SettingItem(
//                    type: .deviceList,
//                    title: "设备列表",
//                    subtitle: "扫描和连接蓝牙设备",
//                    icon: "antenna.radiowaves.left.and.right"
//                )
//            ],
//
//            // 第二组: 调试工具
//            [
//                SettingItem(
//                    type: .logViewer,
//                    title: "日志查看",
//                    subtitle: "查看SDK运行日志",
//                    icon: "doc.text.magnifyingglass"
//                ),
//                SettingItem(
//                    type: .clearCache,
//                    title: "清除缓存",
//                    subtitle: "清除本地缓存数据",
//                    icon: "trash",
//                    accessoryType: .none
//                )
//            ],
//
//            // 第三组: 关于信息
//            [
//                SettingItem(
//                    type: .sdkVersion,
//                    title: "SDK版本",
//                    subtitle: sdkVersion,
//                    icon: "cube.box",
//                    accessoryType: .none
//                ),
//                SettingItem(
//                    type: .appVersion,
//                    title: "应用版本",
//                    subtitle: "\(appVersion) (\(buildNumber))",
//                    icon: "app.badge",
//                    accessoryType: .none
//                ),
//                SettingItem(
//                    type: .about,
//                    title: "关于",
//                    subtitle: "BCLRingSDK Demo",
//                    icon: "info.circle"
//                )
//            ]
//        ]
        
        settingSections = []

        tableView.reloadData()
    }

    // MARK: - Actions

    private func handleSettingItemTap(_ item: SettingItem) {
        switch item.type {
        case .deviceList:
            openDeviceList()

        case .logViewer:
            openLogViewer()

        case .clearCache:
            clearCache()

        case .about:
            showAbout()

        case .sdkVersion, .appVersion:
            // 版本信息不需要响应点击
            break
        }
    }

    /// 打开设备列表
    private func openDeviceList() {
        let deviceTableVC = DeviceTableVC()
        navigationController?.pushViewController(deviceTableVC, animated: true)
    }

    /// 打开日志查看器
    private func openLogViewer() {
        let logVC = Log_VC()
        navigationController?.pushViewController(logVC, animated: true)
    }

    /// 清除缓存
    private func clearCache() {
        let alert = UIAlertController(
            title: "清除缓存",
            message: "确定要清除本地缓存数据吗?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in
            // 清除UserDefaults中的设备信息
            UserDefaults.standard.removeObject(forKey: "ring_macAddress")
            UserDefaults.standard.removeObject(forKey: "ring_peripheralName")
            UserDefaults.standard.removeObject(forKey: "ring_uuidString")
            UserDefaults.standard.synchronize()

            BDLogger.info("缓存已清除")

            let successAlert = UIAlertController(
                title: "成功",
                message: "缓存已清除",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(successAlert, animated: true)
        })

        present(alert, animated: true)
    }

    /// 显示关于信息
    private func showAbout() {
        let aboutMessage = """
        BCLRingSDK Demo

        这是一个展示BCLRingSDK功能的演示应用。

        主要功能:
        • 设备扫描和连接
        • 生理数据测量
        • 历史数据同步
        • 固件升级
        • 文件系统管理

        开发者: BCL Team
        """

        let alert = UIAlertController(
            title: "关于",
            message: aboutMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension Settings_VC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return settingSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingSections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingCell.reuseIdentifier,
            for: indexPath
        ) as! SettingCell

        let item = settingSections[indexPath.section][indexPath.row]
        cell.configure(with: item)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension Settings_VC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = settingSections[indexPath.section][indexPath.row]
        handleSettingItemTap(item)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - SettingCell

class SettingCell: UITableViewCell {

    static let reuseIdentifier = "SettingCell"

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.label
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-40)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.equalTo(titleLabel)
        }
    }

    func configure(with item: SettingItem) {
        iconImageView.image = UIImage(systemName: item.icon)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        subtitleLabel.isHidden = item.subtitle == nil
        accessoryType = item.accessoryType
    }
}
