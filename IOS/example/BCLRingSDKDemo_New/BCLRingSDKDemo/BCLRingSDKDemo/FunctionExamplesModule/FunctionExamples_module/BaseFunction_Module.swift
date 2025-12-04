//
//  BaseFunction_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  功能模块基类 - 提供通用方法
//

import BCLRingSDK
import QMUIKit
import UIKit

/// 功能模块基类 - 提供通用的UI提示方法和错误处理
class BaseFunction_Module: NSObject, FunctionProtocol_Module {
    // MARK: - Properties

    /// 当前所在的ViewController
    weak var viewController: UIViewController?

    /// loading视图
    var tipsView: QMUITips?

    /// 该模块负责的功能ID范围
    var functionIdRange: ClosedRange<Int>

    // MARK: - Initialization

    init(functionIdRange: ClosedRange<Int>) {
        self.functionIdRange = functionIdRange
        super.init()
    }

    // MARK: - FunctionModule Protocol

    func executeFunction(id: Int) {
        fatalError("子类必须重写executeFunction方法")
    }

    func canHandle(functionId: Int) -> Bool {
        return functionIdRange.contains(functionId)
    }

    // MARK: - 通用UI提示方法

    /// 显示加载提示
    func showLoading(_ message: String, userInteractionEnabled: Bool = true) {
        guard let view = viewController?.view else { return }
        if tipsView != nil {
            tipsView?.showLoading(message)
        } else {
            tipsView = QMUITips.createTips(to: view)
            tipsView?.isUserInteractionEnabled = userInteractionEnabled
            tipsView?.showLoading(message)
        }
//        tipsView.showLoading(message, detailText: "", hideAfterDelay: 0)
    }

    /// 隐藏加载提示
    func hideLoading() {
        guard (viewController?.view) != nil else { return }
        if tipsView != nil {
            tipsView?.hide(animated: true)
            tipsView = nil
        }
    }

    /// 显示成功提示
    func showSuccess(_ message: String) {
        guard let view = viewController?.view else { return }
        QMUITips.showSucceed(message, in: view)
    }

    /// 显示错误提示
    func showError(_ message: String) {
        guard let view = viewController?.view else { return }
        QMUITips.showError(message, in: view)
    }

    /// 显示信息弹窗（Alert形式，适用于显示详细文本信息）
    func showInfoAlert(title: String = "提示", message: String) {
        guard let viewController = viewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        viewController.present(alert, animated: true)
    }

    // MARK: - 通用错误处理方法

    /// 处理网络错误
    func handleNetworkError(_ error: BCLError) {
        switch error {
        case let .network(.invalidParameters(message)):
            BDLogger.error("参数无效: \(message)")
            showError("参数无效")
        case let .network(.httpError(code)):
            BDLogger.error("HTTP错误: \(code)")
            showError("网络错误")
        case let .network(.serverError(code, message)):
            BDLogger.error("服务器错误[\(code)]: \(message)")
            showError("服务器错误")
        case let .network(.tokenError(message)):
            BDLogger.error("Token异常: \(message)")
            showError("Token异常")
        default:
            BDLogger.error("其他错误: \(error)")
            showError("操作失败")
        }
    }

    /// 处理温度测量错误(消极响应)
    func handleTemperatureError(_ error: BCLError.TemperatureError, temperature: Int?) {
        switch error {
        case .measuring:
            BDLogger.info("测量中,请等待... 温度值: \(temperature ?? 0)")
            showError("测量中,请等待...")
        case .charging:
            BDLogger.error("设备正在充电,无法测量")
            showError("设备正在充电")
        case .notWearing:
            BDLogger.error("检测未佩戴,测量失败")
            showError("检测未佩戴")
        case .invalid:
            BDLogger.error("无效数据")
            showError("无效数据")
        case .busy:
            BDLogger.error("设备繁忙")
            showError("设备繁忙")
        }
    }
}
