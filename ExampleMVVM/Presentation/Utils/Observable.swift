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
        let block: (Value) -> Void
    }
    
    private var observers = [Observer<Value>]()
    
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
