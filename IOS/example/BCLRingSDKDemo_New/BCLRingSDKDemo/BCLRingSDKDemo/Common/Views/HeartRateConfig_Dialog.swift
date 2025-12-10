//
//  HeartRateConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//

import BCLRingSDK
import QMUIKit
import RxSwift
import SnapKit
import UIKit

class HeartRateConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ collectTime: Int, _ collectFrequency: Int, _ waveformConfig: Int, _ progressConfig: Int, _ intervalConfig: Int) -> Void)?
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
        addSubview(collectTimeLabel)
        addSubview(collectTimeTextField)
        addSubview(collectFrequencyLabel)
        addSubview(collectFrequencyTextField)
        addSubview(waveformConfigLabel)
        addSubview(waveformConfigSwitch)
        addSubview(progressConfigLabel)
        addSubview(progressConfigSwitch)
        addSubview(intervalConfigLabel)
        addSubview(intervalConfigSwitch)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        collectTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(120)
        }

        collectTimeTextField.snp.makeConstraints { make in
            make.centerY.equalTo(collectTimeLabel)
            make.left.equalTo(collectTimeLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        collectFrequencyLabel.snp.makeConstraints { make in
            make.top.equalTo(collectTimeTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(120)
        }

        collectFrequencyTextField.snp.makeConstraints { make in
            make.centerY.equalTo(collectFrequencyLabel)
            make.left.equalTo(collectFrequencyLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        waveformConfigLabel.snp.makeConstraints { make in
            make.top.equalTo(collectFrequencyTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }

        waveformConfigSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(waveformConfigLabel)
            make.right.equalToSuperview().offset(-20)
        }

        progressConfigLabel.snp.makeConstraints { make in
            make.top.equalTo(waveformConfigLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }

        progressConfigSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(progressConfigLabel)
            make.right.equalToSuperview().offset(-20)
        }

        intervalConfigLabel.snp.makeConstraints { make in
            make.top.equalTo(progressConfigLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }

        intervalConfigSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(intervalConfigLabel)
            make.right.equalToSuperview().offset(-20)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(intervalConfigLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(intervalConfigLabel.snp.bottom).offset(30)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    func setupDefaultValues() {
        // 设置默认值
        collectTimeTextField.text = "30"
        collectFrequencyTextField.text = "25"
        waveformConfigSwitch.isOn = true // 默认开启 (1)
        progressConfigSwitch.isOn = true // 默认开启 (1)
        intervalConfigSwitch.isOn = true // 默认开启 (1)
    }

    // MARK: - 懒加载

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "心率测量参数配置"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var collectTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "采集时间:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var collectTimeTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "秒 (建议30)"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return textField
    }()

    lazy var collectFrequencyLabel: UILabel = {
        let label = UILabel()
        label.text = "采集频率:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var collectFrequencyTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "Hz (建议25)"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return textField
    }()

    lazy var waveformConfigLabel: UILabel = {
        let label = UILabel()
        label.text = "波形配置上传:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var waveformConfigSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .blue
        return switchControl
    }()

    lazy var progressConfigLabel: UILabel = {
        let label = UILabel()
        label.text = "进度配置:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var progressConfigSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .blue
        return switchControl
    }()

    lazy var intervalConfigLabel: UILabel = {
        let label = UILabel()
        label.text = "间期配置上传:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var intervalConfigSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .blue
        return switchControl
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
        guard let collectTimeText = collectTimeTextField.text,
              let collectTime = Int(collectTimeText),
              let collectFrequencyText = collectFrequencyTextField.text,
              let collectFrequency = Int(collectFrequencyText) else {
            BDLogger.error("参数输入不正确")
            return
        }

        // Switch 状态转换为 0/1
        let waveformConfig = waveformConfigSwitch.isOn ? 1 : 0
        let progressConfig = progressConfigSwitch.isOn ? 1 : 0
        let intervalConfig = intervalConfigSwitch.isOn ? 1 : 0

        BDLogger.info("心率测量配置 - 采集时间:\(collectTime), 采集频率:\(collectFrequency), 波形配置:\(waveformConfig), 进度配置:\(progressConfig), 间期配置:\(intervalConfig)")
        confirmButtonCallback?(collectTime, collectFrequency, waveformConfig, progressConfig, intervalConfig)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
