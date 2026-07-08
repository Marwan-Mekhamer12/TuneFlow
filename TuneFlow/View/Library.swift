//
//  Library.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 18/06/2026.
//

import UIKit

class Library: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var imageNoData: UIImageView!
    @IBOutlet weak var NoLikedSongsLabel: UILabel!
    @IBOutlet weak var SongsWillAppearHereLabel: UILabel!
    
    var arrData = [Song]()
    var filterData = [Song]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filterData = LikedManager.shared.likedsong
        collectionView.reloadData()
        isHiddenNoData()
        
        
    }
    
    private func start() {
        collectionView.delegate = self
        collectionView.dataSource = self
        filterData = arrData
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Liked..."
        definesPresentationContext = true
    }
    
    private func filterSong(with query: String) {
        if query.isEmpty {
            filterData = arrData
        } else {
            filterData = arrData.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                ($0.artist.name.localizedCaseInsensitiveContains(query)) ||
                ($0.album.title.localizedCaseInsensitiveContains(query))
            }
        }
        collectionView.reloadData()
    }
    
    private func isHiddenNoData() {
        
        let isEmpty = filterData.isEmpty
        collectionView.isHidden = isEmpty
        imageNoData.isHidden = !isEmpty
        NoLikedSongsLabel.isHidden = !isEmpty
        SongsWillAppearHereLabel.isHidden = !isEmpty
    }
    
    
}


extension Library: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = filterData[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "librarycell", for: indexPath) as! LibraryCell
        cell.setUp(items: items)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let items = filterData[indexPath.row]
        print(items.title)
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "showsongs") as? ShowSongsInfo {
            vc.songs = items
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


extension Library: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        filterSong(with: query)
    }
}
