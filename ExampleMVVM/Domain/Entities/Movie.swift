//
//  Movie.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

/*
 @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
 public protocol Identifiable<ID> {

     /// A type representing the stable identity of the entity associated with
     /// an instance.
     associatedtype ID : Hashable

     /// The stable identity of the entity associated with this instance.
     var id: Self.ID { get }
 }
 */
struct Movie: Equatable, Identifiable {
    // 显式地将, ID 的类型进行了明确.
    typealias Identifier = String
    enum Genre {
        case adventure
        case scienceFiction
    }
    let id: Identifier
    let title: String?
    let genre: Genre?
    let posterPath: String?
    let overview: String?
    let releaseDate: Date?
}

// 看来, 对于 Swift 来说, 多多使用 STRUCT 是一个更好的选择. 
struct MoviesPage: Equatable {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
}
