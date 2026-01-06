//
//  CustomCommandDialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/12/15.
//  自定义指令输入对话框 - 允许用户输入十六进制指令

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class CustomCommandDialog: UIView {
    /// 确认回调，传入十六进制指令字符串（已验证）
    var confirmButtonCallback: ((_ hexCommand: String) -> Void)?

    // 常量配置
    private let maxHexLength = 512 // 最多512个十六进制字符 = 256字节
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
        addSubview(commandTextField)
        addSubview(charCountLabel)
        addSubview(cancelButton)
        addSubview(sendButton)
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

        commandTextField.snp.makeConstraints { make in
            make.top.equalTo(placeholderLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(100)
        }

        charCountLabel.snp.makeConstraints { make in
            make.top.equalTo(commandTextField.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(charCountLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(sendButton.snp.left).offset(-12)
            make.height.equalTo(44)
            make.width.equalTo(sendButton.snp.width)
            make.bottom.equalToSuperview().offset(-16)
        }

        sendButton.snp.makeConstraints { make in
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
        label.text = "输入自定义指令"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    /// 说明标签
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "输入十六进制指令（仅 0-9, A-F，最多 512 字符）"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        return label
    }()

    /// 指令输入框
    private lazy var commandTextField: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.clipsToBounds = true
        textView.delegate = self
        // 支持多行输入，便于复制粘贴长指令
        textView.isScrollEnabled = true
        return textView
    }()

    /// 字符计数标签
    private lazy var charCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / \(maxHexLength)"
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

    /// 发送按钮
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("发送", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = accentColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Button Actions

    @objc private func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func sendButtonTapped() {
        guard let hexCommand = commandTextField.text?.trimmingCharacters(in: .whitespaces) else {
            showErrorAlert("指令为空", message: "请输入有效的十六进制指令")
            return
        }

        // 验证不为空
        if hexCommand.isEmpty {
            showErrorAlert("指令为空", message: "请输入有效的十六进制指令")
            return
        }

        // 验证长度不超过限制
        if hexCommand.count > maxHexLength {
            showErrorAlert("指令过长", message: "指令最长 \(maxHexLength) 个字符（\(maxHexLength / 2) 字节）")
            return
        }

        // 验证十六进制格式（仅允许 0-9, A-F, a-f，忽略空格）
        let hexOnlyCommand = hexCommand.replacingOccurrences(of: " ", with: "")
        if !isValidHexadecimal(hexOnlyCommand) {
            showErrorAlert("格式错误", message: "仅允许十六进制字符（0-9, A-F），不能包含其他字符")
            return
        }

        // 验证字符数必须为偶数（每两个十六进制字符代表一个字节）
        if hexOnlyCommand.count % 2 != 0 {
            showErrorAlert("格式错误", message: "十六进制指令必须是偶数个字符")
            return
        }

        BDLogger.info("发送自定义指令: \(hexOnlyCommand)")
        confirmButtonCallback?(hexOnlyCommand)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    // MARK: - Helper Methods

    /// 检查是否为有效的十六进制字符串
    private func isValidHexadecimal(_ string: String) -> Bool {
        let hexPattern = "^[0-9A-Fa-f]*$"
        let regex = try? NSRegularExpression(pattern: hexPattern)
        let range = NSRange(string.startIndex..<string.endIndex, in: string)
        return regex?.firstMatch(in: string, range: range) != nil
    }

    /// 显示错误提示
    private func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))

        // 获取当前的UIViewController来显示alert
        if let viewController = window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
}

// MARK: - UITextViewDelegate

extension CustomCommandDialog: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 限制最大长度
        let currentText = textView.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // 更新字符计数
        DispatchQueue.main.async { [weak self] in
            self?.charCountLabel.text = "\(updatedText.count) / \(self?.maxHexLength ?? 512)"
        }

        // 如果超过限制，返回false不允许输入
        if updatedText.count > maxHexLength {
            return false
        }

        return true
    }
}
