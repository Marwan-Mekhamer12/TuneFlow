//
//  APIData.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 28/03/2026.
//

import Foundation

struct SongsResponse: Codable {
    let data: [Song]
}

struct Song: Codable {
    let id: Int
    let title: String
    let titleShort: String
    let link: String
    let duration: Int
    let preview: String
    let explicitLyrics: Bool
    let artist: Artist
    let album: Album
    
    enum CodingKeys: String, CodingKey {
        case id, title, link, duration, preview, artist, album
        case titleShort = "title_short"
        case explicitLyrics = "explicit_lyrics"
    }
}

struct Artist: Codable {
    let id: Int
    let name: String
    let link: String
    let pictureMedium: String
    let pictureXL: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, link
        case pictureMedium = "picture_medium"
        case pictureXL = "picture_xl"
    }
}

struct Album: Codable {
    let id: Int
    let title: String
    let coverMedium: String
    let coverXL: String
    let artist: Artist?
    
    
    enum CodingKeys: String, CodingKey {
        case id, title, artist
        case coverMedium = "cover_medium"
        case coverXL = "cover_xl"
    }
}
