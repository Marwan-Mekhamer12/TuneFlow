//
//  DisPlayAllArtists.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 16/04/2026.
//

import UIKit

@MainActor
class DisPlayAllArtists: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let searchContoller = UISearchController(searchResultsController: nil)
    
    var arrData = [Artist]()
    var filterData = [Artist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        starting()
    }
    
   
    
    private func starting() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        filterData = arrData
        refreshController()
        navigationItem.searchController = searchContoller
        navigationItem.hidesSearchBarWhenScrolling = false

        searchContoller.searchResultsUpdater = self
        searchContoller.searchBar.delegate = self
        searchContoller.obscuresBackgroundDuringPresentation = false
        searchContoller.searchBar.placeholder = "Search Artist"

        definesPresentationContext = true
    }
    
    private func filterArtists(with query: String) {
            if query.isEmpty {
                filterData = arrData
            } else {
                filterData = arrData.filter { $0.name.localizedCaseInsensitiveContains(query) }
            }
            collectionView.reloadData()
        }
}


extension DisPlayAllArtists: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = filterData[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artistscell", for: indexPath) as! ArtistsCell
        cell.setUp(item: items)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.3, height: self.view.frame.width * 0.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = arrData[indexPath.row]
        if let vc = storyboard?.instantiateViewController(withIdentifier: "showartistinfo") as? ShowArtistInfo {
            vc.artists = data
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension DisPlayAllArtists: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        filterArtists(with: query)
    }
}


extension DisPlayAllArtists {
    func refreshController() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(searchy), for: .valueChanged)
        collectionView.refreshControl = refresh
    }
    
    @objc func searchy() {
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }
}
