//
//  FloatingWindowManager.swift
//  BCLRingSDKDemo
//
//  悬浮窗管理器
//

import BCLRingSDK
import UIKit

class FloatingWindowManager {
    // MARK: - Singleton

    static let shared = FloatingWindowManager()

    // MARK: - Properties

    /// 悬浮窗口
    private var floatingWindow: PassThroughWindow?

    /// 悬浮视图
    private var floatingView: FloatingStatusView?

    /// 是否正在显示
    private var isShowing = false

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// 显示悬浮窗
    func show() {
        guard !isShowing else { return }

        // 创建 Window
        floatingWindow = PassThroughWindow(frame: UIScreen.main.bounds)
        floatingWindow?.backgroundColor = .clear
        floatingWindow?.windowLevel = .alert + 1
        floatingWindow?.rootViewController = UIViewController()
        floatingWindow?.rootViewController?.view.backgroundColor = .clear
        floatingWindow?.isHidden = false

        // 创建悬浮视图
        let floatingFrame = CGRect(x: UIScreen.main.bounds.width - 160,
                                   y: 100,
                                   width: 140,
                                   height: 50)
        floatingView = FloatingStatusView(frame: floatingFrame)

        // 设置点击回调
        floatingView?.onTapToShowLog = { [weak self] in
            self?.showLogViewController()
        }

        // 添加到 Window
        if let floatingView = floatingView {
            floatingWindow?.addSubview(floatingView)
        }

        // 添加进入动画
        floatingView?.alpha = 0
        floatingView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut) {
            self.floatingView?.alpha = 1
            self.floatingView?.transform = .identity
        }

        isShowing = true
    }

    /// 隐藏悬浮窗
    func hide() {
        guard isShowing else { return }

        // 添加退出动画
        UIView.animate(withDuration: 0.3, animations: {
            self.floatingView?.alpha = 0
            self.floatingView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.floatingView?.removeFromSuperview()
            self.floatingView = nil
            self.floatingWindow?.isHidden = true
            self.floatingWindow = nil
            self.isShowing = false
        }
    }

    /// 切换显示/隐藏
    func toggle() {
        if isShowing {
            hide()
        } else {
            show()
        }
    }

    // MARK: - Private Methods

    /// 显示日志视图控制器
    private func showLogViewController() {
        guard let topViewController = getTopViewController() else {
            BDLogger.error("无法获取顶层视图控制器")
            return
        }

        let logVC = LogDisplayViewController()
        logVC.modalPresentationStyle = .overFullScreen
        logVC.modalTransitionStyle = .crossDissolve

        topViewController.present(logVC, animated: true) {}
    }

    /// 获取顶层视图控制器
    private func getTopViewController() -> UIViewController? {
        // 获取主窗口
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }

        guard let rootViewController = keyWindow?.rootViewController else {
            return nil
        }

        return getTopViewController(from: rootViewController)
    }

    /// 递归获取顶层视图控制器
    private func getTopViewController(from viewController: UIViewController) -> UIViewController {
        // 如果是导航控制器
        if let navigationController = viewController as? UINavigationController {
            return getTopViewController(from: navigationController.visibleViewController ?? navigationController)
        }

        // 如果是标签栏控制器
        if let tabBarController = viewController as? UITabBarController {
            return getTopViewController(from: tabBarController.selectedViewController ?? tabBarController)
        }

        // 如果有 presented 视图控制器
        if let presentedViewController = viewController.presentedViewController {
            return getTopViewController(from: presentedViewController)
        }

        // 返回当前控制器
        return viewController
    }
}
