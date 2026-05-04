//
//  APIManager.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 28/03/2026.
//

import Foundation

// base url: https://api.deezer.com/search?q=MichaelJackson

protocol APIManagerProtocol {
    func fetchData<T: Codable> (urlString: String, completion: @escaping(Result<T, Error>) -> Void)
}

final class APIManager: APIManagerProtocol {
    static let shared = APIManager()
    
    func fetchData<T: Codable> (urlString: String, completion: @escaping(Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(URLError(.badURL)))
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
            }
            
        }
        .resume()
        
    }
    
}
