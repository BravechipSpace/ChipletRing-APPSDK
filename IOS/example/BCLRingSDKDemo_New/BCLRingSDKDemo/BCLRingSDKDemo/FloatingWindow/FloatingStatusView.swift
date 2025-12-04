//
//  FloatingStatusView.swift
//  BCLRingSDKDemo
//
//  蓝牙连接状态悬浮视图
//

import UIKit
import SnapKit
import BCLRingSDK
import QMUIKit

class FloatingStatusView: UIView {

    // MARK: - Properties

    /// 状态标签
    private let statusLabel = UILabel()

    /// 状态指示器（圆点）
    private let statusIndicator = UIView()

    /// 设备名称标签
    private let deviceNameLabel = UILabel()

    /// 容器视图
    private let containerView = UIView()

    /// 拖动手势
    private var panGesture: UIPanGestureRecognizer!

    /// 单击手势（用于打开日志）
    private var tapGesture: UITapGestureRecognizer!

    /// 最后的有效位置
    private var lastValidFrame: CGRect = .zero

    /// 日志弹窗回调
    var onTapToShowLog: (() -> Void)?

    /// 当前连接状态
    private var currentConnectionState: ConnectionState = .disconnected

    /// 连接状态枚举
    enum ConnectionState {
        case disconnected
        case connecting
        case connected
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
        setupBluetoothStateObserver()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // 清理回调Block，避免循环引用
        BCLRingManager.shared.deviceIsDidConnectedBlock = nil
    }

    // MARK: - Setup UI

