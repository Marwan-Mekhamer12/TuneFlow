//
//  ArtistsViewModelAsyncAwait.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 25/04/2026.
//

import Foundation
import Combine

protocol ArtistsViewModelAsyncAwaitProtocol: ObservableObject {
    func loadingData() async
    func filterData(with query: String) async
}

@MainActor
final class ArtistsViewModelAsyncAwait: ArtistsViewModelAsyncAwaitProtocol {
    
    @Published var arrData = [Artist]()
    @Published var isLoad = false
    @Published var errorMessage: String?
    
    let manager: APIManagerAsyncAwaitProtocol
    init(manager: APIManagerAsyncAwaitProtocol = APIManagerAsyncAwait()) {
        self.manager = manager
    }
    
    func loadingData() async {
        
        isLoad = true
        errorMessage = nil
        
        do {
            let url = EndPoint.search("Artists").urlString
            
            let response: SongsResponse = try await manager.fetchData(url)
            self.arrData = response.data.map {$0.artist}
            self.isLoad = false
        } catch {
            self.isLoad = false
            self.errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
    }
    
    func filterData(with query: String) async {
        if query.isEmpty {
            await loadingData()
            return
        }
        isLoad = true
        
        do {
            let url = EndPoint.search(query).urlString
            let response: SongsResponse = try await manager.fetchData(url)
            self.arrData = response.data.map {$0.artist}
            self.isLoad = false
            
        } catch {
            self.isLoad = false
            self.errorMessage = "Search artist field: \(error.localizedDescription)"
        }
    }
    
    
    
    
}
