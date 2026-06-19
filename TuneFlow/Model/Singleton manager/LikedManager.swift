//
//  LikedManager.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 18/06/2026.
//

import Foundation

final class LikedManager {
    static let shared = LikedManager()
    
    private init() {}
    
    var likedsong = [Song]()
}
