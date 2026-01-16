//
//  SettingGoMorePersonalInformation_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/14.
//  GoMore个人信息设置对话框

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class SettingGoMorePersonalInformation_Dialog: UIView {
    /// 确认回调，传入个人信息参数
    /// - Parameters:
    ///   - age: 年龄（10-99）
    ///   - gender: 性别（0女性，1男性）
    ///   - height: 身高（100-220 cm）
    ///   - weight: 体重（10-150 kg）
    ///   - maxHeartRate: 最大心率值（138-220），nil表示不设置
    ///   - normalHeartRate: 常态心率值（40-100），nil表示不设置
    ///   - maxOxygenUptake: 最大摄氧量（ml/kg/min），nil表示不设置
    var confirmButtonCallback: ((_ age: UInt8, _ gender: UInt8, _ height: UInt8, _ weight: UInt8, _ maxHeartRate: Int16?, _ normalHeartRate: Int8?, _ maxOxygenUptake: Int8?) -> Void)?

    private let accentColor = UIColor(red: 66 / 255.0, green: 133 / 255.0, blue: 244 / 255.0, alpha: 1)

    // MARK: - Initialization

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

    // MARK: - UI Setup

    private func setupUI() {
        // 强制使用浅色模式
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        layer.cornerRadius = 15
        layer.masksToBounds = true
        backgroundColor = .white

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)

        // 必填参数区域
        contentView.addSubview(requiredSectionLabel)
        contentView.addSubview(ageLabel)
        contentView.addSubview(ageTextField)
        contentView.addSubview(genderLabel)
        contentView.addSubview(genderSegment)
        contentView.addSubview(heightLabel)
        contentView.addSubview(heightTextField)
        contentView.addSubview(weightLabel)
        contentView.addSubview(weightTextField)

        // 可选参数区域
        contentView.addSubview(optionalSectionLabel)
        contentView.addSubview(maxHeartRateLabel)
        contentView.addSubview(maxHeartRateTextField)
        contentView.addSubview(normalHeartRateLabel)
        contentView.addSubview(normalHeartRateTextField)
        contentView.addSubview(maxOxygenUptakeLabel)
        contentView.addSubview(maxOxygenUptakeTextField)

        // 按钮
        contentView.addSubview(cancelButton)
        contentView.addSubview(confirmButton)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        // 必填参数区域
        requiredSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
        }

        ageLabel.snp.makeConstraints { make in
            make.top.equalTo(requiredSectionLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(100)
        }

        ageTextField.snp.makeConstraints { make in
            make.centerY.equalTo(ageLabel)
            make.left.equalTo(ageLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }

        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(ageTextField.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(100)
        }

        genderSegment.snp.makeConstraints { make in
            make.centerY.equalTo(genderLabel)
            make.left.equalTo(genderLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }

        heightLabel.snp.makeConstraints { make in
            make.top.equalTo(genderSegment.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(100)
        }

        heightTextField.snp.makeConstraints { make in
            make.centerY.equalTo(heightLabel)
            make.left.equalTo(heightLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }

        weightLabel.snp.makeConstraints { make in
            make.top.equalTo(heightTextField.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(100)
        }

        weightTextField.snp.makeConstraints { make in
            make.centerY.equalTo(weightLabel)
            make.left.equalTo(weightLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }

        // 可选参数区域
        optionalSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(weightTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
        }

        maxHeartRateLabel.snp.makeConstraints { make in
            make.top.equalTo(optionalSectionLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(100)
        }

        maxHeartRateTextField.snp.makeConstraints { make in
            make.centerY.equalTo(maxHeartRateLabel)
            make.left.equalTo(maxHeartRateLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }

        normalHeartRateLabel.snp.makeConstraints { make in
            make.top.equalTo(maxHeartRateTextField.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(100)
        }

        normalHeartRateTextField.snp.makeConstraints { make in
            make.centerY.equalTo(normalHeartRateLabel)
            make.left.equalTo(normalHeartRateLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }

        maxOxygenUptakeLabel.snp.makeConstraints { make in
            make.top.equalTo(normalHeartRateTextField.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(100)
        }

        maxOxygenUptakeTextField.snp.makeConstraints { make in
            make.centerY.equalTo(maxOxygenUptakeLabel)
            make.left.equalTo(maxOxygenUptakeLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }

        // 按钮
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(maxOxygenUptakeTextField.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(confirmButton.snp.left).offset(-12)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(maxOxygenUptakeTextField.snp.bottom).offset(24)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
    }

    private func setupDefaultValues() {
        ageTextField.text = "25"
        genderSegment.selectedSegmentIndex = 1 // 默认男性
        heightTextField.text = "170"
        weightTextField.text = "65"
        // 可选参数默认为空
        maxHeartRateTextField.text = ""
        normalHeartRateTextField.text = ""
        maxOxygenUptakeTextField.text = ""
    }

    // MARK: - Lazy Properties

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = true
        sv.alwaysBounceVertical = true
        return sv
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "设置GoMore个人信息"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    // 必填参数区域
    private lazy var requiredSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "必填参数"
        label.textColor = accentColor
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.text = "年龄(10-99):"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var ageTextField: QMUITextField = {
        let tf = QMUITextField()
        tf.placeholder = "年龄"
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        tf.keyboardType = .numberPad
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        tf.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return tf
    }()

    private lazy var genderLabel: UILabel = {
        let label = UILabel()
        label.text = "性别:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var genderSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["女性", "男性"])
        segment.selectedSegmentIndex = 1
        return segment
    }()

    private lazy var heightLabel: UILabel = {
        let label = UILabel()
        label.text = "身高(cm):"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var heightTextField: QMUITextField = {
        let tf = QMUITextField()
        tf.placeholder = "100-220"
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        tf.keyboardType = .numberPad
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        tf.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return tf
    }()

    private lazy var weightLabel: UILabel = {
        let label = UILabel()
        label.text = "体重(kg):"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var weightTextField: QMUITextField = {
        let tf = QMUITextField()
        tf.placeholder = "10-150"
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        tf.keyboardType = .numberPad
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        tf.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return tf
    }()

    // 可选参数区域
    private lazy var optionalSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "可选参数（留空表示不设置）"
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    private lazy var maxHeartRateLabel: UILabel = {
        let label = UILabel()
        label.text = "最大心率:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var maxHeartRateTextField: QMUITextField = {
        let tf = QMUITextField()
        tf.placeholder = "138-220（可选）"
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        tf.keyboardType = .numberPad
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        tf.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return tf
    }()

    private lazy var normalHeartRateLabel: UILabel = {
        let label = UILabel()
        label.text = "常态心率:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var normalHeartRateTextField: QMUITextField = {
        let tf = QMUITextField()
        tf.placeholder = "40-100（可选）"
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        tf.keyboardType = .numberPad
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        tf.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return tf
    }()

    private lazy var maxOxygenUptakeLabel: UILabel = {
        let label = UILabel()
        label.text = "最大摄氧量:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var maxOxygenUptakeTextField: QMUITextField = {
        let tf = QMUITextField()
        tf.placeholder = "ml/kg/min（可选）"
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        tf.keyboardType = .numberPad
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        tf.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return tf
    }()

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
        // 验证必填参数
        guard let ageText = ageTextField.text, let age = Int(ageText) else {
            showErrorAlert("参数错误", message: "请输入有效的年龄")
            return
        }
        guard age >= 10 && age <= 99 else {
            showErrorAlert("参数错误", message: "年龄范围: 0-99")
            return
        }

        guard let heightText = heightTextField.text, let height = Int(heightText) else {
            showErrorAlert("参数错误", message: "请输入有效的身高")
            return
        }
        guard height >= 100 && height <= 220 else {
            showErrorAlert("参数错误", message: "身高范围: 100-220 cm")
            return
        }

        guard let weightText = weightTextField.text, let weight = Int(weightText) else {
            showErrorAlert("参数错误", message: "请输入有效的体重")
            return
        }
        guard weight >= 10 && weight <= 150 else {
            showErrorAlert("参数错误", message: "体重范围: 10-150 kg")
            return
        }

        let gender = genderSegment.selectedSegmentIndex // 0=女性, 1=男性

        // 处理可选参数（nil表示不设置）
        var maxHeartRate: Int16? = nil
        if let maxHRText = maxHeartRateTextField.text, !maxHRText.isEmpty {
            guard let maxHR = Int(maxHRText), maxHR >= 138 && maxHR <= 220 else {
                showErrorAlert("参数错误", message: "最大心率范围: 138-220")
                return
            }
            maxHeartRate = Int16(maxHR)
        }

        var normalHeartRate: Int8? = nil
        if let normalHRText = normalHeartRateTextField.text, !normalHRText.isEmpty {
            guard let normalHR = Int(normalHRText), normalHR >= 40 && normalHR <= 100 else {
                showErrorAlert("参数错误", message: "常态心率范围: 40-100")
                return
            }
            normalHeartRate = Int8(normalHR)
        }

        var maxOxygenUptake: Int8? = nil
        if let maxO2Text = maxOxygenUptakeTextField.text, !maxO2Text.isEmpty {
            guard let maxO2 = Int(maxO2Text), maxO2 >= 0 && maxO2 <= 127 else {
                showErrorAlert("参数错误", message: "最大摄氧量范围: 0-127 ml/kg/min")
                return
            }
            maxOxygenUptake = Int8(maxO2)
        }

        BDLogger.info("设置GoMore个人信息 - 年龄:\(age), 性别:\(gender), 身高:\(height), 体重:\(weight), 最大心率:\(String(describing: maxHeartRate)), 常态心率:\(String(describing: normalHeartRate)), 最大摄氧量:\(String(describing: maxOxygenUptake))")

        confirmButtonCallback?(
            UInt8(age),
            UInt8(gender),
            UInt8(height),
            UInt8(weight),
            maxHeartRate,
            normalHeartRate,
            maxOxygenUptake
        )
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    // MARK: - Helper Methods

    private func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))

        if let viewController = window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
}
