//
//  SNCodeConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by Codex on 2026/01/29.
//  SN码配置对话框
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class SNCodeConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ snCode: String) -> Void)?

    // MARK: - Initialization

    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
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
        addSubview(snCodeLabel)
        addSubview(snCodeTextField)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        snCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        snCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(snCodeLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(snCodeTextField.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(snCodeTextField.snp.bottom).offset(24)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "设置SN码"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private lazy var snCodeLabel: UILabel = {
        let label = UILabel()
        label.text = "SN码:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var snCodeTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入SN码"
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
        let snCode = snCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !snCode.isEmpty else {
            showError("SN码不能为空")
            return
        }

        BDLogger.info("设置SN码参数 - snCode: \(snCode)")
        confirmButtonCallback?(snCode)
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
