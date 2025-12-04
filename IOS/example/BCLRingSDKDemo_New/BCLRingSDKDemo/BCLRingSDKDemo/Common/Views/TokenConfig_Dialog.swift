//
//  TokenConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/25.
//

import BCLRingSDK
import QMUIKit
import RxSwift
import SnapKit
import UIKit

class TokenConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ apiKey: String, _ userIdentifier: String) -> Void)?
    let disposeBag = DisposeBag()

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
        addSubview(apiKeyLabel)
        addSubview(apiKeyTextField)
        addSubview(userIdentifierLabel)
        addSubview(userIdentifierTextField)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        // API Key - 垂直布局
        apiKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        apiKeyTextField.snp.makeConstraints { make in
            make.top.equalTo(apiKeyLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        // 用户标识符 - 垂直布局
        userIdentifierLabel.snp.makeConstraints { make in
            make.top.equalTo(apiKeyTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        userIdentifierTextField.snp.makeConstraints { make in
            make.top.equalTo(userIdentifierLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        // 按钮
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(userIdentifierTextField.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(userIdentifierTextField.snp.bottom).offset(30)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    func setupDefaultValues() {
        // 设置默认值
        apiKeyTextField.text = "76d07e37bfe341b1a25c76c0e25f457a"
        userIdentifierTextField.text = "jiandan@qq.com"
    }

    // MARK: - 懒加载

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Token参数配置"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var apiKeyLabel: UILabel = {
        let label = UILabel()
        label.text = "API Key:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var apiKeyTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入API Key"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return textField
    }()

    lazy var userIdentifierLabel: UILabel = {
        let label = UILabel()
        label.text = "用户标识符:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var userIdentifierTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入用户标识符"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.keyboardType = .emailAddress
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return textField
    }()

    // 取消按钮
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

    // 确认按钮
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("确认", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc func confirmButtonTapped() {
        guard let apiKey = apiKeyTextField.text, !apiKey.isEmpty else {
            BDLogger.error("API Key不能为空")
            return
        }

        guard let userIdentifier = userIdentifierTextField.text, !userIdentifier.isEmpty else {
            BDLogger.error("用户标识符不能为空")
            return
        }

        BDLogger.info("Token配置 - API Key:\(apiKey), 用户标识符:\(userIdentifier)")
        confirmButtonCallback?(apiKey, userIdentifier)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
