//
//  GestureFunctionConfig_Dialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/12/12.
//  手势功能配置对话框 - Z4I定制功能
//

import BCLRingSDK
import QMUIKit
import RxSwift
import SnapKit
import UIKit

class GestureFunctionConfig_Dialog: UIView {
    var confirmButtonCallback: ((_ swipeUp: Int, _ swipeDown: Int, _ snap: Int, _ pinch: Int) -> Void)?
    let disposeBag = DisposeBag()

    // 手势功能选项: 1:音乐暂停/开始、2:音乐下一首、3:音乐上一首、4:音量+、5:音量-、6:拍照、255:关闭
    private let gestureFunctions: [(value: Int, name: String)] = [
        (1, "音乐暂停/开始"),
        (2, "音乐下一首"),
        (3, "音乐上一首"),
        (4, "音量+"),
        (5, "音量-"),
        (6, "拍照"),
        (255, "关闭")
    ]

    // 当前选择的手势功能值
    private var selectedSwipeUp: Int = 1        // 上滑手势,默认:音乐暂停/开始
    private var selectedSwipeDown: Int = 2      // 下滑手势,默认:音乐下一首
    private var selectedSnap: Int = 6           // 打响指手势,默认:拍照
    private var selectedPinch: Int = 6          // 捏一捏手势,默认:拍照

