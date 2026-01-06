//
//  GoMoreSleepQueryConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/12/30.
//

import QMUIKit
import SnapKit
import UIKit

class GoMoreSleepQueryConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ date: Date) -> Void)?

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
        addSubview(dateLabel)
        addSubview(datePicker)
        addSubview(dateDescLabel)
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

        dateDescLabel.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(dateDescLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-16)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-16)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(dateDescLabel.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    private func setupDefaultValues() {
        datePicker.date = Date()
        updateDateDescription()
    }

    // MARK: - Actions

    @objc private func confirmButtonTapped() {
        confirmButtonCallback?(datePicker.date)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func datePickerValueChanged() {
        updateDateDescription()
    }

    // MARK: - Helpers

    private func updateDateDescription() {
        let dateStr = dateFormatter.string(from: datePicker.date)
        dateDescLabel.text = "当前选择日期：\(dateStr)"
    }

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择睡眠查询日期"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "按本机时区自然日查询GoMore睡眠详情"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "查询日期"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "zh_CN")
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .compact
        }
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()

    private lazy var dateDescLabel: UILabel = {
        let label = UILabel()
        label.text = "当前选择日期："
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
