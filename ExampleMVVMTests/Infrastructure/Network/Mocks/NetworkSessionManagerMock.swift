//
//  NetworkSessionManagerMock.swift
//  ExampleMVVMTests
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation

// NetworkSessionManager 的能力, 就是可以发送 URLRequest, 获取 Result Data
// Mock 类可以进行值的预先确定. 
struct NetworkSessionManagerMock: NetworkSessionManager {
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
    
    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable {
        completion(data, response, error)
        return URLSessionDataTask()
    }
}
