//
//  BaseNavigation_VC.swift
//  Rings
//
//  Created by JianDan on 2025/3/27.
//

import Foundation
import QMUIKit

class BaseNavigation_VC: QMUINavigationController {
}

extension BaseNavigation_VC {
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
