//
//  AlarmClockConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2026/10/28.
//


import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

/// 闹钟批量参数配置弹窗。
final class AlarmClockConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ items: [BCLAlarmClockData]) -> Void)?

    private let accentColor = UIColor(red: 66 / 255.0, green: 133 / 255.0, blue: 244 / 255.0, alpha: 1)
    private var alarmItems: [BCLAlarmClockData] = []

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.timeZone = TimeZone.current
        return formatter
    }()

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

    // MARK: - Setup

    private func setupUI() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        layer.cornerRadius = 18
        layer.masksToBounds = true
        backgroundColor = .white

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(scrollView)
        scrollView.addSubview(formContentView)

        [timeLabel,
         datePicker,
         repeatTypeLabel,
         repeatTypeSegmentedControl,
         vibrationEffectLabel,
         vibrationEffectSegmentedControl,
         customVibrationLabel,
         customVibrationTextField,
         enabledLabel,
         enabledSwitch,
         weekdayLabel,
         weekdayStackView,
         lightEffectLabel,
         lightEffectTextField,
         addAlarmButton,
         listSectionLabel,
         itemCountLabel,
         lastAlarmSummaryLabel,
         listActionStackView,
         capacityTipLabel].forEach { formContentView.addSubview($0) }

        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(18)
        }
        cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(confirmButton.snp.width)
            make.height.equalTo(44)
        }
        confirmButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(cancelButton)
            make.height.equalTo(cancelButton)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(cancelButton.snp.top).offset(-12)
        }
        formContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(20)
        }
        datePicker.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.right.equalToSuperview().offset(-20)
        }
        repeatTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(20)
        }
        repeatTypeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(repeatTypeLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        vibrationEffectLabel.snp.makeConstraints { make in
            make.top.equalTo(repeatTypeSegmentedControl.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(20)
        }
        vibrationEffectSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(vibrationEffectLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        customVibrationLabel.snp.makeConstraints { make in
            make.top.equalTo(vibrationEffectSegmentedControl.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(120)
        }
        customVibrationTextField.snp.makeConstraints { make in
            make.centerY.equalTo(customVibrationLabel)
            make.left.equalTo(customVibrationLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(38)
        }
        enabledLabel.snp.makeConstraints { make in
            make.top.equalTo(customVibrationTextField.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(20)
        }
        enabledSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(enabledLabel)
            make.right.equalToSuperview().offset(-20)
        }
        weekdayLabel.snp.makeConstraints { make in
            make.top.equalTo(enabledLabel.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(20)
        }
        weekdayStackView.snp.makeConstraints { make in
            make.top.equalTo(weekdayLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        lightEffectLabel.snp.makeConstraints { make in
            make.top.equalTo(weekdayStackView.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(120)
        }
        lightEffectTextField.snp.makeConstraints { make in
            make.centerY.equalTo(lightEffectLabel)
            make.left.equalTo(lightEffectLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(38)
        }
        addAlarmButton.snp.makeConstraints { make in
            make.top.equalTo(lightEffectTextField.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(42)
        }
        listSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(addAlarmButton.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
        }
        itemCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(listSectionLabel)
            make.right.equalToSuperview().offset(-20)
        }
        lastAlarmSummaryLabel.snp.makeConstraints { make in
            make.top.equalTo(listSectionLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(64)
        }
        listActionStackView.snp.makeConstraints { make in
            make.top.equalTo(lastAlarmSummaryLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(38)
        }
        capacityTipLabel.snp.makeConstraints { make in
            make.top.equalTo(listActionStackView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func setupDefaultValues() {
        datePicker.date = Date().addingTimeInterval(10 * 60)
        repeatTypeSegmentedControl.selectedSegmentIndex = 1
        vibrationEffectSegmentedControl.selectedSegmentIndex = 0
        customVibrationTextField.text = "4"
        enabledSwitch.isOn = true
        lightEffectTextField.text = "0"
        weekdayButtons.enumerated().forEach { index, button in
            button.isSelected = (1 ... 5).contains(index)
            updateWeekdayButtonStyle(button)
        }
        updateCustomVibrationAvailability()
        updateWeekdayAvailability()
        updateListSummary()
    }

    // MARK: - Actions

    @objc private func repeatTypeChanged() {
        updateWeekdayAvailability()
    }

    @objc private func vibrationEffectChanged() {
        updateCustomVibrationAvailability()
    }

    @objc private func weekdayButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        updateWeekdayButtonStyle(sender)
    }

    @objc private func addAlarmButtonTapped() {
        endEditing(true)
        guard let alarm = buildAlarmFromCurrentParameters() else { return }
        alarmItems.append(alarm)
        updateListSummary()
        datePicker.date = datePicker.date.addingTimeInterval(10 * 60)
    }

    @objc private func deleteLastButtonTapped() {
        guard !alarmItems.isEmpty else {
            showError("待发送列表为空")
            return
        }
        alarmItems.removeLast()
        updateListSummary()
    }

    @objc private func clearAllButtonTapped() {
        guard !alarmItems.isEmpty else {
            showError("待发送列表已经为空")
            return
        }
        alarmItems.removeAll()
        updateListSummary()
    }

    @objc private func confirmButtonTapped() {
        guard !alarmItems.isEmpty else {
            showError("请至少添加一条闹钟")
            return
        }
        confirmButtonCallback?(alarmItems)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    // MARK: - Data

    private func buildAlarmFromCurrentParameters() -> BCLAlarmClockData? {
        let timestamp = datePicker.date.timeIntervalSince1970
        guard timestamp >= 0, timestamp <= TimeInterval(UInt32.max) else {
            showError("闹钟时间超出协议范围")
            return nil
        }
        guard let vibrationEffect = selectedVibrationEffect(),
              let lightEffect = uint8Value(from: lightEffectTextField, fieldName: "灯光效果") else {
            return nil
        }

        let repeatType = selectedRepeatType()
        let usesWeekdays = repeatType == .daily
        return BCLAlarmClockData(
            timestamp: timestamp,
            repeatType: repeatType,
            vibrationEffect: vibrationEffect,
            isEnabled: enabledSwitch.isOn,
            isMonday: usesWeekdays && weekdayButtons[1].isSelected,
            isTuesday: usesWeekdays && weekdayButtons[2].isSelected,
            isWednesday: usesWeekdays && weekdayButtons[3].isSelected,
            isThursday: usesWeekdays && weekdayButtons[4].isSelected,
            isFriday: usesWeekdays && weekdayButtons[5].isSelected,
            isSaturday: usesWeekdays && weekdayButtons[6].isSelected,
            isSunday: usesWeekdays && weekdayButtons[0].isSelected,
            lightEffect: lightEffect
        )
    }

    private func selectedRepeatType() -> BCLRepeatType {
        switch repeatTypeSegmentedControl.selectedSegmentIndex {
        case 0: return .once
        case 2: return .smartWorkday
        default: return .daily
        }
    }

    private func selectedVibrationEffect() -> BCLVibrationEffect? {
        let rawValue: Int
        switch vibrationEffectSegmentedControl.selectedSegmentIndex {
        case 0, 1, 2:
            rawValue = vibrationEffectSegmentedControl.selectedSegmentIndex
        case 3:
            guard let value = uint8Value(from: customVibrationTextField, fieldName: "自定义震动效果") else {
                return nil
            }
            rawValue = Int(value)
        default:
            rawValue = 0
        }
        guard let effect = BCLVibrationEffect(rawValue) else {
            showError("震动效果必须在 0...255 范围内")
            return nil
        }
        return effect
    }

    private func uint8Value(from textField: UITextField, fieldName: String) -> UInt8? {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard let value = Int(text), (0 ... 255).contains(value) else {
            showError("\(fieldName)必须是 0...255 的整数")
            return nil
        }
        return UInt8(value)
    }

    // MARK: - UI Updates

    private func updateCustomVibrationAvailability() {
        let isCustom = vibrationEffectSegmentedControl.selectedSegmentIndex == 3
        customVibrationTextField.isEnabled = isCustom
        customVibrationTextField.alpha = isCustom ? 1 : 0.45
        customVibrationLabel.alpha = isCustom ? 1 : 0.45
    }

    private func updateWeekdayAvailability() {
        let isDaily = repeatTypeSegmentedControl.selectedSegmentIndex == 1
        weekdayButtons.forEach { button in
            button.isEnabled = isDaily
            button.alpha = isDaily ? 1 : 0.45
        }
        weekdayLabel.text = isDaily ? "重复星期（可多选）" : "重复星期（当前类型不使用）"
    }

    private func updateWeekdayButtonStyle(_ button: UIButton) {
        button.backgroundColor = button.isSelected ? accentColor : UIColor.systemGray5
        button.setTitleColor(button.isSelected ? .white : .darkGray, for: .normal)
    }

    private func updateListSummary() {
        let isEmpty = alarmItems.isEmpty
        itemCountLabel.text = "\(alarmItems.count) 条"
        itemCountLabel.textColor = isEmpty ? .darkGray : accentColor
        deleteLastButton.isEnabled = !isEmpty
        clearAllButton.isEnabled = !isEmpty
        deleteLastButton.alpha = isEmpty ? 0.45 : 1
        clearAllButton.alpha = isEmpty ? 0.45 : 1

        guard let latest = alarmItems.last else {
            lastAlarmSummaryLabel.text = "  尚未添加闹钟。请配置上方参数后点击“添加当前闹钟”。"
            return
        }

        let stateText = latest.isEnabled ? "开启" : "关闭"
        let weekdayText = weekdayDescription(for: latest)
        lastAlarmSummaryLabel.text = "  最近添加：\(dateFormatter.string(from: Date(timeIntervalSince1970: latest.timestamp)))\n  重复：\(repeatTypeDescription(latest.repeatType))，星期：\(weekdayText)\n  震动：\(latest.vibrationEffect.rawValue)，灯光：\(latest.lightEffect)，状态：\(stateText)"
    }

    private func repeatTypeDescription(_ repeatType: BCLRepeatType) -> String {
        switch repeatType {
        case .once: return "仅一次"
        case .daily: return "按星期重复"
        case .smartWorkday: return "智能工作日"
        }
    }

    private func weekdayDescription(for alarm: BCLAlarmClockData) -> String {
        var weekdays: [String] = []
        if alarm.isSunday { weekdays.append("日") }
        if alarm.isMonday { weekdays.append("一") }
        if alarm.isTuesday { weekdays.append("二") }
        if alarm.isWednesday { weekdays.append("三") }
        if alarm.isThursday { weekdays.append("四") }
        if alarm.isFriday { weekdays.append("五") }
        if alarm.isSaturday { weekdays.append("六") }
        return weekdays.isEmpty ? "无" : weekdays.joined(separator: "、")
    }

    private func showError(_ message: String) {
        if let currentWindow = window {
            QMUITips.showError(message, in: currentWindow)
            return
        }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneWindow = windowScene.windows.first {
            QMUITips.showError(message, in: sceneWindow)
        }
    }

    // MARK: - UI Components

    private lazy var titleLabel = makeLabel(text: "闹钟参数配置", size: 18, weight: .bold)

    private lazy var subtitleLabel: UILabel = {
        let label = makeLabel(text: "逐条添加后一次性写入；SDK 不限制固定条数", size: 13, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let formContentView = UIView()
    private lazy var timeLabel = makeLabel(text: "闹钟时间", weight: .medium)

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.locale = Locale(identifier: "zh_CN")
        picker.minimumDate = Date()
        if #available(iOS 14.0, *) { picker.preferredDatePickerStyle = .compact }
        return picker
    }()

    private lazy var repeatTypeLabel = makeLabel(text: "重复类型", weight: .medium)
    private lazy var repeatTypeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["仅一次", "按星期", "智能工作日"])
        control.addTarget(self, action: #selector(repeatTypeChanged), for: .valueChanged)
        return control
    }()

    private lazy var vibrationEffectLabel = makeLabel(text: "震动效果", weight: .medium)
    private lazy var vibrationEffectSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["强力", "弱震动", "渐变", "自定义"])
        control.addTarget(self, action: #selector(vibrationEffectChanged), for: .valueChanged)
        return control
    }()

    private lazy var customVibrationLabel = makeLabel(text: "自定义原始值")
    private lazy var customVibrationTextField = makeNumberTextField(placeholder: "0...255")
    private lazy var enabledLabel = makeLabel(text: "启用闹钟", weight: .medium)
    private lazy var enabledSwitch: UISwitch = {
        let control = UISwitch()
        control.onTintColor = accentColor
        return control
    }()
    private lazy var weekdayLabel = makeLabel(text: "重复星期（可多选）", weight: .medium)

    private lazy var weekdayButtons: [UIButton] = {
        ["日", "一", "二", "三", "四", "五", "六"].enumerated().map { index, title in
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            button.addTarget(self, action: #selector(weekdayButtonTapped(_:)), for: .touchUpInside)
            return button
        }
    }()

    private lazy var weekdayStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: weekdayButtons)
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var lightEffectLabel = makeLabel(text: "灯光效果原始值")
    private lazy var lightEffectTextField = makeNumberTextField(placeholder: "0...255")

    private lazy var addAlarmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("添加当前闹钟", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = accentColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addAlarmButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var listSectionLabel = makeLabel(text: "待发送列表", weight: .semibold)
    private lazy var itemCountLabel = makeLabel(text: "0 条", weight: .semibold)

    private lazy var lastAlarmSummaryLabel: UILabel = {
        let label = makeLabel(text: "")
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.systemGray6
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private lazy var deleteLastButton = makeListActionButton(title: "删除最后一条", color: .systemOrange, action: #selector(deleteLastButtonTapped))
    private lazy var clearAllButton = makeListActionButton(title: "清空全部", color: .systemRed, action: #selector(clearAllButtonTapped))
    private lazy var listActionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [deleteLastButton, clearAllButton])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var capacityTipLabel: UILabel = {
        let label = makeLabel(text: "提示：实际可设置数量仍受目标固件容量和 BLE 单次写入能力约束。", size: 11)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()

    private lazy var cancelButton = makeBottomButton(title: "取消", color: UIColor.gray.withAlphaComponent(0.5), action: #selector(cancelButtonTapped))
    private lazy var confirmButton = makeBottomButton(title: "设置全部", color: accentColor, action: #selector(confirmButtonTapped))

    private func makeLabel(text: String, size: CGFloat = 14, weight: UIFont.Weight = .regular) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: size, weight: weight)
        return label
    }

    private func makeNumberTextField(placeholder: String) -> QMUITextField {
        let textField = QMUITextField()
        textField.placeholder = placeholder
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return textField
    }

    private func makeListActionButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.backgroundColor = color.withAlphaComponent(0.1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeBottomButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
