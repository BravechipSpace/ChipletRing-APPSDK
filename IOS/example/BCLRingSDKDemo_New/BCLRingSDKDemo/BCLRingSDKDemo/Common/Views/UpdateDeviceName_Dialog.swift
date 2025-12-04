//
//  UpdateDeviceName_Dialog.swift
//  Rings
//
//  Created by JianDan on 2025/4/18.
//

import BCLRingSDK
import QMUIKit
import RxSwift
import SnapKit
import UIKit

class UpdateDeviceName_Dialog: UIView {
    var confirmButtonCallback: ((_ name: String) -> Void)?
    let disposeBag = DisposeBag()
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
        addSubview(tipsLabel)
        addSubview(nameTextField)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    func setupConstraints() {
        tipsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(tipsLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(25)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    // MARK: - 懒加载

    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.text = "presentation"
        label.textColor = .black
        return label
    }()

    // 昵称输入框
    lazy var nameTextField: QMUITextField = {
        let textField = QMUITextField()
        textField.placeholder = "Please enter a Bluetooth name"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = .gray.withAlphaComponent(0.2)
        return textField
    }()

    // 取消按钮
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
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
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc func confirmButtonTapped() {
        guard let name = nameTextField.text else { return }
        BDLogger.info("Update Bluetooth device name-\(name)")
        confirmButtonCallback?(name)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
