//
//  SongsCell.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 03/06/2026.
//

import UIKit

class SongsCell: UITableViewCell {

    @IBOutlet weak var urlImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    
    private var currentTask: Task<Void, Never>?
    
    func setUp(item: Song) {
        titleLabel.text = item.title
        artistNameLabel.text = item.artist.name
        urlImg.layer.cornerRadius = 27
        urlImg.image = nil
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            await self?.loadingImage(from: item.artist.pictureMedium)
        }
    }
    
    func loadingImage(from urlString: String) async {
        if Task.isCancelled {return}
        
        if let NScache = Cache.shared.object(forKey: urlString as NSString) {
            await MainActor.run {[weak self] in
                self?.urlImg.image = NScache
            }
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        
        do {
            let (data, _ ) = try await URLSession.shared.data(from: url)
            if Task.isCancelled {return}
            if let image = UIImage(data: data) {
                Cache.shared.setObject(image, forKey: urlString as NSString)
                await MainActor.run { [weak self] in
                    self?.urlImg.image = image
                }
            }
        } catch {
            print("Field to download song image!: \(error.localizedDescription)")
        }
    }
    
    override func prepareForReuse() {
        currentTask?.cancel()
        currentTask = nil
        urlImg.image = nil
        titleLabel.text = nil
        artistNameLabel.text = nil
    }

}
