//
//  DisPlayAllAlbums.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 21/04/2026.
//

import UIKit

@MainActor
class DisPlayAllAlbums: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let searchContoller = UISearchController(searchResultsController: nil)
    
    var arrData = [Album]()
    var filterData = [Album]()
    var viewModel = AlbumViewModelAsyncAwait()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        started()
    }
    
    private func started(){
        tableView.delegate = self
        tableView.dataSource = self
        
        filterData = arrData
        refreshController()
        navigationItem.searchController = searchContoller
        navigationItem.hidesSearchBarWhenScrolling = false

        searchContoller.searchResultsUpdater = self
        searchContoller.searchBar.delegate = self
        searchContoller.obscuresBackgroundDuringPresentation = false
        searchContoller.searchBar.placeholder = "Search Album"

        definesPresentationContext = true
    }
    
    private func filterAlbums(with query: String) {
           if query.isEmpty {
               filterData = arrData
           } else {
               filterData = arrData.filter {
                   $0.title.localizedCaseInsensitiveContains(query) ||
                   ($0.artist?.name ?? "").localizedCaseInsensitiveContains(query)
               }
           }
           tableView.reloadData()
       }
}

extension DisPlayAllAlbums: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = filterData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumcell", for: indexPath) as! AlbumCell
        cell.setUp(items: items)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let items = filterData[indexPath.row]
        print(items.title)
    }
}

extension DisPlayAllAlbums: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        filterAlbums(with: query)
    }
}


extension DisPlayAllAlbums {
    func refreshController() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshy), for: .valueChanged)
        tableView.refreshControl = refresh
        
    }
    
    @objc func refreshy() {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
}
