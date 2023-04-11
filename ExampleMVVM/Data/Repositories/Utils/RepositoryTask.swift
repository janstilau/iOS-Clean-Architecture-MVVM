//
//  RepositoryTask.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 25.10.19.
//

import Foundation

// 一个包装盒子, 里面存放真正的 DataTask. 
class RepositoryTask: Cancellable {
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
}
