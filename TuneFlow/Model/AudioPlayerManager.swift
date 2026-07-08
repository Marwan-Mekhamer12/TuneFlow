//
//  AudioPlayerManager.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 16/06/2026.
//

import Foundation
import AVFoundation


final class AudioPlayerManager {
    static let shared = AudioPlayerManager()
    
    var player: AVPlayer?
    
    func play(_ urlString: String) {
        guard let url = URL(string: urlString) else {return}
        player = AVPlayer(url: url)
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player = nil
    }
    
}