    weak var presentingViewController: UIViewController?

    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        updateButtonTitles()
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
        addSubview(swipeUpLabel)
        addSubview(swipeUpButton)
        addSubview(swipeDownLabel)
        addSubview(swipeDownButton)
        addSubview(snapLabel)
        addSubview(snapButton)
        addSubview(pinchLabel)
        addSubview(pinchButton)
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
            make.left.right.equalToSuperview().inset(20)
        }

        swipeUpLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(90)
        }

        swipeUpButton.snp.makeConstraints { make in
            make.centerY.equalTo(swipeUpLabel)
            make.left.equalTo(swipeUpLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(36)
        }

        swipeDownLabel.snp.makeConstraints { make in
            make.top.equalTo(swipeUpButton.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(90)
        }

        swipeDownButton.snp.makeConstraints { make in
            make.centerY.equalTo(swipeDownLabel)
            make.left.equalTo(swipeDownLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(36)
        }

        snapLabel.snp.makeConstraints { make in
            make.top.equalTo(swipeDownButton.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(90)
        }

        snapButton.snp.makeConstraints { make in
            make.centerY.equalTo(snapLabel)
            make.left.equalTo(snapLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(36)
        }

        pinchLabel.snp.makeConstraints { make in
            make.top.equalTo(snapButton.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(90)
        }

        pinchButton.snp.makeConstraints { make in
            make.centerY.equalTo(pinchLabel)
            make.left.equalTo(pinchLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(36)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(pinchButton.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(confirmButton.snp.width)
            make.bottom.equalToSuperview().offset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(pinchButton.snp.bottom).offset(25)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    // MARK: - 懒加载

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "手势功能配置"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "配置4种手势的功能映射 (Z4I定制)"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    lazy var swipeUpLabel: UILabel = {
        let label = UILabel()
        label.text = "上滑手势:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var swipeUpButton: UIButton = {
        let button = createSelectButton()
        button.tag = 1
        button.addTarget(self, action: #selector(selectGestureTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var swipeDownLabel: UILabel = {
        let label = UILabel()
        label.text = "下滑手势:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var swipeDownButton: UIButton = {
        let button = createSelectButton()
        button.tag = 2
        button.addTarget(self, action: #selector(selectGestureTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var snapLabel: UILabel = {
        let label = UILabel()
        label.text = "打响指:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var snapButton: UIButton = {
        let button = createSelectButton()
        button.tag = 3
        button.addTarget(self, action: #selector(selectGestureTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var pinchLabel: UILabel = {
        let label = UILabel()
        label.text = "捏一捏:"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var pinchButton: UIButton = {
        let button = createSelectButton()
        button.tag = 4
        button.addTarget(self, action: #selector(selectGestureTapped(_:)), for: .touchUpInside)
        return button
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

    // MARK: - 辅助方法

    /// 创建选择按钮样式
    private func createSelectButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }

    /// 更新按钮标题显示当前选择
    private func updateButtonTitles() {
        swipeUpButton.setTitle(getFunctionName(selectedSwipeUp), for: .normal)
        swipeDownButton.setTitle(getFunctionName(selectedSwipeDown), for: .normal)
        snapButton.setTitle(getFunctionName(selectedSnap), for: .normal)
        pinchButton.setTitle(getFunctionName(selectedPinch), for: .normal)
    }

    /// 根据功能值获取功能名称
    private func getFunctionName(_ value: Int) -> String {
        return gestureFunctions.first(where: { $0.value == value })?.name ?? "未知"
    }

    // MARK: - Actions

    /// 点击手势选择按钮
    @objc func selectGestureTapped(_ sender: UIButton) {
        // 获取当前顶层的ViewController
        guard let vc = getTopViewController() else {
            BDLogger.error("无法获取顶层ViewController")
            return
        }

        let alert = UIAlertController(title: "选择手势功能", message: nil, preferredStyle: .actionSheet)

        // 添加所有手势功能选项
        for function in gestureFunctions {
            let action = UIAlertAction(title: function.name, style: .default) { [weak self] _ in
                guard let self = self else { return }
                switch sender.tag {
                case 1: // 上滑
                    self.selectedSwipeUp = function.value
                case 2: // 下滑
                    self.selectedSwipeDown = function.value
                case 3: // 打响指
                    self.selectedSnap = function.value
                case 4: // 捏一捏
                    self.selectedPinch = function.value
                default:
                    break
                }
                self.updateButtonTitles()
            }
            alert.addAction(action)
        }

        // 添加取消按钮
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))

        // iPad支持
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }

        vc.present(alert, animated: true)
    }

    /// 获取当前顶层的ViewController
    private func getTopViewController() -> UIViewController? {
        // 优先查找QMUIModalPresentationWindow (这是QMUI创建的最顶层window)
        let allWindows = UIApplication.shared.windows

        // 查找QMUIModalPresentationWindow
        if let modalWindow = allWindows.first(where: {
            String(describing: type(of: $0)).contains("QMUIModalPresentationWindow") && $0.isKeyWindow
        }) {
            if let rootVC = modalWindow.rootViewController {
                BDLogger.info("找到QMUIModalPresentationWindow的rootViewController")
                return getTopViewController(from: rootVC)
            }
        }

        // 如果没有找到，尝试从presentingViewController获取
        if let vc = presentingViewController {
            return getTopViewController(from: vc)
        }

        // 最后从keyWindow获取
        guard let window = allWindows.first(where: { $0.isKeyWindow }) else {
            return nil
        }

        guard let rootVC = window.rootViewController else {
            return nil
        }

        return getTopViewController(from: rootVC)
    }

    /// 递归获取顶层的ViewController
    private func getTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return getTopViewController(from: presented)
        }

        if let navigationController = viewController as? UINavigationController {
            if let visible = navigationController.visibleViewController {
                return getTopViewController(from: visible)
            }
        }

        if let tabBarController = viewController as? UITabBarController {
            if let selected = tabBarController.selectedViewController {
                return getTopViewController(from: selected)
            }
        }

        return viewController
    }

    @objc func confirmButtonTapped() {
        BDLogger.info("手势功能配置 - 上滑:\(selectedSwipeUp), 下滑:\(selectedSwipeDown), 打响指:\(selectedSnap), 捏一捏:\(selectedPinch)")
        confirmButtonCallback?(selectedSwipeUp, selectedSwipeDown, selectedSnap, selectedPinch)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func cancelButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }
}
