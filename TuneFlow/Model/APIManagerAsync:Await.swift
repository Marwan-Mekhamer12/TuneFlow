//
//  APIManagerAsync:Await.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 25/04/2026.
//

import Foundation

protocol APIManagerAsyncAwaitProtocol {
    func fetchData<T: Codable>(_ urlString: String) async throws -> T
}

final class APIManagerAsyncAwait: APIManagerAsyncAwaitProtocol {
    
    func fetchData<T: Codable>(_ urlString: String) async throws -> T {
        // 1. Create URL
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL(urlString)
        }
        
        do {
            // 2. Create Fetch data
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // 3. Check Response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.badResponse(-1)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.badResponse(httpResponse.statusCode)
            }
            
            // 4. Decoded
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
                
            } catch {
                throw APIError.decodedField("\(error)")
            }
            
        } catch {
            throw error
        }
    }
}
