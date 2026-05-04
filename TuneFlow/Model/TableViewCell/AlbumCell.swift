//
//  AlbumCell.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 19/04/2026.
//

import UIKit

class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var albumImg: UIImageView!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    private var currentTask: Task<Void, Never>?
 
    func setUp(items: Album) {
        albumLabel.text = items.title
        artistLabel.text = items.title
        albumImg.image = nil
        albumImg.layer.cornerRadius = 27
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            await self?.LoadData(from: items.coverMedium)
        }
    }
    
    func LoadData(from urlString: String) async {
        
        if Task.isCancelled {return}
        
        if let NSCache = Cache.shared.object(forKey: urlString as NSString) {
            
            await MainActor.run {[weak self] in
                self?.albumImg.image = NSCache
            
            }
            return
        }
        
        guard let url = URL(string: urlString) else {return}
     
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
    
            if Task.isCancelled {return}
            if let image = UIImage(data: data) {
                Cache.shared.setObject(image, forKey: urlString as NSString)
                await MainActor.run { [weak self] in
                    self?.albumImg.image = image
                }
            }
 
            
        } catch {
            print("Faild to load Album: \(error.localizedDescription)")
        }
      
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        albumImg.image = nil
        albumLabel.text = nil
        artistLabel.text = nil
    }
}
