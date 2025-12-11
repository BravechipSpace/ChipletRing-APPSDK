//
//  SleepDataConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/12/10.
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class SleepDataConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ date: Date, _ timeZone: BCLRingTimeZone) -> Void)?

    // 全部 25 个时区选项，按偏移量从西到东排序
    private let timeZoneOptions: [BCLRingTimeZone] = [
        // 西时区 (West12 到 West1)
        .West12, .West11, .West10, .West9, .West8, .West7,
        .West6, .West5, .West4, .West3, .West2, .West1,
        // 中时区
        .UTC,
        // 东时区 (East1 到 East12)
        .East1, .East2, .East3, .East4, .East5, .East6,
        .East7, .East8, .East9, .East10, .East11, .East12
    ]

    private var selectedTimeZone: BCLRingTimeZone = .West8
    private let accentColor = UIColor(red: 66 / 255.0, green: 133 / 255.0, blue: 244 / 255.0, alpha: 1)

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

    private func setupUI() {
        // 强制使用浅色模式，避免暗黑模式下显示问题
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        layer.cornerRadius = 18
        layer.masksToBounds = true
        backgroundColor = .white

        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(dateLabel)
        addSubview(datePicker)
        addSubview(timeZoneLabel)
        addSubview(timeZoneButton)
        addSubview(timeZoneDescLabel)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(18)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(20)
        }

        datePicker.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }

        timeZoneLabel.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
        }

        timeZoneButton.snp.makeConstraints { make in
            make.top.equalTo(timeZoneLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }

        timeZoneDescLabel.snp.makeConstraints { make in
            make.top.equalTo(timeZoneButton.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(50)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(timeZoneDescLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-16)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-16)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(timeZoneDescLabel.snp.bottom).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    private func setupDefaultValues() {
        // 默认给到西八区场景，方便复现用户案例
        selectedTimeZone = .West8
        updateTimeZoneButtonTitle()
        updateDatePickerTimeZone()
    }

    // MARK: - Actions

    @objc private func confirmButtonTapped() {
        confirmButtonCallback?(datePicker.date, selectedTimeZone)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    // MARK: - TimeZone Menu

    @available(iOS 14.0, *)
    private func createTimeZoneMenu() -> UIMenu {
        // 按区域分组创建子菜单
        let westZones: [BCLRingTimeZone] = [.West12, .West11, .West10, .West9, .West8, .West7, .West6, .West5, .West4, .West3, .West2, .West1]
        let eastZones: [BCLRingTimeZone] = [.East1, .East2, .East3, .East4, .East5, .East6, .East7, .East8, .East9, .East10, .East11, .East12]

        let westActions = westZones.map { timeZone in
            UIAction(
                title: displayName(for: timeZone),
                state: selectedTimeZone == timeZone ? .on : .off
            ) { [weak self] _ in
                self?.selectTimeZone(timeZone)
            }
        }

        let utcAction = UIAction(
            title: displayName(for: .UTC),
            state: selectedTimeZone == .UTC ? .on : .off
        ) { [weak self] _ in
            self?.selectTimeZone(.UTC)
        }

        let eastActions = eastZones.map { timeZone in
            UIAction(
                title: displayName(for: timeZone),
                state: selectedTimeZone == timeZone ? .on : .off
            ) { [weak self] _ in
                self?.selectTimeZone(timeZone)
            }
        }

        let westMenu = UIMenu(title: "西时区 (GMT-12 ~ GMT-1)", options: .displayInline, children: westActions)
        let utcMenu = UIMenu(title: "中时区", options: .displayInline, children: [utcAction])
        let eastMenu = UIMenu(title: "东时区 (GMT+1 ~ GMT+12)", options: .displayInline, children: eastActions)

        return UIMenu(title: "选择时区", children: [westMenu, utcMenu, eastMenu])
    }

    private func selectTimeZone(_ timeZone: BCLRingTimeZone) {
        selectedTimeZone = timeZone
        updateTimeZoneButtonTitle()
        updateDatePickerTimeZone()
        // 更新菜单以显示选中状态
        if #available(iOS 14.0, *) {
            timeZoneButton.menu = createTimeZoneMenu()
        }
    }

    // MARK: - Helpers

    private func displayName(for timeZone: BCLRingTimeZone) -> String {
        let offset = timeZone.timeZoneOffset
        let sign = offset >= 0 ? "+" : ""
        return "GMT\(sign)\(offset)"
    }

    private func iOSTimeZone(for timeZone: BCLRingTimeZone) -> TimeZone {
        return TimeZone(secondsFromGMT: timeZone.timeZoneOffset * 3600) ?? TimeZone.current
    }

    private func updateTimeZoneButtonTitle() {
        let title = displayName(for: selectedTimeZone)
        if #available(iOS 15.0, *) {
            var config = timeZoneButton.configuration
            config?.title = title
            timeZoneButton.configuration = config
        } else {
            timeZoneButton.setTitle("  \(title)", for: .normal)
        }
    }

    private func updateDatePickerTimeZone() {
        datePicker.timeZone = iOSTimeZone(for: selectedTimeZone)
        timeZoneDescLabel.text = "当前选择：\(displayName(for: selectedTimeZone))，日期选择器已同步该时区\n\n⚠️ 提示：请将手机系统时区设置为与查询时区一致，以确保数据准确性"
    }

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择睡眠查询时间"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择查询时刻与所属时区，方便跨区调试"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "查询时间（日期 + 时间）"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.locale = Locale(identifier: "zh_CN")
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .compact
        }
        return picker
    }()

    private lazy var timeZoneLabel: UILabel = {
        let label = UILabel()
        label.text = "选择时区（用于生成目标绝对时间）"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var timeZoneButton: UIButton = {
        let button = UIButton(type: .system)

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "选择时区"
            config.baseForegroundColor = UIColor(white: 0.3, alpha: 1)
            config.baseBackgroundColor = UIColor(white: 0.95, alpha: 1)
            config.image = UIImage(systemName: "chevron.down")
            config.imagePlacement = .trailing
            config.imagePadding = 8
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            config.cornerStyle = .medium
            button.configuration = config
        } else {
            button.setTitle("  选择时区", for: .normal)
            button.setTitleColor(UIColor(white: 0.3, alpha: 1), for: .normal)
            button.contentHorizontalAlignment = .left
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.backgroundColor = UIColor(white: 0.95, alpha: 1)
            button.layer.cornerRadius = 10
            button.layer.masksToBounds = true
            button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            button.tintColor = .gray
            button.semanticContentAttribute = .forceRightToLeft
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        }

        if #available(iOS 14.0, *) {
            button.showsMenuAsPrimaryAction = true
            button.menu = createTimeZoneMenu()
        }
        return button
    }()

    private lazy var timeZoneDescLabel: UILabel = {
        let label = UILabel()
        label.text = "当前选择："
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        return label
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
        button.backgroundColor = accentColor
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
}
