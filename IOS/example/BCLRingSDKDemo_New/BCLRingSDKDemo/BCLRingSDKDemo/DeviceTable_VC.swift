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
        table.rowHeight = 100
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
            case .success(let devices):
                self.devices = devices
                self.tableView.reloadData()
            case .failure(let error):
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
        QMUITips.showLoading("Device Connecting...", in: view)
        
        BCLRingManager.shared.startConnect(uuidString: device.peripheral.identifier.uuidString, isAutoReconnect: true, autoReconnectTimeLimit: 300, autoReconnectMaxAttempts: 10) { result in
            switch result {
            case .success:
                BDLogger.info("connect success")
                QMUITips.hideAllTips(in: self.view)
                self.navigationController?.popViewController(animated: true)
            case let .failure(error):
                BDLogger.error("connect failed: \(error)")
                QMUITips.hideAllTips(in: self.view)
                QMUITips.showError("Connect Failed", in: self.view)
            }
        }
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
        [nameLabel, macLabel, connectButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            macLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            macLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            connectButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            connectButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            connectButton.widthAnchor.constraint(equalToConstant: 60),
        ])

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
    }

    func configure(with device: BCLDeviceInfoModel) {
        nameLabel.text = "Name:\(device.peripheral.name ?? "Unknown")"
        
        if device.isScannedAndConnected {
            macLabel.text = "Mac:系统蓝牙已连接，无法通过广播获取Mac"
        }else{
            macLabel.text = "Mac:\(device.macAddress ?? "Unknown")"
        }
    }

    @objc private func connectButtonPressed() {
        connectButtonTapped?()
    }
}