    private func setupUI() {
        // 设置容器视图
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        containerView.layer.borderWidth = 1
        addSubview(containerView)

        // 添加阴影
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4

        // 状态指示器（圆点）
        statusIndicator.layer.cornerRadius = 5
        statusIndicator.backgroundColor = .systemRed
        statusIndicator.layer.shadowColor = UIColor.red.cgColor
        statusIndicator.layer.shadowOpacity = 0.8
        statusIndicator.layer.shadowRadius = 3
        containerView.addSubview(statusIndicator)

        // 状态标签
        statusLabel.textColor = .white
        statusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusLabel.textAlignment = .left
        statusLabel.text = "未连接"
        containerView.addSubview(statusLabel)

        // 设备名称标签
        deviceNameLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        deviceNameLabel.font = .systemFont(ofSize: 10)
        deviceNameLabel.textAlignment = .left
        deviceNameLabel.text = "点击查看日志"
        containerView.addSubview(deviceNameLabel)

        // 添加日志图标
        let logIcon = UIImageView()
        logIcon.image = UIImage(systemName: "doc.text.magnifyingglass")
        logIcon.tintColor = UIColor.white.withAlphaComponent(0.5)
        logIcon.contentMode = .scaleAspectFit
        containerView.addSubview(logIcon)

        // 设置约束
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        statusIndicator.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(10)
        }

        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(statusIndicator.snp.right).offset(8)
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-40)
        }

        deviceNameLabel.snp.makeConstraints { make in
            make.left.equalTo(statusIndicator.snp.right).offset(8)
            make.top.equalTo(statusLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(-8)
        }

        logIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        // 添加脉冲动画效果
        addPulseAnimation()
    }

    // MARK: - Setup Gestures

    private func setupGestures() {
        // 拖动手势
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)

        // 单击手势（打开日志）
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    // MARK: - Bluetooth State Monitoring

    /// 设置蓝牙连接状态监听
    private func setupBluetoothStateObserver() {
        // 使用SDK提供的deviceIsDidConnectedBlock简化状态回调（未连接、连接中、连接成功）
        BCLRingManager.shared.deviceIsDidConnectedBlock = { [weak self] simpleState in
            guard let self = self else { return }

            // 确保在主线程更新UI
            DispatchQueue.main.async {
                // 根据SDK返回的简化状态更新UI
                switch simpleState {
                case .disconnected:
                    // 设备未连接
                    self.updateConnectionState(.disconnected)
                    self.updateDeviceInfo(nil)

                case .connecting:
                    // 设备连接中
                    self.updateConnectionState(.connecting)
                    // 连接中时也尝试获取设备信息
                    self.updateDeviceInfo(BCLRingManager.shared.currentConnectedDevice)

                case .connected:
                    // 设备已连接
                    self.updateConnectionState(.connected)
                    self.updateDeviceInfo(BCLRingManager.shared.currentConnectedDevice)

                @unknown default:
                    // 处理未来可能新增的状态
                    self.updateConnectionState(.disconnected)
                    self.updateDeviceInfo(nil)
                }
            }
        }
    }

    // MARK: - Update UI

    private func updateConnectionState(_ state: ConnectionState) {
        guard currentConnectionState != state else { return }
        currentConnectionState = state

        switch state {
        case .disconnected:
            statusLabel.text = "未连接"
            statusIndicator.backgroundColor = .systemRed
            deviceNameLabel.text = "点击查看日志"
            removePulseAnimation()

        case .connecting:
            statusLabel.text = "连接中..."
            statusIndicator.backgroundColor = .systemOrange
            addPulseAnimation()

        case .connected:
            statusLabel.text = "已连接"
            statusIndicator.backgroundColor = .systemGreen
            removePulseAnimation()
        }

        // 更新阴影颜色
        statusIndicator.layer.shadowColor = statusIndicator.backgroundColor?.cgColor
    }

    private func updateDeviceInfo(_ deviceInfo: BCLDeviceInfoModel?) {
        if let info = deviceInfo {
            var deviceText = ""

            // 设备名称
            if let name = info.peripheralName, !name.isEmpty {
                deviceText = name
            }

            // MAC地址
            if let mac = info.macAddress, !mac.isEmpty {
                deviceText = deviceText.isEmpty ? mac : "\(deviceText)"
            }

            // RSSI
            if let rssi = info.rssi {
                deviceText = deviceText.isEmpty ? "RSSI: \(rssi)" : "\(deviceText) • \(rssi)dB"
            }

            deviceNameLabel.text = deviceText.isEmpty ? "点击查看日志" : deviceText
        } else {
            deviceNameLabel.text = "点击查看日志"
        }
    }

    // MARK: - Animations

    private func addPulseAnimation() {
        removePulseAnimation()

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.3
        animation.duration = 0.8
        animation.autoreverses = true
        animation.repeatCount = .infinity
        statusIndicator.layer.add(animation, forKey: "pulse")
    }

    private func removePulseAnimation() {
        statusIndicator.layer.removeAnimation(forKey: "pulse")
    }

    // MARK: - Gesture Handlers

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = self.superview else { return }

        let translation = gesture.translation(in: window)
        let newCenter = CGPoint(
            x: center.x + translation.x,
            y: center.y + translation.y
        )

        switch gesture.state {
        case .began:
            // 记录开始位置
            lastValidFrame = frame

            // 添加缩放动画
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.alpha = 0.9
            }

        case .changed:
            // 更新位置（带边界检查）
            let halfWidth = bounds.width / 2
            let halfHeight = bounds.height / 2
            let minX = halfWidth
            let maxX = window.bounds.width - halfWidth
            let minY = halfHeight + (window.safeAreaInsets.top > 0 ? window.safeAreaInsets.top : 20)
            let maxY = window.bounds.height - halfHeight - (window.safeAreaInsets.bottom > 0 ? window.safeAreaInsets.bottom : 20)

            center = CGPoint(
                x: min(maxX, max(minX, newCenter.x)),
                y: min(maxY, max(minY, newCenter.y))
            )

        case .ended, .cancelled:
            // 恢复缩放
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
                self.alpha = 1.0
            }

            // 吸附到边缘
            snapToEdge(in: window)

        default:
            break
        }

        gesture.setTranslation(.zero, in: window)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // 添加点击反馈动画
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }

        // 触发回调打开日志弹窗
        onTapToShowLog?()
    }

    // MARK: - Helper Methods

    private func snapToEdge(in view: UIView) {
        let padding: CGFloat = 10
        var finalCenter = center

        // 判断靠近哪一边
        if center.x < view.bounds.width / 2 {
            // 靠左
            finalCenter.x = bounds.width / 2 + padding
        } else {
            // 靠右
            finalCenter.x = view.bounds.width - bounds.width / 2 - padding
        }

        // 边界检查
        let minY = bounds.height / 2 + (view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 20)
        let maxY = view.bounds.height - bounds.height / 2 - (view.safeAreaInsets.bottom > 0 ? view.safeAreaInsets.bottom : 20)
        finalCenter.y = min(maxY, max(minY, finalCenter.y))

        // 动画吸附
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            self.center = finalCenter
        })
    }
}
