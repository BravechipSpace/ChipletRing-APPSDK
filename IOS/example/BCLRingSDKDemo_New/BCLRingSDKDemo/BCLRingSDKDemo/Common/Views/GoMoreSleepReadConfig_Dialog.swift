//
//  GoMoreSleepReadConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  戒指蓝牙睡眠读取配置，与云端日期查询配置独立。
//

import QMUIKit
import SnapKit
import UIKit

/// 功能425：显式选择旧固件请求或1.0.2时间请求，不自动推断固件能力。
class GoMoreSleepReadConfig_Dialog: UIView {
    /// nil使用旧无参请求；0使用新版全部缓存请求；非0使用新版时间查询。
    var confirmButtonCallback: ((_ sinceTimestamp: UInt32?) -> Void)?

    private let modeControl = UISegmentedControl(items: ["旧固件", "新版全部", "新版按时间"])
    private let timestampField = UITextField()
    private let hintLabel = UILabel()
    private let errorLabel = UILabel()

    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateMode()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        overrideUserInterfaceStyle = .light
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.masksToBounds = true

        let titleLabel = UILabel()
        titleLabel.text = "读取戒指睡眠数据"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(16)
        }

        modeControl.selectedSegmentIndex = 0 // 保持旧固件默认调用行为。
        modeControl.addTarget(self, action: #selector(updateMode), for: .valueChanged)
        addSubview(modeControl)
        modeControl.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }

        timestampField.borderStyle = .roundedRect
        timestampField.keyboardType = .numberPad
        timestampField.placeholder = "UNIX秒：0...4294967295"
        timestampField.font = .systemFont(ofSize: 14)
        timestampField.text = String(UInt32(Date().timeIntervalSince1970))
        timestampField.accessibilityLabel = "查询起始UNIX秒"
        addSubview(timestampField)
        timestampField.snp.makeConstraints { make in
            make.top.equalTo(modeControl.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        hintLabel.numberOfLines = 0
        hintLabel.font = .systemFont(ofSize: 13)
        hintLabel.textColor = .darkGray
        addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(timestampField.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }

        errorLabel.numberOfLines = 0
        errorLabel.font = .systemFont(ofSize: 12)
        errorLabel.textColor = .systemRed
        addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addSubview(cancelButton)
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("读取", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        addSubview(confirmButton)
        cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton)
            make.right.equalTo(confirmButton.snp.left).offset(-16)
        }
        confirmButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.height.equalTo(cancelButton)
        }
    }

    @objc private func updateMode() {
        let usesTimestamp = modeControl.selectedSegmentIndex == 2
        timestampField.isEnabled = usesTimestamp
        timestampField.alpha = usesTimestamp ? 1 : 0.45
        if !usesTimestamp { endEditing(true) }
        errorLabel.text = nil
        switch modeControl.selectedSegmentIndex {
        case 1:
            hintLabel.text = "获取全部缓存。请确认固件支持新版睡眠查询。"
        case 2:
            hintLabel.text = "读取指定时间后的数据，单位为秒；0读取全部。请确认固件支持新版查询。"
        default:
            hintLabel.text = "使用旧固件读取方式，获取设备缓存睡眠数据。"
        }
    }

    @objc private func confirmButtonTapped() {
        let timestamp: UInt32?
        switch modeControl.selectedSegmentIndex {
        case 1:
            timestamp = 0
        case 2:
            let text = (timestampField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            // numberPad无法限制粘贴内容；必须再次校验ASCII整数与UInt32范围。
            guard !text.isEmpty, text.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }),
                  let value = UInt32(text) else {
                errorLabel.text = "请输入0...4294967295的整数秒，不能使用毫秒、负数或小数。"
                return
            }
            timestamp = value
        default:
            timestamp = nil
        }
        endEditing(true)
        confirmButtonCallback?(timestamp)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func cancelButtonTapped() {
        endEditing(true)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
