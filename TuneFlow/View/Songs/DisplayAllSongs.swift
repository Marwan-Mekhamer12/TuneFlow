//
//  DisplayAllSongs.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 16/06/2026.
//

import UIKit

@MainActor  // all code in Main Thread 
class DisplayAllSongs: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var arrData = [Song]()
    var filterData = [Song]()
    private let viewModel = songViewModelAsyncAwait()
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        start()
    }
    
    private func start() {
        tableView.delegate = self
        tableView.dataSource = self
        
        filterData = arrData
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Song"
        definesPresentationContext = true
    }
    
    private func filterSongs(with query: String) {
        let source = LikedManager.shared.likedsong
        if query.isEmpty {
            filterData = source
        } else {
            filterData = source.filter{
                $0.title.localizedCaseInsensitiveContains(query) ||
                ($0.artist.name ).localizedCaseInsensitiveContains(query) ||
                ($0.album.title).localizedCaseInsensitiveContains(query)
            }
        }
        
        tableView.reloadData()
    }
    
    
}


extension DisplayAllSongs: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = filterData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "showallsongs", for: indexPath) as! SongsCell
        cell.setUp(item: items)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let items = filterData[indexPath.row]
        if let vc = storyboard?.instantiateViewController(withIdentifier: "showsongs") as? ShowSongsInfo {
            vc.songs = items
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}


extension DisplayAllSongs: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        filterSongs(with: query)
    }
}
