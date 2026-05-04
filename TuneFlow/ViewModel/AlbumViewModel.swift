//
//  AlbumViewModel.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 19/04/2026.
//

import Combine

protocol AlbumViewModelProtocol {
    func loadingData()
    func filterData(with query: String)
}

class AlbumViewController: AlbumViewModelProtocol {
    
    @Published var albumData = [Album]()
    @Published var filterAlbumData = [Album]()
    
    
    
    private let manager: APIManagerProtocol
    init(manager: APIManagerProtocol = APIManager()) {
        self.manager = manager
    }
    
    func loadingData() {
        let url = EndPoint.search("Album").urlString
        manager.fetchData(urlString: url) { [weak self] (result: Result<SongsResponse, Error>) in
            switch result{
            case .success(let response):
                self?.albumData = response.data.map {$0.album}
                self?.filterAlbumData = response.data.map {$0.album}
            case .failure(let error):
                print("Error Album", error)
            }
        }
    }
    
    func filterData(with query: String) {
        if query.isEmpty {
            filterAlbumData = albumData
            return
        }
        
        let url = EndPoint.search("Album").urlString
        manager.fetchData(urlString: url) { [weak self] (result: Result<SongsResponse, Error>) in
            switch result {
            case .success(let response):
                self?.filterAlbumData = response.data.map {$0.album}
            case .failure(let error):
                print("Filter Album Error:", error)
            }
        }
    }
    
    
}
