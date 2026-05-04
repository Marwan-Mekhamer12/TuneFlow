//
//  ViewController.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 28/03/2026.
//

import UIKit
import Combine

@MainActor
class Home: UIViewController {
    
    @IBOutlet weak var ArtistsCollectionView: UICollectionView!
    @IBOutlet weak var AlbumTableView: UITableView!
    
    @IBOutlet weak var circleProfile: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    private var arrDataArtists = [Artist]()
    private var disPlayArtists: [Artist] {
        Array(arrDataArtists.prefix(7))
    }
    
    private var arrDataAlbums = [Album]()
    private var disPlayAlbums : [Album] {
        Array(arrDataAlbums.prefix(7))
    }
    
    
    private let viewModelArtists = ArtistsViewModelAsyncAwait()
    private let viewModelAlbums = AlbumViewModelAsyncAwait()
    private var cancelLabel = Set<AnyCancellable>()
    private var loadingTasks: Task<Void, Never>?
    private var hasLoadedData = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        starting()
        bindingArtists()
        bindingAlbums()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasLoadedData else {return}
        hasLoadedData = true
        loadingTasks = Task { [weak self] in
            await self?.viewModelArtists.loadingData()
            await self?.viewModelAlbums.loadingData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        loadingTasks?.cancel()
    }
    
    private func bindingArtists() {
        viewModelArtists.$arrData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artists in
                self?.arrDataArtists = artists
                self?.ArtistsCollectionView.reloadData()
            }
            .store(in: &cancelLabel)
        
        // view alert
        viewModelArtists.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showAlert(error)
                }
            }
            .store(in: &cancelLabel)
    }
    
    private func bindingAlbums() {
        viewModelAlbums.$albumData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] albums in
                self?.arrDataAlbums = albums
                self?.AlbumTableView.reloadData()
            }
            .store(in: &cancelLabel)
        
        // show album alert
        viewModelAlbums.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error{
                    self?.showAlert(error)
                }
            }
            .store(in: &cancelLabel)
    }
    
    private func starting() {
        ArtistsCollectionView.delegate = self
        ArtistsCollectionView.dataSource = self
        
        AlbumTableView.delegate = self
        AlbumTableView.dataSource = self
        
        setupRefreshController()
        
        circleProfile.layer.cornerRadius = 27
        circleProfile.backgroundColor = .red
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(alert, animated: true)
    }
        
    @IBAction func ProfileAction(_ sender: UIButton) {
    }
    
    @IBAction func viewAllArtists(_ sender: UIButton) {
        
        // show all artists image and data
        if let vc = storyboard?.instantiateViewController(withIdentifier: "allartistsss") as? DisPlayAllArtists {
            vc.title = "Artists"
            vc.arrData = arrDataArtists
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func viewAllAlbums(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "allalbums") as? DisPlayAllAlbums {
            vc.title = "Albums"
            vc.arrData = arrDataAlbums
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// Mark: - CollectionView

extension Home: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return disPlayArtists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = disPlayArtists[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artistscell", for: indexPath) as! ArtistsCell
        cell.setUp(item: items)
        return cell
        
    }
}

// Mark: - TableView

extension Home: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return disPlayAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = disPlayAlbums[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumcell") as! AlbumCell
        cell.setUp(items: items)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let items = disPlayAlbums[indexPath.row]
        print(items.title)
    }
}

// Mark: - Refresh Data
extension Home {
    
    private func setupRefreshController() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        AlbumTableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        loadingTasks = Task { [weak self] in
            await self?.viewModelAlbums.loadingData()
            await self?.viewModelArtists.loadingData()
            
            await MainActor.run {
                self?.AlbumTableView.refreshControl?.endRefreshing()
                self?.ArtistsCollectionView.reloadData()  // تحديث يدوي
            }
        }
    }
}
