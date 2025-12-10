//
//  PassThroughWindow.swift
//  BCLRingSDKDemo
//

import UIKit

class PassThroughWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self || hitView == self.rootViewController?.view {
            return nil
        }
        return hitView
    }
}
