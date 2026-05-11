//
//  ShowAlbum.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 10/05/2026.
//

import UIKit

@MainActor
class ShowAlbum: UIViewController {
    
    @IBOutlet weak var albumIng: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var album: Album?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        nameLabel.text = album?.title
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
    
}
