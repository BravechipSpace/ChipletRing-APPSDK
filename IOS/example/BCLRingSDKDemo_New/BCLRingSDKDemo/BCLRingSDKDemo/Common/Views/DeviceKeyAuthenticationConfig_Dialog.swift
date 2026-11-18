//
//  DeviceKeyAuthenticationConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  设备密钥鉴权的独立字节输入视图，不保存密钥。
//

import Foundation
import QMUIKit
import SnapKit
import UIKit

/// 严格的十六进制输入转换，不补零、不截断，不将输入文本本身作为密钥。
enum DeviceKeyAuthenticationInput {
    static func parse(_ text: String) -> Data? {
        let compact = text.filter { !$0.isWhitespace }
        let bytes = Array(compact.utf8)
        guard !bytes.isEmpty, bytes.count % 2 == 0 else { return nil }
        var data = Data()
        for offset in stride(from: 0, to: bytes.count, by: 2) {
            guard let high = nibble(bytes[offset]), let low = nibble(bytes[offset + 1]) else { return nil }
            data.append(high << 4 | low)
        }
        return data
    }

    private static func nibble(_ value: UInt8) -> UInt8? {
        switch value {
        case 48 ... 57: return value - 48
        case 65 ... 70: return value - 65 + 10
        case 97 ... 102: return value - 97 + 10
        default: return nil
        }
    }
}

/// 功能2033的输入弹窗；取消/提交后清空输入，仅通过回调传递原始字节。
class DeviceKeyAuthenticationConfig_Dialog: UIView {
    var confirmButtonCallback: ((Data) -> Void)?

    private let keyField = UITextField()
    private let errorLabel = UILabel()

    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        overrideUserInterfaceStyle = .light
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.masksToBounds = true
        let titleLabel = UILabel()
        titleLabel.text = "设备密钥鉴权"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(16)
        }

        keyField.placeholder = "输入密钥十六进制字节"
        keyField.borderStyle = .roundedRect
        keyField.isSecureTextEntry = true
        keyField.autocorrectionType = .no
        keyField.autocapitalizationType = .none
        keyField.spellCheckingType = .no
        keyField.font = .systemFont(ofSize: 15)
        keyField.accessibilityLabel = "鉴权密钥十六进制字节"
        addSubview(keyField)
        keyField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        let hint = UILabel()
        hint.text = "输入偶数个十六进制字符，可用空格分组。\n示例00 7F 80 FF仅为演示，不是设备真实密钥。"
        hint.numberOfLines = 0
        hint.font = .systemFont(ofSize: 13)
        hint.textColor = .darkGray
        addSubview(hint)
        hint.snp.makeConstraints { make in
            make.top.equalTo(keyField.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }
        errorLabel.numberOfLines = 0
        errorLabel.font = .systemFont(ofSize: 12)
        errorLabel.textColor = .systemRed
        addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(hint.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }

        let cancel = UIButton(type: .system)
        cancel.setTitle("取消", for: .normal)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        addSubview(cancel)
        let confirm = UIButton(type: .system)
        confirm.setTitle("鉴权", for: .normal)
        confirm.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        addSubview(confirm)
        cancel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.width.equalTo(confirm)
            make.right.equalTo(confirm.snp.left).offset(-16)
        }
        confirm.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.height.equalTo(cancel)
        }
    }

    // MARK: - Actions

    @objc private func confirmTapped() {
        guard let data = DeviceKeyAuthenticationInput.parse(keyField.text ?? "") else {
            errorLabel.text = "请输入非空、偶数个ASCII十六进制字符（0-9、A-F），可用空白分组。"
            return
        }
        keyField.text = nil
        endEditing(true)
        confirmButtonCallback?(data)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func cancelTapped() {
        keyField.text = nil
        endEditing(true)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
