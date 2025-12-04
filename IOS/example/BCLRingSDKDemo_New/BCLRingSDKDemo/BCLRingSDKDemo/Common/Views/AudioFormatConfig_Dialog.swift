//
//  AudioFormatConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/27.
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class AudioFormatConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ audioType: BCLAudioType) -> Void)?

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
        addSubview(descriptionLabel)
        addSubview(audioTypeLabel)
        addSubview(audioTypeSegmentedControl)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        audioTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }

        audioTypeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(audioTypeLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(36)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(audioTypeSegmentedControl.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(audioTypeSegmentedControl.snp.bottom).offset(30)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    func setupDefaultValues() {
        audioTypeSegmentedControl.selectedSegmentIndex = 0 // 默认 PCM
    }

    // MARK: - 懒加载

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "主动推送音频格式配置"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "选择设备主动推送音频数据的格式类型"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    lazy var audioTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "音频格式:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var audioTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["PCM", "ADPCM"])
        segmentedControl.selectedSegmentIndex = 0
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
        let audioType: BCLAudioType = audioTypeSegmentedControl.selectedSegmentIndex == 0 ? .pcm : .adpcm
        let typeDescription = audioTypeSegmentedControl.selectedSegmentIndex == 0 ? "PCM" : "ADPCM"
        BDLogger.info("音频格式配置 - 格式:\(typeDescription)")
        confirmButtonCallback?(audioType)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
