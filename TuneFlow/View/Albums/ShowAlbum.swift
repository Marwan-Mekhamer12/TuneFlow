//
//  ShowAlbum.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 10/05/2026.
//

import UIKit
import SafariServices

@MainActor
class ShowAlbum: UIViewController {
    
    @IBOutlet weak var albumIng: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var linkShape: UIButton!
    
    var album: Album?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        nameLabel.text = album?.title
        linkShape.layer.cornerRadius = 18
        Task {
            await loadData()
        }
    }
    
    private func loadData() async {
        guard let imageURL = album?.coverMedium, let url = URL(string: imageURL) else {return}
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                albumIng.image = image
            }
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    @IBAction func pressedLink(_ sender: UIButton) {
//        alertOpenLink()
        
        
        alertOpenLink()
    }
    
    private func alertOpenLink() {
        guard let tracklistURL = album?.tracklist, let url = URL(string: tracklistURL) else {
            showErrorAlert(message: "No tracklist available")
            return
        }
        
        let alert = UIAlertController(title: "Open Track", message: "Do you want to open the album's first track?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { [weak self] _ in
            Task {
                await self?.fetchAndOpenFirstTrack(from: url)
            }
        }))
        present(alert, animated: true)
    }

    private func fetchAndOpenFirstTrack(from tracklistURL: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: tracklistURL)
            let response = try JSONDecoder().decode(tracklist.self, from: data)
            
            if let firstTrack = response.data.first, let trackURL = URL(string: firstTrack.link) {
                let safariVC = SFSafariViewController(url: trackURL)
                await MainActor.run {
                    present(safariVC, animated: true)
                }
            } else {
                await MainActor.run {
                    showErrorAlert(message: "No tracks found")
                }
            }
        } catch {
            print(error.localizedDescription)
            await MainActor.run {
                showErrorAlert(message: "Failed to load tracks")
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
