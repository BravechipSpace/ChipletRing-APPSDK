//
//  FirmwareCategoryConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by Claude Code on 2025/12/17.
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

class FirmwareCategoryConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ category: String) -> Void)?

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
        addSubview(categoryLabel)
        addSubview(categoryTextField)
        addSubview(hintLabel)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        categoryTextField.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryTextField.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(25)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    func setupDefaultValues() {
        categoryTextField.text = "Z2Y"
    }

    // MARK: - Lazy Properties

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "查询固件版本历史列表"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "查询参数 (category):"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var categoryTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "请输入查询参数"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        textField.autocapitalizationType = .allCharacters
        return textField
    }()

    lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "示例: Z2Y / Z3R / Z3N / Z47"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

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

    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("查询", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc func confirmButtonTapped() {
        guard let category = categoryTextField.text, !category.isEmpty else {
            BDLogger.error("查询参数不能为空")
            return
        }

        BDLogger.info("查询固件版本列表 - category:\(category)")
        confirmButtonCallback?(category)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
