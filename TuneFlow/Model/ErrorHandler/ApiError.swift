//
//  ApiError.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 03/05/2026.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL(String)
    case badResponse(Int)
    case decodedField(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .badResponse(let code):
            return "Bad server response: \(code)"
        case.decodedField(let error):
            return "Field to decode data: \(error)"
        }
    }
}
