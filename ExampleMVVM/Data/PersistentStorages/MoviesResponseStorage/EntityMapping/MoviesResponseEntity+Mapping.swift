//
//  MoviesResponseEntity+Mapping.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 05/04/2020.
//

import Foundation
import CoreData

/*
 extension MoviesResponseEntity {

     @nonobjc public class func fetchRequest() -> NSFetchRequest<MoviesResponseEntity> {
         return NSFetchRequest<MoviesResponseEntity>(entityName: "MoviesResponseEntity")
     }

     @NSManaged public var page: Int32
     @NSManaged public var totalPages: Int32
     @NSManaged public var movies: NSSet?
     @NSManaged public var request: MoviesRequestEntity?

 }

 // MARK: Generated accessors for movies
 extension MoviesResponseEntity {

     @objc(addMoviesObject:)
     @NSManaged public func addToMovies(_ value: MovieResponseEntity)

     @objc(removeMoviesObject:)
     @NSManaged public func removeFromMovies(_ value: MovieResponseEntity)

     @objc(addMovies:)
     @NSManaged public func addToMovies(_ values: NSSet)

     @objc(removeMovies:)
     @NSManaged public func removeFromMovies(_ values: NSSet)

 }

 */

// 定义各种映射函数, 将数据库中的数据, 变为业务数据.
extension MoviesResponseEntity {
    func toDTO() -> MoviesResponseDTO {
        return .init(page: Int(page),
                     totalPages: Int(totalPages),
                     movies: movies?.allObjects.map { ($0 as! MovieResponseEntity).toDTO() } ?? [])
    }
}

extension MovieResponseEntity {
    func toDTO() -> MoviesResponseDTO.MovieDTO {
        return .init(id: Int(id),
                     title: title,
                     genre: MoviesResponseDTO.MovieDTO.GenreDTO(rawValue: genre ?? ""),
                     posterPath: posterPath,
                     overview: overview,
                     releaseDate: releaseDate)
    }
}

extension MoviesRequestDTO {
    func toEntity(in context: NSManagedObjectContext) -> MoviesRequestEntity {
        let entity: MoviesRequestEntity = .init(context: context)
        entity.query = query
        entity.page = Int32(page)
        return entity
    }
}

extension MoviesResponseDTO {
    func toEntity(in context: NSManagedObjectContext) -> MoviesResponseEntity {
        let entity: MoviesResponseEntity = .init(context: context)
        entity.page = Int32(page)
        entity.totalPages = Int32(totalPages)
        movies.forEach {
            entity.addToMovies($0.toEntity(in: context))
        }
        return entity
    }
}

extension MoviesResponseDTO.MovieDTO {
    func toEntity(in context: NSManagedObjectContext) -> MovieResponseEntity {
        let entity: MovieResponseEntity = .init(context: context)
        entity.id = Int64(id)
        entity.title = title
        entity.genre = genre?.rawValue
        entity.posterPath = posterPath
        entity.overview = overview
        entity.releaseDate = releaseDate
        return entity
    }
}
