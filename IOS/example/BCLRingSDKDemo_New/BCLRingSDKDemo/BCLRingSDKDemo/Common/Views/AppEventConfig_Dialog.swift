//
//  AppEventConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by Codex on 2026/9/2.
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class AppEventConfig_Dialog: UIView {
    enum CommandType {
        case bind
        case connect
        case refresh

        var title: String {
            switch self {
            case .bind:
                return "绑定戒指参数配置"
            case .connect:
                return "连接戒指参数配置"
            case .refresh:
                return "刷新戒指参数配置"
            }
        }

        var supportsFilterTime: Bool {
            switch self {
            case .bind:
                return false
            case .connect, .refresh:
                return true
            }
        }
    }

    var confirmButtonCallback: ((_ date: Date, _ timeZone: BCLRingTimeZone, _ filterTime: Date?) -> Void)?

    private let commandType: CommandType
    private let dateFormat = "yyyy-MM-dd HH:mm:ss"

    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, commandType: CommandType) {
        self.init(frame: CGRect(x: x, y: y, width: width, height: height), commandType: commandType)
    }

    init(frame: CGRect, commandType: CommandType) {
        self.commandType = commandType
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
        addSubview(dateLabel)
        addSubview(dateTextField)
        addSubview(dateHintLabel)
        addSubview(timeZoneLabel)
        addSubview(timeZoneTextField)
        addSubview(timeZoneHintLabel)

        if commandType.supportsFilterTime {
            addSubview(filterTimeSwitchLabel)
            addSubview(filterTimeSwitch)
            addSubview(filterTimeLabel)
            addSubview(filterTimeTextField)
            addSubview(filterTimeHintLabel)
        }

        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(20)
        }

        dateTextField.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        dateHintLabel.snp.makeConstraints { make in
            make.top.equalTo(dateTextField.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        timeZoneLabel.snp.makeConstraints { make in
            make.top.equalTo(dateHintLabel.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(20)
        }

        timeZoneTextField.snp.makeConstraints { make in
            make.top.equalTo(timeZoneLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        timeZoneHintLabel.snp.makeConstraints { make in
            make.top.equalTo(timeZoneTextField.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        if commandType.supportsFilterTime {
            filterTimeSwitchLabel.snp.makeConstraints { make in
                make.top.equalTo(timeZoneHintLabel.snp.bottom).offset(14)
                make.left.equalToSuperview().offset(20)
                make.centerY.equalTo(filterTimeSwitch)
            }

            filterTimeSwitch.snp.makeConstraints { make in
                make.top.equalTo(timeZoneHintLabel.snp.bottom).offset(10)
                make.right.equalToSuperview().offset(-20)
            }

            filterTimeLabel.snp.makeConstraints { make in
                make.top.equalTo(filterTimeSwitch.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(20)
            }

            filterTimeTextField.snp.makeConstraints { make in
                make.top.equalTo(filterTimeLabel.snp.bottom).offset(8)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.height.equalTo(40)
            }

            filterTimeHintLabel.snp.makeConstraints { make in
                make.top.equalTo(filterTimeTextField.snp.bottom).offset(6)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
            }

            cancelButton.snp.makeConstraints { make in
                make.top.equalTo(filterTimeHintLabel.snp.bottom).offset(24)
                make.left.equalToSuperview().offset(20)
                make.right.equalTo(confirmButton.snp.left).offset(-20)
                make.height.equalTo(44)
                make.width.equalTo(confirmButton.snp.width)
                make.bottom.equalToSuperview().offset(-20)
            }
        } else {
            cancelButton.snp.makeConstraints { make in
                make.top.equalTo(timeZoneHintLabel.snp.bottom).offset(24)
                make.left.equalToSuperview().offset(20)
                make.right.equalTo(confirmButton.snp.left).offset(-20)
                make.height.equalTo(44)
                make.width.equalTo(confirmButton.snp.width)
                make.bottom.equalToSuperview().offset(-20)
            }
        }

        confirmButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
            make.centerY.equalTo(cancelButton)
        }
    }

    func setupDefaultValues() {
        titleLabel.text = commandType.title
        dateTextField.text = formattedDate(Date())
        timeZoneTextField.text = "\(timeZoneOffsetHours(BCLRingTimeZone.getCurrentSystemTimeZone()))"
        filterTimeTextField.text = "2025-01-01 00:00:00"
        filterTimeTextField.isEnabled = filterTimeSwitch.isOn
        filterTimeTextField.alpha = filterTimeSwitch.isOn ? 1.0 : 0.45
        filterTimeHintLabel.alpha = filterTimeSwitch.isOn ? 1.0 : 0.45
    }

    // MARK: - 懒加载

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "同步时间:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var dateTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "例如: 2026-09-02 12:00:00"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.keyboardType = .numbersAndPunctuation
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return textField
    }()

    lazy var dateHintLabel: UILabel = {
        let label = UILabel()
        label.text = "格式: yyyy-MM-dd HH:mm:ss"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()

    lazy var timeZoneLabel: UILabel = {
        let label = UILabel()
        label.text = "时区:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var timeZoneTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "例如: 8"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.keyboardType = .numbersAndPunctuation
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return textField
    }()

    lazy var timeZoneHintLabel: UILabel = {
        let label = UILabel()
        label.text = "UTC填0，东区填1~12，西区填-1~-12"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()

    lazy var filterTimeSwitchLabel: UILabel = {
        let label = UILabel()
        label.text = "启用过滤时间:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var filterTimeSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.isOn = true
        switchView.addTarget(self, action: #selector(filterTimeSwitchChanged), for: .valueChanged)
        return switchView
    }()

    lazy var filterTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "过滤时间:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var filterTimeTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "例如: 2025-01-01 00:00:00"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.keyboardType = .numbersAndPunctuation
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return textField
    }()

    lazy var filterTimeHintLabel: UILabel = {
        let label = UILabel()
        label.text = "关闭开关或留空时传nil，表示不过滤"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
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
        button.setTitle("确认", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc func filterTimeSwitchChanged() {
        filterTimeTextField.isEnabled = filterTimeSwitch.isOn
        filterTimeTextField.alpha = filterTimeSwitch.isOn ? 1.0 : 0.45
        filterTimeHintLabel.alpha = filterTimeSwitch.isOn ? 1.0 : 0.45
    }

    @objc func confirmButtonTapped() {
        guard let timeZoneText = timeZoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let timeZone = timeZone(from: timeZoneText) else {
            BDLogger.warning("时区格式不正确，请输入-12到12之间的整数")
            shakeTextField(timeZoneTextField)
            return
        }

        guard let dateText = dateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let date = parseDate(dateText, timeZone: timeZone) else {
            BDLogger.warning("同步时间格式不正确，请使用\(dateFormat)")
            shakeTextField(dateTextField)
            return
        }

        var filterTime: Date?
        if commandType.supportsFilterTime && filterTimeSwitch.isOn {
            let filterTimeText = filterTimeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if filterTimeText.isEmpty {
                filterTime = nil
            } else if let parsedFilterTime = parseDate(filterTimeText, timeZone: timeZone) {
                filterTime = parsedFilterTime
            } else {
                BDLogger.warning("过滤时间格式不正确，请使用\(dateFormat)")
                shakeTextField(filterTimeTextField)
                return
            }
        }

        BDLogger.info("App复合指令参数配置 - 同步时间:\(dateText), 时区:\(timeZoneDescription(timeZone)), 过滤时间:\(filterTimeDescription(filterTime))")
        confirmButtonCallback?(date, timeZone, filterTime)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    private func formattedDate(_ date: Date) -> String {
        return dateFormatter(for: BCLRingTimeZone.getCurrentSystemTimeZone()).string(from: date)
    }

    private func parseDate(_ text: String, timeZone: BCLRingTimeZone) -> Date? {
        return dateFormatter(for: timeZone).date(from: text)
    }

    private func filterTimeDescription(_ filterTime: Date?) -> String {
        guard let filterTime = filterTime else {
            return "未启用(nil)"
        }
        return formattedDate(filterTime)
    }

    private func timeZoneDescription(_ timeZone: BCLRingTimeZone) -> String {
        let offsetHours = timeZoneOffsetHours(timeZone)
        return "GMT\(offsetHours >= 0 ? "+" : "")\(offsetHours)(rawValue:\(timeZone.rawValue))"
    }

    private func dateFormatter(for timeZone: BCLRingTimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: timeZoneOffsetHours(timeZone) * 3600)
        return formatter
    }

    private func timeZoneOffsetHours(_ timeZone: BCLRingTimeZone) -> Int {
        let rawValue = timeZone.rawValue
        return rawValue > 127 ? rawValue - 256 : rawValue
    }

    private func timeZone(from text: String) -> BCLRingTimeZone? {
        guard let offsetHours = Int(text), (-12 ... 12).contains(offsetHours) else {
            return nil
        }

        switch offsetHours {
        case 0: return .UTC
        case 1: return .East1
        case 2: return .East2
        case 3: return .East3
        case 4: return .East4
        case 5: return .East5
        case 6: return .East6
        case 7: return .East7
        case 8: return .East8
        case 9: return .East9
        case 10: return .East10
        case 11: return .East11
        case 12: return .East12
        case -1: return .West1
        case -2: return .West2
        case -3: return .West3
        case -4: return .West4
        case -5: return .West5
        case -6: return .West6
        case -7: return .West7
        case -8: return .West8
        case -9: return .West9
        case -10: return .West10
        case -11: return .West11
        case -12: return .West12
        default: return nil
        }
    }

    private func shakeTextField(_ textField: UITextField) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10, 10, -10, 10, -5, 5, -2, 2, 0]
        textField.layer.add(animation, forKey: "shake")
    }
}
