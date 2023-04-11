//
//  UserDefaultsMoviesQueriesStorage.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation

// 使用 UserDefault 的方式, 来完成存储读取的动作.
final class UserDefaultsMoviesQueriesStorage {
    private let maxStorageLimit: Int
    private let recentsMoviesQueriesKey = "recentsMoviesQueries"
    private var userDefaults: UserDefaults
    
    init(maxStorageLimit: Int, userDefaults: UserDefaults = UserDefaults.standard) {
        self.maxStorageLimit = maxStorageLimit
        self.userDefaults = userDefaults
    }
    
    // 私有化真正的读取动作.
    // 在接口实现中, 再使用这个动作的结果做业务逻辑.
    // 这样更加的清晰, 自己的业务逻辑不伴随着接口. 接口移除的时候, 不会影响到这个类的主逻辑.
    // 这是更加健壮的一种代码组织方式, 应该学习.
    private func fetchMoviesQuries() -> [MovieQuery] {
        if let queriesData = userDefaults.object(forKey: recentsMoviesQueriesKey) as? Data {
            // 使用 UDS 进行读取, 然后转换成为 App 使用的业务类型.
            if let movieQueryList = try? JSONDecoder().decode(MovieQueriesListUDS.self, from: queriesData) {
                return movieQueryList.list.map { $0.toDomain() }
            }
        }
        return []
    }
    
    private func persist(moviesQuries: [MovieQuery]) {
        let encoder = JSONEncoder()
        // 老外经常使用 MovieQueryUDS.init, 这种写法是真的将函数当做对象来使用. 
        let movieQueryUDSs = moviesQuries.map(MovieQueryUDS.init)
        if let encoded = try? encoder.encode(MovieQueriesListUDS(list: movieQueryUDSs)) {
            userDefaults.set(encoded, forKey: recentsMoviesQueriesKey)
        }
    }
}

extension UserDefaultsMoviesQueriesStorage: MoviesQueriesStorage {
    
    // 对于接口的实现, 是调用其他的实现.
    // 在其中完成了工作环境的调度, 以及接口的限制.
    func fetchRecentsQueries(maxCount: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // 对于这种, self 的生命周期, 没有调用 completion.
            // 不过, completion 的命名是通用命名, 要坚持下去.
            guard let self = self else { return }
            
            var queries = self.fetchMoviesQuries()
            queries = queries.count < self.maxStorageLimit ? queries : Array(queries[0..<maxCount])
            completion(.success(queries))
        }
    }
    
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var queries = self.fetchMoviesQuries()
            self.cleanUpQueries(for: query, in: &queries)
            queries.insert(query, at: 0)
            self.persist(moviesQuries: queries)
            
            completion(.success(query))
        }
    }
}


// Trim 相关的代码. 
extension UserDefaultsMoviesQueriesStorage {
    
    private func cleanUpQueries(for query: MovieQuery, in queries: inout [MovieQuery]) {
        removeDuplicates(for: query, in: &queries)
        removeQueries(limit: maxStorageLimit - 1, in: &queries)
    }
    
    private func removeDuplicates(for query: MovieQuery, in queries: inout [MovieQuery]) {
        queries = queries.filter { $0 != query }
    }
    
    private func removeQueries(limit: Int, in queries: inout [MovieQuery]) {
        queries = queries.count <= limit ? queries : Array(queries[0..<limit])
    }
}
