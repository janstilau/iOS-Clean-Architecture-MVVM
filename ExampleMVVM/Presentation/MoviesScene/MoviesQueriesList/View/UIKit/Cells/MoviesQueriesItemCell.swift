//
//  MoviesQueriesItemCell.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import UIKit

final class MoviesQueriesItemCell: UITableViewCell {
    
    static let height = CGFloat(50)
    static let reuseIdentifier = String(describing: MoviesQueriesItemCell.self)

    @IBOutlet private var titleLabel: UILabel!
    
    // 对于使用了 MVVM 的 View 来说, 可以使用自己的 Config 来进行自身的状态保持.
    // 也可以不保存 Config 类, 仅仅是 Update 的时候, 将这个对象传进来进行自身状态的刷新. 
    func fill(with suggestion: MoviesQueryListItemViewModel) {
        self.titleLabel.text = suggestion.query
    }
}
