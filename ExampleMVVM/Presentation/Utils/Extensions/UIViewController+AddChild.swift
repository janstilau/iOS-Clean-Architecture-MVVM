//
//  UIViewController+AddChild.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 25.08.19.
//

import UIKit

extension UIViewController {
    
    // 这是一个通用的写法. 可以移植到自己的项目中.
    func add(child: UIViewController, container: UIView) {
        addChild(child)
        child.view.frame = container.bounds
        container.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    // 这是一个通用的写法, 可以移植到自己的项目中. 
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
