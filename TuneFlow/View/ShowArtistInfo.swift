//
//  ShowArtistInfo.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 10/05/2026.
//

import UIKit
import SafariServices

@MainActor
class ShowArtistInfo: UIViewController {
    
    @IBOutlet weak var artistImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var linkShape: UIButton!
    
    var artists: Artist?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nameLabel.text = artists?.name
        
        linkShape.layer.cornerRadius = 27
        Task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let imageURL = artists?.pictureMedium ,let url = URL(string: imageURL) else {return}
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                artistImg.image = image
            }
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    @IBAction func openLink(_ sender: UIButton) {
        openLinkAlert()
    }
    
    private func openLinkAlert() {
        let alert = UIAlertController(
            title: "Open Link?",
            message: "Are you sure that you want open this link?",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { [weak self] _ in
            if let link = self?.artists?.link, let url = URL(string: link) {
                let safareieURL = SFSafariViewController(url: url)
                self?.present(safareieURL, animated: true)
            }
        }))
        present(alert, animated: true)
    }
}
