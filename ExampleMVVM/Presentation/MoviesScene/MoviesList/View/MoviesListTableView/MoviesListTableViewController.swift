//
//  MoviesListTableViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import UIKit

final class MoviesListTableViewController: UITableViewController {
    
    var viewModel: MoviesListViewModel!
    
    var posterImagesRepository: PosterImagesRepository?
    var nextPageLoadingSpinner: UIActivityIndicatorView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    /*
     这与其说是一个 VC, 不如说是一个 View. VM 信号发出, 主 VC 进行信号的处理, 然后主动调用自己管理 View 的相关 Update 函数. 
     */
    
    func reload() {
        tableView.reloadData()
    }
    
    // 这是外界触发的. VM 的
    func updateLoading(_ loading: MoviesListViewModelLoading?) {
        switch loading {
        case .nextPage:
            nextPageLoadingSpinner?.removeFromSuperview()
            nextPageLoadingSpinner = makeActivityIndicator(size: .init(width: tableView.frame.width, height: 44))
            tableView.tableFooterView = nextPageLoadingSpinner
        case .fullScreen, .none:
            tableView.tableFooterView = nil
        }
    }
    
    // MARK: - Private
    
    private func setupViews() {
        tableView.estimatedRowHeight = MoviesListItemCell.height
        tableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MoviesListTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoviesListItemCell.reuseIdentifier,
                                                       for: indexPath) as? MoviesListItemCell else {
            assertionFailure("Cannot dequeue reusable cell \(MoviesListItemCell.self) with reuseIdentifier: \(MoviesListItemCell.reuseIdentifier)")
            return UITableViewCell()
        }
        
        cell.fill(with: viewModel.items.value[indexPath.row],
                  posterImagesRepository: posterImagesRepository)
        
        // 非常丑陋的实现, 居然用这种方式, 来触发 ViewModel 的 Action.
        if indexPath.row == viewModel.items.value.count - 1 {
            viewModel.didLoadNextPage()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.isEmpty ? tableView.frame.height : super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}
