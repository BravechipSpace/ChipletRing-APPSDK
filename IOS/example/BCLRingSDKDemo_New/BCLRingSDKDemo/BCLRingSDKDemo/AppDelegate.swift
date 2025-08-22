//
//  AppDelegate.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/3/18.
//

import BCLRingSDK
import QMUIKit
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let initialVC = storyboard.instantiateInitialViewController() else {
            fatalError("无法从 Main.storyboard 实例化初始控制器")
        }
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
        
        // 配置网络地址（国外地址：.overseas、国内地址：.domestic（默认））
//        BCLRingManager.shared.networkRegion = .overseas

        //  检查蓝牙权限
        BCLRingManager.shared.checkBluetoothPermission { auth in
            switch auth {
            case .allowedAlways:
                BDLogger.info("蓝牙权限：已授权")
            case .denied:
                BDLogger.info("蓝牙权限：未授权")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let alertController = UIAlertController(title: "系统蓝牙权限受限，请检查！", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                    }))
                    UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            case .notDetermined:
                BDLogger.info("蓝牙权限：未确定")
            case .restricted:
                BDLogger.info("蓝牙权限：受限")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let alertController = UIAlertController(title: "系统蓝牙权限受限，请检查！", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                    }))
                    UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            default:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    QMUITips.show(withText: "蓝牙已断开", in: self.window?.rootViewController?.view ?? UIView(), hideAfterDelay: 1.5)
                }
                break
            }
        }
        return true
    }
}
