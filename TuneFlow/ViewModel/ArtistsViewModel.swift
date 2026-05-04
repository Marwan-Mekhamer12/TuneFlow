//
//  DataViewModel.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 28/03/2026.
//

import Foundation
import Combine

protocol ArtistsViewModelProtocol {
    func loadData()
    func filterData(with query: String)
}

class ArtistsViewModel: ArtistsViewModelProtocol {
    
    @Published var artists = [Artist]()
    @Published var filterArtists = [Artist]()
    
    private let manager: APIManagerProtocol
    init(manager: APIManagerProtocol = APIManager()) {
        self.manager = manager
    }
    
    func loadData() {
        
        let url = EndPoint.search("artist").urlString
        
        manager.fetchData(urlString: url) { [weak self] (result: Result<SongsResponse, Error>) in
            switch result {
            case .success(let response):
                self?.artists = response.data.map {$0.artist}
                self?.filterArtists = response.data.map {$0.artist}
            case .failure(let error):
                print("Error", error)
            }
        }
    }
    
    
    
    func filterData(with query: String) {
        if query.isEmpty {
            filterArtists = artists
            return
        }
        
        let url = EndPoint.search(query).urlString
        
        manager.fetchData(urlString: url) { [weak self] (result: Result<SongsResponse, Error>) in
            switch result{
            case .success(let response):
                self?.filterArtists = response.data.map {$0.artist}
            case .failure(let error):
                print("Error Artists", error)
            }
        }
        
    }
}


enum EndPoint {
    case search(String)
    
    var urlString: String {
        switch self {
        case .search(let query):
            return "https://api.deezer.com/search?q=\(query)"
        }
    }
}
