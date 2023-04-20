//
//  MoviesListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct MoviesListViewModelActions {
    let showMovieDetails: (Movie) -> Void
    let showMovieQueriesSuggestions: (@escaping (_ didSelect: MovieQuery) -> Void) -> Void
    let closeMovieQueriesSuggestions: () -> Void
}

enum MoviesListViewModelLoading {
    case fullScreen
    case nextPage
}

/*
 在编写 ViewModel 的时候, 需要显式地区分 ModelAction 和 Ouput
 在这里, 作者是将 ModelAction 当做了 Input 来看待了. 他就是 View Action 绑定到 ViewModel 的逻辑.
 不只是 BtnClicked 这种交互, 对于 View 的各个生命周期函数, 对于 ViewModel 的调用, 也可以认为是 ViewModel 的 ModelAction .
 */
protocol MoviesListViewModelInput {
    func viewDidLoad()
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func showQueriesSuggestions()
    func closeQueriesSuggestions()
    func didSelectItem(at index: Int)
}

// 显式地, 将可以发送信号的属性, 和仅仅作为显示的属性区分开还是很重要的.
// 所有的 Model 操作, 都是通过 Model Action. 而不是直接的属性赋值.
protocol MoviesListViewModelOutput {
    var items: Observable<[MoviesListItemViewModel]> { get } /// Also we can calculate view model items on demand:  https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/pull/10/files
    var loading: Observable<MoviesListViewModelLoading?> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
}

// 就连 ViewModel, 都是一个接口对象了.
protocol MoviesListViewModel: MoviesListViewModelInput, MoviesListViewModelOutput {}

// 当然, 还是要有一个实现类的. 
final class DefaultMoviesListViewModel: MoviesListViewModel {
    
    // 工具对象, 使用接口进行抽象.
    // 使用 Init 方法进行传入.
    private let searchMoviesUseCase: SearchMoviesUseCase
    private let actions: MoviesListViewModelActions?
    
    // 使用接口的好处, 这些所有的实现细节, 在使用者那里其实是不可见的.
    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }
    
    private var pages: [MoviesPage] = []
    // 在 WillSet 里面, 做 cancel 的动作, 这是更加符合 willset, didset 的使用场景.
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    
    // MARK: - OUTPUT
    
    let items: Observable<[MoviesListItemViewModel]> = Observable([])
    let loading: Observable<MoviesListViewModelLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    
    // VM 里面, 将 View 所需要的内容直接组织好, 避免在 VC 里面大段的业务代码堆砌.
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = NSLocalizedString("Movies", comment: "")
    let emptyDataTitle = NSLocalizedString("Search results", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder = NSLocalizedString("Search Movies", comment: "")
    
    // MARK: - Init
    // 需要使用的接口对象, 最好是 init 的时候传递过来.
    // 这种功能性的控件, 如果一直带着 Optinal, 使用起来会特别不方便.
    init(searchMoviesUseCase: SearchMoviesUseCase, actions: MoviesListViewModelActions? = nil) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.actions = actions
    }
    
    // MARK: - Private
    
    // 作者的思路, 首先是从缓存里面读取相关的数据.
    // 然后是网络请求, 网络请求得到之后, 首先被缓存, 然后调用回调
    // 缓存的回调和网络的回调都是 appendPage 所以里面应该使用 filter 进行过滤.
    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages
        pages = pages.filter { $0.page != moviesPage.page } + [moviesPage]
        
        // 在做完了内部的数据变化之后, 来触发信号的变化. 这样比较好, 相当于是最后一步触发给 VC 外界变化.
        // 其实, 和使用一个闭包来传递给外界数据发生了变化, 没有太大的区别. 只是这样代码更加的集中.
        items.value = pages.movies.map(MoviesListItemViewModel.init)
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.value.removeAll()
    }
    
    private func load(movieQuery: MovieQuery, loading: MoviesListViewModelLoading) {
        self.loading.value = loading
        query.value = movieQuery.query
        
        // 真正的动作, 还是要对应的工具对象进行执行,
        // 这又是一个接口对象, 只能使用相关的接口函数.
        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: .init(query: movieQuery, page: nextPage),
            cached: appendPage,
            completion: { result in
                switch result {
                case .success(let page):
                    self.appendPage(page)
                case .failure(let error):
                    self.handle(error: error)
                }
                self.loading.value = .none
            })
    }
    
    // 在控制层的方法里面, 完成对于信号对象的赋值操作.
    // 自动触发后续的逻辑, ViewModel 中不需要专门的触发 View 的变化.
    /*
     响应式编程（Reactive Programming）是一种编程范式，它主张以数据流和变化的方式来处理应用程序的输入和输出。在响应式编程中，数据流是一种主要的抽象概念，应用程序通过对数据流进行组合和变换来实现业务逻辑。
     
     响应式编程的核心概念是响应式流，它是一个可以被异步推送的序列数据集合，它可以包含异步事件、异步数据或异步控制流等多种类型的数据。在响应式编程中，应用程序可以订阅响应式流，并接收它所感兴趣的数据，并可以对这些数据进行变换和组合。
     
     响应式编程的主要目的是提高应用程序的响应能力和可扩展性。响应式编程可以帮助应用程序处理异步事件，同时也可以帮助应用程序处理高并发场景下的数据访问和处理。此外，响应式编程还可以帮助应用程序实现响应式界面，在用户交互时能够及时更新界面。
     
     总之，响应式编程是一种以数据流和变化的方式来处理应用程序的输入和输出的编程范式，它通过处理异步事件和高并发场景等问题，提高了应用程序的响应能力和可扩展性。
     */
    // 从上面的定义我们知道, ViewModel 需要有一种机制, 来触发自己数据变化之后的 View 变化.
    // 如果暴露了各种信号对象, 那么信号对象的变化会触发后续逻辑.
    // 否则, 也要在 ViewModel 内部触发对应的逻辑. Delegate 也好, 闭包也好, 都要主动调用.
    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
        NSLocalizedString("No internet connection", comment: "") :
        NSLocalizedString("Failed loading movies", comment: "")
    }
    
    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loading: .fullScreen)
    }
}

// MARK: - INPUT. View event methods
// 将, 对外暴露的接口函数, 和自己内部运行的逻辑函数进行区分还是很重要的.
// 在这些接口函数里面, 不做主要的逻辑运转, 而是调用逻辑函数. 这样, 逻辑函数更容易复用. 避免接口函数里面的代码太复杂. 
extension DefaultMoviesListViewModel {
    
    func viewDidLoad() { }
    
    func didLoadNextPage() {
        guard hasMorePages, loading.value == .none else { return }
        load(movieQuery: .init(query: query.value),
             loading: .nextPage)
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(movieQuery: MovieQuery(query: query))
    }
    
    func didCancelSearch() {
        moviesLoadTask?.cancel()
    }
    
    func showQueriesSuggestions() {
        actions?.showMovieQueriesSuggestions(update(movieQuery:))
    }
    
    func closeQueriesSuggestions() {
        actions?.closeMovieQueriesSuggestions()
    }
    
    func didSelectItem(at index: Int) {
        actions?.showMovieDetails(pages.movies[index])
    }
}

// MARK: - Private

private extension Array where Element == MoviesPage {
    var movies: [Movie] { flatMap { $0.movies } }
}
