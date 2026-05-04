//
//  AlbumViewModelAsyncAwait.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 26/04/2026.
//

import Foundation
import Combine

protocol AlbumViewModelAsyncAwaitProtocol: ObservableObject {
    func loadingData() async
    func filterData(with query: String) async
}

@MainActor
class AlbumViewModelAsyncAwait: AlbumViewModelAsyncAwaitProtocol {
    @Published var albumData = [Album]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let manager: APIManagerAsyncAwaitProtocol
    init(manager: APIManagerAsyncAwaitProtocol = APIManagerAsyncAwait()) {
        self.manager = manager
    }
    
    func loadingData() async {
        isLoading = true
        errorMessage = nil
        do {
            let url = EndPoint.search("Album").urlString
            let response: SongsResponse = try await manager.fetchData(url)
            self.albumData = response.data.map {$0.album}
            self.isLoading = false
        } catch {
            self.errorMessage = "Album Field: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
     func filterData(with query: String) async {
        if query.isEmpty {
            await loadingData()
            return
        }
        isLoading = true
        do {
            let url = EndPoint.search(query).urlString
            let response: SongsResponse = try await manager.fetchData(url)
            self.albumData = response.data.map {$0.album}
            self.isLoading = false
        } catch {
            self.errorMessage = "Search album fiald: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
