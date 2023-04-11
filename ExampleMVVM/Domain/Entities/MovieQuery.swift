//
//  MovieQuery.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation

// 专门找了一个类型进行包装. 这主要是为了扩展.
// 这是一个好习惯, 因为搜索, 本身就有可能是一个很复杂的业务. 可能有很多的选项. 
struct MovieQuery: Equatable {
    let query: String
}
