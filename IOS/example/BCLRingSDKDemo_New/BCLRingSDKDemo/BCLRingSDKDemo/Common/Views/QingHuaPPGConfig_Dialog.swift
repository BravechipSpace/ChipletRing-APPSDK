//
//  QingHuaPPGConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by Codex on 2026/3/12.
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class QingHuaPPGConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ collectTime: Int,
                                 _ collectFrequency: Int,
                                 _ greenLEDCurrent: Int,
                                 _ infraredLEDCurrent: Int,
                                 _ redLEDCurrent: Int,
                                 _ progressConfig: Int,
                                 _ waveformConfig: Int) -> Void)?

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
        layer.cornerRadius = 15
        layer.masksToBounds = true
        backgroundColor = .white

        addSubview(titleLabel)
        addSubview(collectTimeLabel)
        addSubview(collectTimeTextField)
        addSubview(collectFrequencyLabel)
        addSubview(collectFrequencyTextField)
        addSubview(greenLEDCurrentLabel)
        addSubview(greenLEDCurrentTextField)
        addSubview(infraredLEDCurrentLabel)
        addSubview(infraredLEDCurrentTextField)
        addSubview(redLEDCurrentLabel)
        addSubview(redLEDCurrentTextField)
        addSubview(progressConfigLabel)
        addSubview(progressConfigSwitch)
        addSubview(waveformConfigLabel)
        addSubview(waveformConfigSwitch)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        collectTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(130)
        }

        collectTimeTextField.snp.makeConstraints { make in
            make.centerY.equalTo(collectTimeLabel)
            make.left.equalTo(collectTimeLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        collectFrequencyLabel.snp.makeConstraints { make in
            make.top.equalTo(collectTimeTextField.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(130)
        }

        collectFrequencyTextField.snp.makeConstraints { make in
            make.centerY.equalTo(collectFrequencyLabel)
            make.left.equalTo(collectFrequencyLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        greenLEDCurrentLabel.snp.makeConstraints { make in
            make.top.equalTo(collectFrequencyTextField.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(130)
        }

        greenLEDCurrentTextField.snp.makeConstraints { make in
            make.centerY.equalTo(greenLEDCurrentLabel)
            make.left.equalTo(greenLEDCurrentLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        infraredLEDCurrentLabel.snp.makeConstraints { make in
            make.top.equalTo(greenLEDCurrentTextField.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(130)
        }

        infraredLEDCurrentTextField.snp.makeConstraints { make in
            make.centerY.equalTo(infraredLEDCurrentLabel)
            make.left.equalTo(infraredLEDCurrentLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        redLEDCurrentLabel.snp.makeConstraints { make in
            make.top.equalTo(infraredLEDCurrentTextField.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(130)
        }

        redLEDCurrentTextField.snp.makeConstraints { make in
            make.centerY.equalTo(redLEDCurrentLabel)
            make.left.equalTo(redLEDCurrentLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        progressConfigLabel.snp.makeConstraints { make in
            make.top.equalTo(redLEDCurrentTextField.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
        }

        progressConfigSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(progressConfigLabel)
            make.right.equalToSuperview().offset(-20)
        }

        waveformConfigLabel.snp.makeConstraints { make in
            make.top.equalTo(progressConfigLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
        }

        waveformConfigSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(waveformConfigLabel)
            make.right.equalToSuperview().offset(-20)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(waveformConfigLabel.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(waveformConfigLabel.snp.bottom).offset(28)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    private func setupDefaultValues() {
        collectTimeTextField.text = "30"
        collectFrequencyTextField.text = "25"
        greenLEDCurrentTextField.text = "20"
        infraredLEDCurrentTextField.text = "20"
        redLEDCurrentTextField.text = "20"
        progressConfigSwitch.isOn = true
        waveformConfigSwitch.isOn = true
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "清华实时PPG参数配置"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private lazy var collectTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "采集时间:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var collectTimeTextField: QMUITextField = makeNumberField(placeholder: "秒 (默认30)")

    private lazy var collectFrequencyLabel: UILabel = {
        let label = UILabel()
        label.text = "采集频率:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var collectFrequencyTextField: QMUITextField = makeNumberField(placeholder: "Hz (默认25)")

    private lazy var greenLEDCurrentLabel: UILabel = {
        let label = UILabel()
        label.text = "绿灯电流:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var greenLEDCurrentTextField: QMUITextField = makeNumberField(placeholder: "默认20")

    private lazy var infraredLEDCurrentLabel: UILabel = {
        let label = UILabel()
        label.text = "红外灯电流:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var infraredLEDCurrentTextField: QMUITextField = makeNumberField(placeholder: "默认20")

    private lazy var redLEDCurrentLabel: UILabel = {
        let label = UILabel()
        label.text = "红灯电流:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var redLEDCurrentTextField: QMUITextField = makeNumberField(placeholder: "0-50, 默认20")

    private lazy var progressConfigLabel: UILabel = {
        let label = UILabel()
        label.text = "进度上传:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var progressConfigSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .blue
        return switchControl
    }()

    private lazy var waveformConfigLabel: UILabel = {
        let label = UILabel()
        label.text = "波形上传:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var waveformConfigSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .blue
        return switchControl
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
        button.backgroundColor = .blue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc private func confirmButtonTapped() {
        guard let collectTime = parseInteger(from: collectTimeTextField),
              let collectFrequency = parseInteger(from: collectFrequencyTextField),
              let greenLEDCurrent = parseInteger(from: greenLEDCurrentTextField),
              let infraredLEDCurrent = parseInteger(from: infraredLEDCurrentTextField),
              let redLEDCurrent = parseInteger(from: redLEDCurrentTextField) else {
            showError("参数不能为空且必须为整数")
            return
        }

        guard (0 ... Int(UInt8.max)).contains(collectTime) else {
            showError("采集时间范围应为 0-255")
            return
        }
        guard (0 ... Int(UInt8.max)).contains(collectFrequency) else {
            showError("采集频率范围应为 0-255")
            return
        }
        guard (0 ... Int(UInt8.max)).contains(greenLEDCurrent) else {
            showError("绿灯电流范围应为 0-255")
            return
        }
        guard (0 ... Int(UInt8.max)).contains(infraredLEDCurrent) else {
            showError("红外灯电流范围应为 0-255")
            return
        }
        guard (0 ... 50).contains(redLEDCurrent) else {
            showError("红灯电流范围应为 0-50")
            return
        }

        let progressConfig = progressConfigSwitch.isOn ? 1 : 0
        let waveformConfig = waveformConfigSwitch.isOn ? 1 : 0

        BDLogger.info("""
        清华实时PPG测量配置 - 采集时间:\(collectTime), 采集频率:\(collectFrequency), \
        绿灯电流:\(greenLEDCurrent), 红外灯电流:\(infraredLEDCurrent), 红灯电流:\(redLEDCurrent), \
        进度配置:\(progressConfig), 波形配置:\(waveformConfig)
        """)

        confirmButtonCallback?(collectTime,
                               collectFrequency,
                               greenLEDCurrent,
                               infraredLEDCurrent,
                               redLEDCurrent,
                               progressConfig,
                               waveformConfig)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc private func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    private func makeNumberField(placeholder: String) -> QMUITextField {
        let textField = QMUITextField()
        textField.placeholder = placeholder
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return textField
    }

    private func parseInteger(from textField: QMUITextField) -> Int? {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              let value = Int(text) else {
            return nil
        }
        return value
    }

    private func showError(_ message: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            QMUITips.showError(message, in: window)
        }
        BDLogger.error(message)
    }
}
