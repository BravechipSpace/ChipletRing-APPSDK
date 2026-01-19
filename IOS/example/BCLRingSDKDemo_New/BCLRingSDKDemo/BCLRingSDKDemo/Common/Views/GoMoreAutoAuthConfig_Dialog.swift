//
//  GoMoreAutoAuthConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by Claude on 2026/01/16.
//  GoMore授权状态检查并自动授权处理参数配置对话框
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class GoMoreAutoAuthConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ companyKey: String) -> Void)?

    private let defaultCompanyKey = "76d07e37bfe341b1a25c76c0e25f457a"

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
        addSubview(descriptionLabel)
        addSubview(companyKeyLabel)
        addSubview(companyKeyTextField)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        companyKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        companyKeyTextField.snp.makeConstraints { make in
            make.top.equalTo(companyKeyLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(companyKeyTextField.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(companyKeyTextField.snp.bottom).offset(24)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    private func setupDefaultValues() {
        companyKeyTextField.text = defaultCompanyKey
    }

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "GoMore自动授权"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "自动检查授权状态，未授权时自动完成授权流程"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()

    private lazy var companyKeyLabel: UILabel = {
        let label = UILabel()
        label.text = "Company Key (公司密钥):"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var companyKeyTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入公司密钥"
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
        button.setTitle("开始授权", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Actions

    @objc private func confirmButtonTapped() {
        let companyKey = companyKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !companyKey.isEmpty else {
            showError("公司密钥不能为空")
            return
        }

        BDLogger.info("GoMore自动授权参数 - companyKey: \(companyKey)")
        confirmButtonCallback?(companyKey)
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
