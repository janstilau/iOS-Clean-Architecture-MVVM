//
//  ServiceConfig.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

// 应该多多使用面向接口. 虽然这个接口的真正实现类, 只会在 ApiDataNetworkConfig 中体现.
// 从这里看, 好像是没有必要.
// 但是, 在该项目的所有其他地方面对的都是这个接口对象.
// 使用接口对象, 可以利于替换, 也使得使用方能够受限.
// 实现类可以写很多方法, 根据场景的不同, 不能够完全的限制方法的可见性, 这个时候, 其他地方只知道协议对象, 那么这种暴露也就无妨了. 
public protocol NetworkConfigurable {
    var baseURL: URL { get }
    var headers: [String: String] { get } // 默认的一些 Header 值
    var queryParameters: [String: String] { get } // 默认的一些 Query 值. 
}

public struct ApiDataNetworkConfig: NetworkConfigurable {
    public let baseURL: URL
    public let headers: [String: String]
    public let queryParameters: [String: String]
    
    public init(baseURL: URL,
                headers: [String: String] = [:],
                queryParameters: [String: String] = [:]) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
    }
}
