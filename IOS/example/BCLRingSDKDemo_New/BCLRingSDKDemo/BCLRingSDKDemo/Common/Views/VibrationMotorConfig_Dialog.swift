//
//  VibrationMotorConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/25.
//

import BCLRingSDK
import QMUIKit
import RxSwift
import SnapKit
import UIKit

class VibrationMotorConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ delaySeconds: Int, _ vibrationType: BCLVibrationMotorType) -> Void)?
    let disposeBag = DisposeBag()

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

    func setupUI() {
        layer.cornerRadius = 15
        layer.masksToBounds = true
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(delayTimeLabel)
        addSubview(delayTimeTextField)
        addSubview(vibrationTypeLabel)
        addSubview(vibrationTypeSegmentedControl)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        delayTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(120)
        }

        delayTimeTextField.snp.makeConstraints { make in
            make.centerY.equalTo(delayTimeLabel)
            make.left.equalTo(delayTimeLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        vibrationTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(delayTimeTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }

        vibrationTypeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(vibrationTypeLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(36)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(vibrationTypeSegmentedControl.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(vibrationTypeSegmentedControl.snp.bottom).offset(30)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    func setupDefaultValues() {
        // 设置默认值
        delayTimeTextField.text = "5"
        vibrationTypeSegmentedControl.selectedSegmentIndex = 1 // 默认持续震动
    }

    // MARK: - 懒加载

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "马达震动参数配置"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var delayTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "延迟时间:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var delayTimeTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "秒 (建议5-60秒)"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return textField
    }()

    lazy var vibrationTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "震动类型:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var vibrationTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["强力震动", "持续震动", "渐变震动"])
        segmentedControl.selectedSegmentIndex = 1
        return segmentedControl
    }()

    // 取消按钮
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

    // 确认按钮
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

    @objc func confirmButtonTapped() {
        guard let delayTimeText = delayTimeTextField.text,
              let delayTime = Int(delayTimeText),
              delayTime > 0 else {
            BDLogger.error("延迟时间输入不正确,必须大于0")
            return
        }

        // 根据选中的索引确定震动类型
        let vibrationType: BCLVibrationMotorType
        switch vibrationTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            vibrationType = .strongVibration
        case 1:
            vibrationType = .continuousVibration
        case 2:
            vibrationType = .gradientVibration
        default:
            vibrationType = .continuousVibration
        }

        let typeDescription = ["强力震动", "持续震动", "渐变震动"][vibrationTypeSegmentedControl.selectedSegmentIndex]
        BDLogger.info("马达震动配置 - 延迟时间:\(delayTime)秒, 震动类型:\(typeDescription)")
        confirmButtonCallback?(delayTime, vibrationType)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
