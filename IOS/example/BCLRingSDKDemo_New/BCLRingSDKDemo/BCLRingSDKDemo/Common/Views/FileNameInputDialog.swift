//
//  FileNameInputDialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/27.
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class FileNameInputDialog: UIView {
    var confirmButtonCallback: ((_ fileName: String) -> Void)?

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
        addSubview(fileNameLabel)
        addSubview(fileNameTextField)
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

        fileNameLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }

        fileNameTextField.snp.makeConstraints { make in
            make.top.equalTo(fileNameLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(fileNameTextField.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(fileNameTextField.snp.bottom).offset(30)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    // MARK: - 懒加载

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "获取文件数据"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "请输入要获取的文件名称"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.text = "文件名:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var fileNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "例如: 010203040506_2025_08_25_16_30_37_7.txt"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
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
        guard let fileName = fileNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !fileName.isEmpty else {
            BDLogger.warning("文件名不能为空")
            // 可以添加抖动动画提示
            shakeTextField()
            return
        }

        BDLogger.info("获取文件数据 - 文件名: \(fileName)")
        confirmButtonCallback?(fileName)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    // MARK: - Private Methods

    /// 抖动动画提示
    private func shakeTextField() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10, 10, -10, 10, -5, 5, -2, 2, 0]
        fileNameTextField.layer.add(animation, forKey: "shake")
    }
}
