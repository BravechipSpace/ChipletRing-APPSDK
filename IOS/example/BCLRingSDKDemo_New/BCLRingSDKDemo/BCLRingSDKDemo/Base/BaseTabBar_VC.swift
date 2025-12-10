//
//  BaseTabBar_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//

import UIKit

class BaseTabBar_VC: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewControllers()

        // 初始化悬浮窗
        FloatingWindowManager.shared.show()
    }

    // MARK: - Private Methods

    private func setupUI() {
        // 配置TabBar外观
        tabBar.tintColor = UIColor.systemBlue
        tabBar.unselectedItemTintColor = UIColor.systemGray
        tabBar.backgroundColor = UIColor.systemBackground

        // iOS 15及以上版本的TabBar外观配置
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.systemBackground
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    private func setupViewControllers() {
        // Tab 1: 功能示例
        let functionDemoVC = FunctionDemo_VC()
        let functionNav = BaseNavigation_VC(rootViewController: functionDemoVC)
        functionNav.tabBarItem = UITabBarItem(
            title: "功能示例",
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        // Tab 2: 场景示例
        let sceneDemoVC = SceneDemo_VC()
        let sceneNav = BaseNavigation_VC(rootViewController: sceneDemoVC)
        sceneNav.tabBarItem = UITabBarItem(
            title: "场景示例",
            image: UIImage(systemName: "square.stack.3d.up"),
            selectedImage: UIImage(systemName: "square.stack.3d.up.fill")
        )

        // Tab 3: 设置/工具
        let settingsVC = Settings_VC()
        let settingsNav = BaseNavigation_VC(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "设置",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )

        // 设置所有Tab页
        viewControllers = [functionNav, sceneNav, settingsNav]
    }
}
