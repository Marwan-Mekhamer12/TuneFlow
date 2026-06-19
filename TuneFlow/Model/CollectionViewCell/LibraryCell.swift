//
//  LibraryCell.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 18/06/2026.
//

import UIKit

class LibraryCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var likednameLabel: UILabel!
    
    private var currentTask: Task<Void, Never>?
    
    func setUp(items: Song) {
        currentTask?.cancel()
        likednameLabel.text = items.artist.name
        image.layer.cornerRadius = 18
        image.image = nil
        
        currentTask = Task { [weak self] in
            await self?.loadingData(items.artist.pictureMedium)
        }
    }
    
    private func loadingData(_ urlString: String) async {
        if Task.isCancelled {return}
        
        if let NSCashe = Cache.shared.object(forKey: urlString as NSString) {
            await MainActor.run {
                image.image = NSCashe
            }
             return
        }
        
        guard let url = URL(string: urlString) else {return}
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                Cache.shared.setObject(image, forKey: urlString as NSString)
                await MainActor.run { [weak self] in
                    self?.image.image = image
                }
            }
            
        } catch {
            print("Error to load iimage from Library Cell: \(error.localizedDescription)")
            return
        }
    }
}
