//
//  Observable.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.02.19.
//

import Foundation

/*
 各种, 可监听的对象, 基本上就是数据发生改变之后会触发后面的一些操作.
 对于 ViewModel 来说, 他必须暴露一些信号属性, 使得 View 可以伴随着 ViewModel 的数据变化而变化.
 
 在其他的框架里面, 是一个很重的机制. 而在这里, 这是使用了一个包装对象. 里面有一个 Value 值, 当 Value 值改变之后, 会触发所有存储的回调.
 */
// 这是一个非常好的类. 
public final class Observable<Value> {
    
    struct Observer<Value> {
        // 这里的 Observer 唯一的作用, 就是 Remove 的时候.
        weak var observer: AnyObject?
        // 存储的闭包, 接受值是 Value 类型
        // 这其实也是引到使用者, 在传递的闭包里面, 使用 Block 的参数来获取值, 而不是直接对于 Value 进行读取.
        let block: (Value) -> Void
    }
    
    private var observers = [Observer<Value>]()
    
    // 我会对于这个属性进行改造, 所有的行为, 必须使用 update 类似的函数进行更新.
    // 这个值, 变为私有属性, 暴露出一个计算属性来进行读取.
    public var value: Value {
        didSet { notifyObservers() }
    }
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public func observe(on observer: AnyObject, observerBlock: @escaping (Value) -> Void) {
        observers.append(Observer(observer: observer, block: observerBlock))
        observerBlock(self.value)
    }
    
    public func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }
    
    private func notifyObservers() {
        for observer in observers {
            DispatchQueue.main.async { observer.block(self.value) }
        }
    }
}
