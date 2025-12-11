//
//  SleepDataRangeConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/12/10.
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class SleepDataRangeConfig_Dialog: UIView {
    /// 确认回调，返回日期字符串数组 ["2025-05-01", "2025-05-02", ...]
    var confirmButtonCallback: ((_ dates: [String]) -> Void)?

    private let accentColor = UIColor(red: 66 / 255.0, green: 133 / 255.0, blue: 244 / 255.0, alpha: 1)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
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
        addSubview(startDateLabel)
        addSubview(startDatePicker)
        addSubview(endDateLabel)
        addSubview(endDatePicker)
        addSubview(dateRangeDescLabel)
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

        startDateLabel.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(20)
        }

        startDatePicker.snp.makeConstraints { make in
            make.top.equalTo(startDateLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }

        endDateLabel.snp.makeConstraints { make in
            make.top.equalTo(startDatePicker.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(20)
        }

        endDatePicker.snp.makeConstraints { make in
            make.top.equalTo(endDateLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }

        dateRangeDescLabel.snp.makeConstraints { make in
            make.top.equalTo(endDatePicker.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(dateRangeDescLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-16)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-16)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(dateRangeDescLabel.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    private func setupDefaultValues() {
        // 默认：开始日期为7天前，结束日期为今天
        let today = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today
        startDatePicker.date = sevenDaysAgo
        endDatePicker.date = today
        updateDateRangeDescription()
    }

    // MARK: - Actions

    @objc private func confirmButtonTapped() {
        // 验证日期范围
        if endDatePicker.date < startDatePicker.date {
            showError("结束日期不能早于开始日期")
            return
        }

        let dates = generateDateStrings(from: startDatePicker.date, to: endDatePicker.date)
        confirmButtonCallback?(dates)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func datePickerValueChanged() {
        updateDateRangeDescription()
    }

    // MARK: - Helpers

    private func generateDateStrings(from startDate: Date, to endDate: Date) -> [String] {
        var dates: [String] = []
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            dates.append(dateFormatter.string(from: currentDate))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return dates
    }

    private func updateDateRangeDescription() {
        let startStr = dateFormatter.string(from: startDatePicker.date)
        let endStr = dateFormatter.string(from: endDatePicker.date)

        let dayCount = Calendar.current.dateComponents([.day], from: startDatePicker.date, to: endDatePicker.date).day ?? 0
        let actualDays = dayCount + 1

        if endDatePicker.date < startDatePicker.date {
            dateRangeDescLabel.text = "日期范围无效（结束日期早于开始日期）"
            dateRangeDescLabel.textColor = .systemRed
        } else {
            dateRangeDescLabel.text = "查询范围：\(startStr) 至 \(endStr)，共 \(actualDays) 天"
            dateRangeDescLabel.textColor = UIColor.darkGray
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
        label.text = "选择睡眠查询时间范围"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择开始和结束日期，查询多日睡眠数据"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()

    private lazy var startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "开始日期"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "zh_CN")
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .compact
        }
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()

    private lazy var endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "结束日期"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "zh_CN")
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .compact
        }
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()

    private lazy var dateRangeDescLabel: UILabel = {
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
