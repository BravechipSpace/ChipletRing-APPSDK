//
//  AppDelegate.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/3/18.
//

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

        return true
    }
}
