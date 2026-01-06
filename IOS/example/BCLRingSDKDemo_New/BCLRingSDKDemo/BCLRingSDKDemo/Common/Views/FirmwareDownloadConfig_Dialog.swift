//
//  FirmwareDownloadConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by Claude Code on 2025/12/17.
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class FirmwareDownloadConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ url: String, _ fileName: String, _ destinationPath: String) -> Void)?

    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupDefaultValues()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        layer.cornerRadius = 15
        layer.masksToBounds = true
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(urlLabel)
        addSubview(urlTextField)
        addSubview(fileNameLabel)
        addSubview(fileNameTextField)
        addSubview(pathLabel)
        addSubview(pathTextField)
        addSubview(hintLabel)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        urlLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        urlTextField.snp.makeConstraints { make in
            make.top.equalTo(urlLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        fileNameLabel.snp.makeConstraints { make in
            make.top.equalTo(urlTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        fileNameTextField.snp.makeConstraints { make in
            make.top.equalTo(fileNameLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        pathLabel.snp.makeConstraints { make in
            make.top.equalTo(fileNameTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        pathTextField.snp.makeConstraints { make in
            make.top.equalTo(pathLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(pathTextField.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    func setupDefaultValues() {
        // 设置默认保存路径为Documents目录
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        pathTextField.text = documentsPath
    }

    // MARK: - Lazy Properties

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "下载特定固件文件"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.text = "固件下载地址:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var urlTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入固件下载URL"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.text = "固件文件名:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var fileNameTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入固件文件名 (如: firmware.bin)"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    lazy var pathLabel: UILabel = {
        let label = UILabel()
        label.text = "保存路径:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var pathTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入保存路径"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "默认保存到Documents目录"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray.withAlphaComponent(0.5)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("开始下载", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc func confirmButtonTapped() {
        guard let url = urlTextField.text, !url.isEmpty else {
            BDLogger.error("固件下载地址不能为空")
            return
        }

        guard let fileName = fileNameTextField.text, !fileName.isEmpty else {
            BDLogger.error("固件文件名不能为空")
            return
        }

        guard let path = pathTextField.text, !path.isEmpty else {
            BDLogger.error("保存路径不能为空")
            return
        }

        BDLogger.info("固件下载配置 - URL:\(url), 文件名:\(fileName), 保存路径:\(path)")
        confirmButtonCallback?(url, fileName, path)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
