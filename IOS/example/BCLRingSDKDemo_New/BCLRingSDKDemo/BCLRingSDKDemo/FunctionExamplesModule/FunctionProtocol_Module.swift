//
//  FunctionProtocol_Module.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//  功能模块协议定义
//

import UIKit

/// 功能模块协议 - 所有功能模块必须遵循此协议
protocol FunctionProtocol_Module: AnyObject {
    /// 当前所在的ViewController (用于显示提示信息、弹窗等)
    var viewController: UIViewController? { get set }

    /// 执行指定功能
    /// - Parameter id: 功能ID
    func executeFunction(id: Int)

    /// 判断该模块是否可以处理指定的功能ID
    /// - Parameter functionId: 功能ID
    /// - Returns: true表示可以处理,false表示不能处理
    func canHandle(functionId: Int) -> Bool
}
