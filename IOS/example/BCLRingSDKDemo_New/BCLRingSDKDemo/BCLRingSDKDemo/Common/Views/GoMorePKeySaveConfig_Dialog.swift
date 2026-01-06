//
//  GoMorePKeySaveConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by Codex on 2025/12/20.
//  GoMore设备信息保存参数配置对话框
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class GoMorePKeySaveConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ companyApiKey: String, _ deviceId: String, _ mac: String, _ pkey: String) -> Void)?

    private let defaultCompanyApiKey = "76d07e37bfe341b1a25c76c0e25f457a"

    // MARK: - Initialization

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

    // MARK: - UI Setup

    private func setupUI() {
        layer.cornerRadius = 15
        layer.masksToBounds = true
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(companyApiKeyLabel)
        addSubview(companyApiKeyTextField)
        addSubview(deviceIdLabel)
        addSubview(deviceIdTextField)
        addSubview(macLabel)
        addSubview(macTextField)
        addSubview(pkeyLabel)
        addSubview(pkeyTextField)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        companyApiKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        companyApiKeyTextField.snp.makeConstraints { make in
            make.top.equalTo(companyApiKeyLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        deviceIdLabel.snp.makeConstraints { make in
            make.top.equalTo(companyApiKeyTextField.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        deviceIdTextField.snp.makeConstraints { make in
            make.top.equalTo(deviceIdLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        macLabel.snp.makeConstraints { make in
            make.top.equalTo(deviceIdTextField.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        macTextField.snp.makeConstraints { make in
            make.top.equalTo(macLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        pkeyLabel.snp.makeConstraints { make in
            make.top.equalTo(macTextField.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        pkeyTextField.snp.makeConstraints { make in
            make.top.equalTo(pkeyLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(pkeyTextField.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(pkeyTextField.snp.bottom).offset(24)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    private func setupDefaultValues() {
        companyApiKeyTextField.text = defaultCompanyApiKey
    }

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "保存GoMore授权设备信息"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private lazy var companyApiKeyLabel: UILabel = {
        let label = UILabel()
        label.text = "Company API Key:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var companyApiKeyTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入companyApiKey"
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

    private lazy var deviceIdLabel: UILabel = {
        let label = UILabel()
        label.text = "Device ID:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var deviceIdTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入deviceId"
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

    private lazy var macLabel: UILabel = {
        let label = UILabel()
        label.text = "MAC:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var macTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入MAC地址"
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

    private lazy var pkeyLabel: UILabel = {
        let label = UILabel()
        label.text = "PKey:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var pkeyTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入PKey"
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

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray.withAlphaComponent(0.5)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("确认", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Actions

    @objc private func confirmButtonTapped() {
        let companyApiKey = companyApiKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let deviceId = deviceIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mac = macTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pkey = pkeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !companyApiKey.isEmpty else {
            showError("companyApiKey不能为空")
            return
        }

        guard !deviceId.isEmpty else {
            showError("deviceId不能为空")
            return
        }

        guard !mac.isEmpty else {
            showError("mac不能为空")
            return
        }

        guard !pkey.isEmpty else {
            showError("pkey不能为空")
            return
        }

        BDLogger.info("保存GoMore设备信息参数 - companyApiKey: \(companyApiKey), deviceId: \(deviceId), mac: \(mac), pkey: \(pkey)")
        confirmButtonCallback?(companyApiKey, deviceId, mac, pkey)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    // MARK: - Helpers

    private func showError(_ message: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            QMUITips.show(withText: message, in: window, hideAfterDelay: 2.0)
        }
    }
}
