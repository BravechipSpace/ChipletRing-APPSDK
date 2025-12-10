//
//  DeviceTable_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/3/18.
//

import BCLRingSDK
import QMUIKit
import UIKit

class DeviceTableVC: UIViewController {
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(DeviceTableViewCell.self, forCellReuseIdentifier: "DeviceCell")
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        return table
    }()

    private var devices: [BCLDeviceInfoModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        devices = []
        BCLRingManager.shared.startScan { res in
            switch res {
            case let .success(devices):
                self.devices = devices
                self.tableView.reloadData()
            case let .failure(error):
                BDLogger.error("scan failed: \(error)")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BCLRingManager.shared.stopScan()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func connectDevice(device: BCLDeviceInfoModel) {
        if device.isPhyBootMode {
            BDLogger.info("设备处于PHY引导模式，无法连接")
            BDLogger.info("连接设备的UUID：\(device.peripheral.identifier.uuidString)")
//            BCLRingManager.shared.connectPhyBootModeDevice(device: device, firmwareVersion: "2.7.5.0Z3N", isAutoReconnect: false, autoReconnectTimeLimit: 0, autoReconnectMaxAttempts: 0, progressHandler: { progress in
//                BDLogger.info("升级进度：\(progress)")
//            }, upgradeCompletion: { res in
//                switch res {
//                case let .success(state):
//                    switch state {
//                    case .preparing:
//                        BDLogger.info("phy固件boot模式中断重新升级结果：升级准备中")
//                    case .preparingToBootMode:
//                        BDLogger.info("phy固件boot模式中断重新升级结果：准备进入boot模式")
//                    case .bootModeDisconnected:
//                        BDLogger.info("phy固件boot模式中断重新升级结果：boot模式连接断开")
//                    case .bootModeConnected:
//                        BDLogger.info("phy固件boot模式中断重新升级结果：boot模式连接成功")
//                    case .preparingToAppMode:
//                        BDLogger.info("phy固件boot模式中断重新升级结果：准备进入app模式")
//                    case .appModeDisconnected:
//                        BDLogger.info("phy固件boot模式中断重新升级结果：app模式连接断开")
//                    case .appModeConnected:
//                        BDLogger.info("phy固件boot模式中断重新升级结果：app模式连接成功")
//                    case .upgrading:
//                        BDLogger.info("phy固件boot模式中断重新升级结果：升级中")
//                    case let .failed(error):
//                        BDLogger.error("phy固件boot模式中断重新升级结果：升级失败：\(error)")
//                    case .success:
//                        BDLogger.info("phy固件boot模式中断重新升级结果：升级成功")
//                    }
//                    break
//                case let .failure(error):
//                    BDLogger.error("升级失败：\(error)")
//                    break
//                }
//            }, connectResultBlock: { res in
//                switch res {
//                case let .success(deviceInfo):
//                    BDLogger.info("连接成功：\(deviceInfo)")
//                    break
//                case let .failure(error):
//                    BDLogger.error("连接失败：\(error)")
//                }
//            })
//            BCLRingManager.shared.connectPhyBootModeDevice(macAddress: device.macAddress ?? "", isAutoReconnect: false, autoReconnectTimeLimit: 0, autoReconnectMaxAttempts: 0) { result in
//                switch result {
//                case .success:
//                    BDLogger.info("connect success")
//                    QMUITips.hideAllTips(in: self.view)
//                    self.navigationController?.popViewController(animated: true)
//                case let .failure(error):
//                    BDLogger.error("connect failed: \(error)")
//                    QMUITips.hideAllTips(in: self.view)
//                    QMUITips.showError("Connect Failed", in: self.view)
//                }
//            }
        } else {
            QMUITips.showLoading("Device Connecting...", in: view)
            BDLogger.info("连接设备的UUID：\(device.peripheral.identifier.uuidString)")
            BCLRingManager.shared.startConnect(uuidString: device.peripheral.identifier.uuidString, isAutoReconnect: true, autoReconnectTimeLimit: 600, autoReconnectMaxAttempts: 20) { result in
                switch result {
                case .success:
                    BDLogger.info("connect success")
                    QMUITips.hideAllTips(in: self.view)

                    // 保存设备信息到 UserDefaults
                    let connectedDevice = BCLRingManager.shared.currentConnectedDevice
                    let macAddress = connectedDevice?.macAddress
                    let peripheralName = connectedDevice?.peripheralName

                    BDLogger.info("准备保存设备信息 - MAC: \(macAddress ?? "nil"), 设备名: \(peripheralName ?? "nil")")

                    UserDefaults.standard.set(macAddress, forKey: "ring_macAddress")
                    UserDefaults.standard.set(peripheralName, forKey: "ring_peripheralName")
                    UserDefaults.standard.synchronize()

                    BDLogger.info("设备信息已保存到 UserDefaults")

                    self.navigationController?.popViewController(animated: true)
                case let .failure(error):
                    BDLogger.error("connect failed: \(error)")
                    QMUITips.hideAllTips(in: self.view)
                    QMUITips.showError("Connect Failed", in: self.view)
                }
            }
        }
        
//        QMUITips.showLoading("Device Connecting...", in: view)
//        BDLogger.info("连接设备的UUID：\(device.peripheral.identifier.uuidString)")
//        BCLRingManager.shared.startConnect(uuidString: device.peripheral.identifier.uuidString, isAutoReconnect: true, autoReconnectTimeLimit: 300, autoReconnectMaxAttempts: 10) { result in
//            switch result {
//            case .success:
//                BDLogger.info("connect success")
//                QMUITips.hideAllTips(in: self.view)
//                self.navigationController?.popViewController(animated: true)
//            case let .failure(error):
//                BDLogger.error("connect failed: \(error)")
//                QMUITips.hideAllTips(in: self.view)
//                QMUITips.showError("Connect Failed", in: self.view)
//            }
//        }
    }
}

// MARK: - UITableView DataSource & Delegate

extension DeviceTableVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceTableViewCell
        let device = devices[indexPath.row]
        cell.configure(with: device)
        cell.connectButtonTapped = { [weak self] in
            self?.connectDevice(device: device)
        }
        return cell
    }
}

// MARK: - DeviceTableViewCell

class DeviceTableViewCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 8
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let macLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    private let rssiLabel: UILabel = {
        let label = UILabel()
        label.text = "RSSI：Unknown"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    private let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Connect", for: .normal)
        return button
    }()

    var connectButtonTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
        ])
        [nameLabel, macLabel, rssiLabel, connectButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            macLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            macLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            rssiLabel.topAnchor.constraint(equalTo: macLabel.bottomAnchor, constant: 5),
            rssiLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            rssiLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            connectButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            connectButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            connectButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            connectButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            connectButton.widthAnchor.constraint(equalToConstant: 60),
        ])

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
    }

    func configure(with device: BCLDeviceInfoModel) {
        nameLabel.text = "Name:\(device.peripheral.name ?? "Unknown")"
//        nameLabel.text = "Name:\(device.localName ?? "Unknown")"
        if device.isScannedAndConnected {
            macLabel.text = "Mac:系统蓝牙已连接，无法通过广播获取Mac"
        } else {
            macLabel.text = "Mac:\(device.macAddress ?? "Unknown")"
        }
        if let rssi = device.rssi {
            rssiLabel.text = "RSSI: \(rssi)"
        } else {
            rssiLabel.text = "RSSI: Unknown"
        }
    }

    @objc private func connectButtonPressed() {
        connectButtonTapped?()
    }
}
