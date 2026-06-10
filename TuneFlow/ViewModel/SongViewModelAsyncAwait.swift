//
//  SongViewModelAsyncAwait.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 03/06/2026.
//

import Foundation
import Combine


protocol songViewModelProtocol: ObservableObject {
    func loadingData() async
    func filterData(with query: String) async
}

@MainActor
final class songViewModelAsyncAwait: songViewModelProtocol {
    
    @Published var arrData = [Song]()
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
            let url = EndPoint.search("Song").urlString
            let response: SongsResponse = try await manager.fetchData(url)
            self.arrData = response.data.map {$0.self}
            self.isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Song Field: \(error.localizedDescription)"
        }
    }
    
    func filterData(with query: String) async {
        if query.isEmpty {
            await loadingData()
            return
        }
        isLoading = true
        do {
            let url = EndPoint.search("Song").urlString
            let response: SongsResponse = try await manager.fetchData(url)
            self.arrData = response.data.map {$0.self}
            self.isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Field to Filter Song!: \(error.localizedDescription)"
        }
    }
    
    
    
    
}
