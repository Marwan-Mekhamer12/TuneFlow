//
//  ArtistsCell.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 09/04/2026.
//

import UIKit

class ArtistsCell: UICollectionViewCell {
    
    @IBOutlet weak var ArtistsImg: UIImageView!
    @IBOutlet weak var Articstsname: UILabel!
    
    private var currentTask: Task<Void, Never>?
    
    func setUp(item: Artist) {
        Articstsname.text = item.name
        ArtistsImg.image = nil
        ArtistsImg.layer.cornerRadius = 18
        
        currentTask?.cancel()
        
        currentTask = Task { [weak self] in
            await self?.loadingImage(from: item.pictureMedium)
        }
    }
    
    func loadingImage(from urlString: String) async {
        
        if Task.isCancelled {return}
        
        if let Nscache = Cache.shared.object(forKey: urlString as NSString) {
            await MainActor.run { [weak self] in
                self?.ArtistsImg.image = Nscache
            }
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                Cache.shared.setObject(image, forKey: urlString as NSString)
                await MainActor.run { [weak self] in
                    self?.ArtistsImg.image = image
                }
            }
            
        } catch {
            print("Image loading error: \(error.localizedDescription)")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        ArtistsImg.image = nil
        Articstsname.text = nil
    }
}
