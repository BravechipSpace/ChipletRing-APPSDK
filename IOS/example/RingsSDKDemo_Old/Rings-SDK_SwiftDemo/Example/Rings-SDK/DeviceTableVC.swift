//
//  DeviceTableVC.swift
//  Rings-SDK_Example
//
//  Created by JianDan on 2025/3/11.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import QMUIKit
import RingsSDK
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

    private var devices: [DeviceInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        devices = []
        RingManager.shared.startScan { devices in
            self.devices = devices ?? []
            self.tableView.reloadData()
        }
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

    func connectDevice(device: DeviceInfo) {
        QMUITips.showLoading("Device Connecting...", in: view)
        // connect device
        RingManager.shared.startConnect(deviceUUID: device.peripheral.identifier.uuidString) { result in
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

    func configure(with device: DeviceInfo) {
        nameLabel.text = "Name:\(device.peripheral.name ?? "Unknown")"
        //  mac address
        var macString = ""
        if let macData = device.advertisementData["kCBAdvDataManufacturerData"] as? Data, macData.count >= 8 {
            macString = String(format: "%02X:%02X:%02X:%02X:%02X:%02X", macData[7], macData[6], macData[5], macData[4], macData[3], macData[2])
        }
        macLabel.text = "Mac:\(macString)"
    }

    @objc private func connectButtonPressed() {
        connectButtonTapped?()
    }
}
