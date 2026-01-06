//
//  GoMorePKeyConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by Claude on 2025/12/15.
//  GoMore PKey授权密钥输入对话框

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class GoMorePKeyConfig_Dialog: UIView {
    /// 确认回调，传入64字节PKey字符串（已验证）
    var confirmButtonCallback: ((_ pKey: String) -> Void)?

    // 常量配置
    private let pKeyLength = 64 // SDK要求64个字符
    private let accentColor = UIColor(red: 66 / 255.0, green: 133 / 255.0, blue: 244 / 255.0, alpha: 1)

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
        // 强制使用浅色模式，避免暗黑模式下显示问题
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        layer.cornerRadius = 15
        layer.masksToBounds = true
        backgroundColor = .white

        addSubview(titleLabel)
        addSubview(placeholderLabel)
        addSubview(pKeyTextField)
        addSubview(charCountLabel)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(18)
        }

        pKeyTextField.snp.makeConstraints { make in
            make.top.equalTo(placeholderLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(100)
        }

        charCountLabel.snp.makeConstraints { make in
            make.top.equalTo(pKeyTextField.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(charCountLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(confirmButton.snp.left).offset(-12)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-16)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(charCountLabel.snp.bottom).offset(20)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    // MARK: - Lazy Properties

    /// 标题标签
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "输入GoMore授权PKey"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    /// 说明标签
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "输入64字符授权密钥"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        return label
    }()

    /// PKey输入框
    private lazy var pKeyTextField: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.clipsToBounds = true
        textView.delegate = self
        textView.isScrollEnabled = true
        return textView
    }()

    /// 字符计数标签
    private lazy var charCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / \(pKeyLength)"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    /// 取消按钮
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    /// 确认按钮
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("确认", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = accentColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Button Actions

    @objc private func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func confirmButtonTapped() {
        guard let pKey = pKeyTextField.text?.trimmingCharacters(in: .whitespaces) else {
            showErrorAlert("PKey为空", message: "请输入有效的授权密钥")
            return
        }

        // 移除空格
        let pKeyClean = pKey.replacingOccurrences(of: " ", with: "")

        // 验证不为空
        if pKeyClean.isEmpty {
            showErrorAlert("PKey为空", message: "请输入有效的授权密钥")
            return
        }

        // 验证长度必须为64个字符
        if pKeyClean.count != pKeyLength {
            showErrorAlert("长度错误", message: "PKey必须为64个字符，当前长度: \(pKeyClean.count)")
            return
        }

        BDLogger.info("下发GoMore PKey: \(pKeyClean)")
        confirmButtonCallback?(pKeyClean)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    // MARK: - Helper Methods

    /// 显示错误提示
    private func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))

        if let viewController = window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
}

// MARK: - UITextViewDelegate

extension GoMorePKeyConfig_Dialog: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // 更新字符计数
        DispatchQueue.main.async { [weak self] in
            let cleanText = updatedText.replacingOccurrences(of: " ", with: "")
            self?.charCountLabel.text = "\(cleanText.count) / \(self?.pKeyLength ?? 128)"
        }

        return true
    }
}
