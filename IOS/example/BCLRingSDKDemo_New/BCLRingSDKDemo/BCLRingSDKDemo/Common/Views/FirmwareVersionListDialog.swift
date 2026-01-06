//
//  FirmwareVersionListDialog.swift
//  BCLRingSDKDemo
//
//  Created by Claude Code on 2025/12/17.
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

// MARK: - 固件版本列表对话框

class FirmwareVersionListDialog: UIView {
    private var versionList: [FirmwareVersionItem] = []

    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, versions: [FirmwareVersionItem]) {
        self.init(frame: CGRect(x: x, y: y, width: width, height: height))
        self.versionList = versions
        tableView.reloadData()
        updateCountLabel()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        // 强制使用浅色模式，禁止跟随系统暗黑模式
        overrideUserInterfaceStyle = .light
        layer.cornerRadius = 15
        layer.masksToBounds = true
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(countLabel)
        addSubview(tableView)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }

        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
        }

        countLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }

    private func updateCountLabel() {
        countLabel.text = "共 \(versionList.count) 个版本"
    }

    // MARK: - Lazy Properties

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "固件版本历史列表"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = "共 0 个版本"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.register(FirmwareVersionCell.self, forCellReuseIdentifier: "FirmwareVersionCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .white
        return tableView
    }()

    // MARK: - Actions

    @objc func closeButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension FirmwareVersionListDialog: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return versionList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirmwareVersionCell", for: indexPath) as! FirmwareVersionCell
        let version = versionList[indexPath.row]
        cell.configure(with: version, index: indexPath.row + 1)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - 固件版本单元格

class FirmwareVersionCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // 固定背景色，禁止跟随系统暗黑模式
        backgroundColor = .white
        contentView.backgroundColor = .white
        contentView.addSubview(indexLabel)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(filePathLabel)
        contentView.addSubview(fileUrlLabel)
    }

    private func setupConstraints() {
        indexLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(30)
        }

        fileNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(indexLabel.snp.right).offset(8)
            make.right.equalToSuperview().offset(-15)
        }

        filePathLabel.snp.makeConstraints { make in
            make.top.equalTo(fileNameLabel.snp.bottom).offset(6)
            make.left.equalTo(fileNameLabel)
            make.right.equalToSuperview().offset(-15)
        }

        fileUrlLabel.snp.makeConstraints { make in
            make.top.equalTo(filePathLabel.snp.bottom).offset(6)
            make.left.equalTo(fileNameLabel)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    // MARK: - UI Components

    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .blue
        label.textAlignment = .center
        return label
    }()

    private lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()

    private lazy var filePathLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()

    private lazy var fileUrlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .systemBlue
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    // MARK: - Configuration

    func configure(with version: FirmwareVersionItem, index: Int) {
        indexLabel.text = "\(index)"
        fileNameLabel.text = "文件名: \(version.fileName)"
        filePathLabel.text = "路径: \(version.filePath)"
        fileUrlLabel.text = "下载: \(version.fileUrl)"
    }
}
