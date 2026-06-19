//
//  ShowSongsInfo.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 16/06/2026.
//

import UIKit
import SafariServices
import AVFoundation

@MainActor
class ShowSongsInfo: UIViewController {
    
    @IBOutlet weak var imgSong: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var AlbumNameLabel: UILabel!
    @IBOutlet weak var LinkBtnChape: UIButton!
    @IBOutlet weak var playAndPausePreviewShape: UIButton!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var viewShape: UIView!
    @IBOutlet weak var currentTime: UILabel!  // start time in progress
    @IBOutlet weak var totalTime: UILabel!   // final time in progress
    
    @IBOutlet weak var likedShape: UIButton!
    
    
    var songs: Song?
    private var isPlaying = false
    private var timeObserver: Any?
    
    private var isLiked = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        start()
        
    }
    
    // stop preview when user leave ShowSongsInfo
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AudioPlayerManager.shared.stop()
        progress.progress = 0
        
        if let observer = timeObserver,
              let player = AudioPlayerManager.shared.player {
            
               player.removeTimeObserver(observer)
               timeObserver = nil
           }

    }
    
    private func start() {
        
        titleLabel.text = songs?.title
        artistNameLabel.text = songs?.artist.name
        AlbumNameLabel.text = songs?.album.title
        imgSong.image = nil
        LinkBtnChape.layer.cornerRadius = 18
        playAndPausePreviewShape.layer.cornerRadius = 18
        viewShape.layer.cornerRadius = 18
        currentTime.text = "00:00"
        totalTime.text = "00:00"
        Task {
            await loadingData()
        }
        
    }
    
    private func loadingData() async {
        guard let urlImage = songs?.album.coverMedium, let url = URL(string: urlImage) else {return}
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                imgSong.image = image
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
    }
    
    @IBAction func pressedLink(_ sender: UIButton) {
        openLinkAlert()
    }
    
    private func openLinkAlert() {
        let alert = UIAlertController(title: "Open Link", message: "Are you sure you want open this link?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { [weak self] _ in
            if let link = self?.songs?.link, let url = URL(string: link) {
                let safarieURL = SFSafariViewController(url: url)
                self?.present(safarieURL, animated: true)
            }
        }))
        present(alert, animated: true)
    }
    
    @IBAction func pressedPlayAndPausePreview(_ sender: UIButton) {
        
        guard let previewURL = songs?.preview else {return}
        
        if isPlaying {
            AudioPlayerManager.shared.pause()
            playAndPausePreviewShape.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            progress.progress = 0
            AudioPlayerManager.shared.play("\(previewURL)")
            playAndPausePreviewShape.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            startProgressTracking()
        }
        isPlaying.toggle()
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startProgressTracking() {

        guard let player = AudioPlayerManager.shared.player else { return }

        let interval = CMTime(seconds: 0.1,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] currentTime in

            guard let self = self else { return }

            let currentSeconds = currentTime.seconds

            guard let durationSeconds =
                player.currentItem?.duration.seconds,
                  durationSeconds.isFinite
            else { return }
            
            self.currentTime.text = self.formatTime(currentSeconds)
            self.totalTime.text = self.formatTime(durationSeconds)

            let progress = Float(currentSeconds / durationSeconds)

            self.progress.progress = progress
        }
    }
    
    @IBAction func pressedLikedSong(_ sender: UIButton) {
        
        guard let song = songs else {return}
        
        if isLiked {
            likedShape.setImage(UIImage(systemName: "heart"), for: .normal)
            LikedManager.shared.likedsong.removeAll {
                $0.id == song.id
            }
        } else {
            likedShape.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            // passing Data in here
            LikedManager.shared.likedsong.append(song)
        }
        isLiked.toggle()
    }
    
    
}
