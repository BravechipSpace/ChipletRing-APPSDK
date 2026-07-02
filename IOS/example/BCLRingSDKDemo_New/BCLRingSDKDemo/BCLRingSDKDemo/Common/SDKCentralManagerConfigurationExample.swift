//
//  SDKCentralManagerConfigurationExample.swift
//  BCLRingSDKDemo
//
//  Created by Codex on 2026/7/1.
//

import BCLRingSDK
import CoreBluetooth
import UIKit

/// SDK初始化配置示例：必须在首次初始化 CBCentralManager 前调用。
enum SDKCentralManagerConfigurationExample {
    private static let restoreIdentifier = "com.bravechip.BCLRingSDKDemo.centralManager.restore"

    static func applyBeforeSDKInitialization() {
        let options: [String: Any] = [
            CBCentralManagerOptionRestoreIdentifierKey: restoreIdentifier,
            CBCentralManagerOptionShowPowerAlertKey: true
        ]

        let isApplied = BCLRingManager.shared.configureCentralManagerInitialization(queue: nil, options: options)
        if isApplied {
            BDLogger.info("CBCentralManager初始化配置示例已应用，restoreIdentifier：\(restoreIdentifier)")
        } else {
            BDLogger.error("CBCentralManager初始化配置示例未应用：CBCentralManager可能已经初始化")
        }
    }

    static func presentStatus(from viewController: UIViewController) {
        let lateOptions: [String: Any] = [
            CBCentralManagerOptionRestoreIdentifierKey: "\(restoreIdentifier).late-check"
        ]
        let lateApplyResult = BCLRingManager.shared.configureCentralManagerInitialization(queue: nil, options: lateOptions)

        let message = """
        启动时示例已在 AppDelegate 中调用：
        BCLRingManager.shared.configureCentralManagerInitialization(queue: nil, options: options)

        当前示例 options：
        \(CBCentralManagerOptionRestoreIdentifierKey): \(restoreIdentifier)
        \(CBCentralManagerOptionShowPowerAlertKey): true

        该配置必须在首次初始化 CBCentralManager 前调用。
        当前页面再次配置的返回值：\(lateApplyResult)
        已初始化后返回 false 属于预期行为，SDK不会重建CBCentralManager。
        """

        let alert = UIAlertController(
            title: "CBCentralManager初始化配置示例",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        viewController.present(alert, animated: true)
    }
}
