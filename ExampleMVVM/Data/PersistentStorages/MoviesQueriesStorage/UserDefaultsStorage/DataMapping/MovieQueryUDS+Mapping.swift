//
//  MovieQueryUDS+Mapping.swift
//  Data
//
//  Created by Oleh Kudinov on 12.08.19.
//  Copyright © 2019 Oleh Kudinov. All rights reserved.
//

import Foundation

/*
 在编程领域，UDS 通常指 Unified Data Source，即统一数据源。
 它是一种数据架构和设计模式，通过将不同的数据源合并为一个统一的数据源，并提供标准的接口和查询语言，方便应用程序访问和使用数据源。
 */
/*
 统一数据源（Unified Data Source，简称 UDS）是一种数据架构和设计模式，它将不同的数据源（如数据库、文件系统、Web 服务、API 等）合并为一个统一的数据源，提供标准的接口和查询语言，以方便应用程序访问和使用数据源。

 UDS 的设计目的是为了解决应用程序中数据来源繁多、数据格式不统一、数据访问方式复杂等问题。通过将数据源合并为一个统一的数据源，应用程序可以方便地访问和使用各种数据源，无需关心数据源的实现细节，从而提高数据的整合和访问效率。

 UDS 通常包括以下组件：

 1. 数据源适配器：用于将不同的数据源适配为统一的数据源格式。

 2. 数据访问接口：提供标准的数据访问接口和查询语言，用于访问和操作统一的数据源。

 3. 数据缓存和管理：用于缓存和管理数据，提高数据访问效率和响应速度。

 UDS 的设计可以实现以下优点：

 1. 简化应用程序的数据访问和管理。

 2. 提供标准的数据访问接口和查询语言，方便应用程序开发和维护。

 3. 提高数据整合和访问效率，减少数据冗余和重复访问。

 4. 支持多种数据源，包括关系型数据库、NoSQL 数据库、文件系统、Web 服务、API 等。

 总之，UDS 的设计使得应用程序可以更加方便地与数据源进行交互和管理，提高了数据的整合和访问效率，同时减少了开发和维护的难度。
 */
/*
 可以这样理解. archive 的数据类型, 不一定要和业务类型完全相同, 但是要提供相互转换的逻辑
 存储的时候, 应该考虑通用的数据类型, 避免业务类型的各种细节, 只要能够成功转化, 就不影响业务实现. 
 */
struct MovieQueriesListUDS: Codable {
    var list: [MovieQueryUDS]
}

struct MovieQueryUDS: Codable {
    let query: String
}

extension MovieQueryUDS {
    init(movieQuery: MovieQuery) {
        query = movieQuery.query
    }
}

extension MovieQueryUDS {
    func toDomain() -> MovieQuery {
        return .init(query: query)
    }
}
