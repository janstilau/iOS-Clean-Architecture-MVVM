//
//  StoryboardInstantiable.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit

/*
 一个抽象类. 这个抽象类里面, 是进行一组方法的集合.
 并且给出了这组方法的定义.
 这样, 外界可以直接声明实现这个抽象类, 来获取这组方法的使用.
 */
public protocol StoryboardInstantiable: NSObjectProtocol {
    associatedtype T
    static var defaultFileName: String { get }
    static func instantiateViewController(_ bundle: Bundle?) -> T
}

// T 被 Self 所固定下来了. 
public extension StoryboardInstantiable where Self: UIViewController {
    static var defaultFileName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    
    static func instantiateViewController(_ bundle: Bundle? = nil) -> Self {
        let fileName = defaultFileName
        let storyboard = UIStoryboard(name: fileName, bundle: bundle)
        guard let vc = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("Cannot instantiate initial view controller \(Self.self) from storyboard with name \(fileName)")
        }
        return vc
    }
}
