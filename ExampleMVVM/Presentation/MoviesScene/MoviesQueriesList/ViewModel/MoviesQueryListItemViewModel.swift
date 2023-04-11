//
//  MoviesQueryListItemViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 25.08.19.
//

import Foundation

// 对于 Cell 来说, 也是要有 ViewModel 的
// 这个 ViewModel, 没有各种控制层的逻辑, 它的主要作用, 就是将 View 的显示逻辑, 从 View 中抽离, 变为控制层的一部分. 
class MoviesQueryListItemViewModel {
    let query: String

    init(query: String) {
        self.query = query
    }
}

extension MoviesQueryListItemViewModel: Equatable {
    static func == (lhs: MoviesQueryListItemViewModel,
                    rhs: MoviesQueryListItemViewModel) -> Bool {
        return lhs.query == rhs.query
    }
}
