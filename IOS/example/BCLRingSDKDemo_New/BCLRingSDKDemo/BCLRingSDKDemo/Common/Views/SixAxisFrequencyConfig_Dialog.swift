//
//  SixAxisFrequencyConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/24.
//

import BCLRingSDK
import QMUIKit
import RxSwift
import SnapKit
import UIKit

class SixAxisFrequencyConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ frequency: Int) -> Void)?
    let disposeBag = DisposeBag()

    // 可选的频率值
    private let frequencies = [25, 50, 100, 150, 200]
    private var selectedFrequency: Int = 100 // 默认选择 100Hz

    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
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
        addSubview(frequencyLabel)
        addSubview(frequencySegmentedControl)
        addSubview(noteLabel)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(20)
        }

        frequencyLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }

        frequencySegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(frequencyLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        noteLabel.snp.makeConstraints { make in
            make.top.equalTo(frequencySegmentedControl.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(20)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(noteLabel.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(noteLabel.snp.bottom).offset(25)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    // MARK: - 懒加载

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "六轴传感器工作频率配置"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "设置加速度计和陀螺仪的工作频率"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    lazy var frequencyLabel: UILabel = {
        let label = UILabel()
        label.text = "选择频率 (Hz):"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var frequencySegmentedControl: UISegmentedControl = {
        let items = frequencies.map { "\($0)" }
        let segmented = UISegmentedControl(items: items)
        segmented.selectedSegmentIndex = 2 // 默认选中 100Hz (索引2)
        segmented.addTarget(self, action: #selector(frequencyChanged(_:)), for: .valueChanged)
        return segmented
    }()

    lazy var noteLabel: UILabel = {
        let label = UILabel()
        label.text = "注意：加速度计和陀螺仪将使用相同频率"
        label.textColor = .systemOrange
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
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

    // MARK: - Actions

    @objc func frequencyChanged(_ sender: UISegmentedControl) {
        selectedFrequency = frequencies[sender.selectedSegmentIndex]
        BDLogger.info("选择频率: \(selectedFrequency)Hz")
    }

    @objc func confirmButtonTapped() {
        BDLogger.info("六轴传感器频率配置 - 频率:\(selectedFrequency)Hz")
        confirmButtonCallback?(selectedFrequency)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
