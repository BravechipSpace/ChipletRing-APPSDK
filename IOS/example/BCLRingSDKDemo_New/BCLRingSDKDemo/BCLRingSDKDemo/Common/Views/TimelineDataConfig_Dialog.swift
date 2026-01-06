//
//  TimelineDataConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/12/30.
//

import QMUIKit
import SnapKit
import UIKit

class TimelineDataConfig_Dialog: UIView {
    /// 确认回调，返回开始时间戳和结束时间戳（秒级）
    var confirmButtonCallback: ((_ startTime: Int, _ endTime: Int) -> Void)?

    private let accentColor = UIColor(red: 66 / 255.0, green: 133 / 255.0, blue: 244 / 255.0, alpha: 1)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
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

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subTitleLabel.text = subtitle
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
        addSubview(startTimeLabel)
        addSubview(startTimePicker)
        addSubview(endTimeLabel)
        addSubview(endTimePicker)
        addSubview(timeRangeDescLabel)
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

        startTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(20)
        }

        startTimePicker.snp.makeConstraints { make in
            make.top.equalTo(startTimeLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }

        endTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(startTimePicker.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(20)
        }

        endTimePicker.snp.makeConstraints { make in
            make.top.equalTo(endTimeLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }

        timeRangeDescLabel.snp.makeConstraints { make in
            make.top.equalTo(endTimePicker.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(timeRangeDescLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-16)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-16)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(timeRangeDescLabel.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    private func setupDefaultValues() {
        // 默认：开始时间为7天前的00:00，结束时间为当前时间
        let today = Date()
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        let startOfDay = calendar.startOfDay(for: sevenDaysAgo)
        startTimePicker.date = startOfDay
        endTimePicker.date = today
        updateTimeRangeDescription()
    }

    // MARK: - Actions

    @objc private func confirmButtonTapped() {
        // 验证时间范围
        if endTimePicker.date < startTimePicker.date {
            showError("结束时间不能早于开始时间")
            return
        }

        let startTimestamp = Int(startTimePicker.date.timeIntervalSince1970)
        let endTimestamp = Int(endTimePicker.date.timeIntervalSince1970)
        confirmButtonCallback?(startTimestamp, endTimestamp)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func datePickerValueChanged() {
        updateTimeRangeDescription()
    }

    // MARK: - Helpers

    private func updateTimeRangeDescription() {
        let startStr = dateFormatter.string(from: startTimePicker.date)
        let endStr = dateFormatter.string(from: endTimePicker.date)

        let components = Calendar.current.dateComponents([.day, .hour], from: startTimePicker.date, to: endTimePicker.date)
        let days = components.day ?? 0
        let hours = components.hour ?? 0

        if endTimePicker.date < startTimePicker.date {
            timeRangeDescLabel.text = "时间范围无效（结束时间早于开始时间）"
            timeRangeDescLabel.textColor = .systemRed
        } else {
            var durationDesc = ""
            if days > 0 {
                durationDesc = "\(days) 天 \(hours) 小时"
            } else {
                durationDesc = "\(hours) 小时"
            }
            timeRangeDescLabel.text = "查询范围：\(startStr) 至 \(endStr)\n时长约：\(durationDesc)"
            timeRangeDescLabel.textColor = UIColor.darkGray
        }
    }

    private func showError(_ message: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            QMUITips.show(withText: message, in: window, hideAfterDelay: 2.0)
        }
    }

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择时间线查询范围"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择开始和结束时间，查询时间线数据"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()

    private lazy var startTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "开始时间"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var startTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.locale = Locale(identifier: "zh_CN")
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .compact
        }
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()

    private lazy var endTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "结束时间"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var endTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.locale = Locale(identifier: "zh_CN")
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .compact
        }
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()

    private lazy var timeRangeDescLabel: UILabel = {
        let label = UILabel()
        label.text = "查询范围："
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
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
