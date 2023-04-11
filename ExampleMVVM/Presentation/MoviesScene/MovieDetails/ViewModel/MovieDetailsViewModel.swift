//
//  MovieDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 04.08.19.
//  Copyright (c) 2019 All rights reserved.
//

import Foundation

protocol MovieDetailsViewModelInput {
    func updatePosterImage(width: Int)
}

protocol MovieDetailsViewModelOutput {
    var posterImage: Observable<Data?> { get }
    
    var title: String { get }
    var isPosterImageHidden: Bool { get }
    var overview: String { get }
}

protocol MovieDetailsViewModel: MovieDetailsViewModelInput, MovieDetailsViewModelOutput { }

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {
    
    private let posterImagePath: String?
    private let posterImagesRepository: PosterImagesRepository
    // 在这个项目里面, 所有的异步动作, 都有着取消机制.
    // 这是一个好的设计. 
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    
    // MARK: - OUTPUT
    let posterImage: Observable<Data?> = Observable(nil)
    
    let title: String
    let isPosterImageHidden: Bool
    let overview: String
    
    init(movie: Movie,
         posterImagesRepository: PosterImagesRepository) {
        self.title = movie.title ?? ""
        self.overview = movie.overview ?? ""
        self.posterImagePath = movie.posterPath
        self.isPosterImageHidden = movie.posterPath == nil
        self.posterImagesRepository = posterImagesRepository
    }
}

// MARK: - INPUT. View event methods
extension DefaultMovieDetailsViewModel {
    
    func updatePosterImage(width: Int) {
        guard let posterImagePath = posterImagePath else { return }
        
        imageLoadTask = posterImagesRepository.fetchImage(with: posterImagePath,
                                                          width: width) { result in
            guard self.posterImagePath == posterImagePath else { return }
            switch result {
            case .success(let data):
                self.posterImage.value = data
            case .failure: break
            }
            self.imageLoadTask = nil
        }
    }
}
