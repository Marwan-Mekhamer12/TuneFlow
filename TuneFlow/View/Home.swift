//
//  ViewController.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 28/03/2026.
//

import UIKit
import Combine
import AVFoundation

@MainActor
class Home: UIViewController {
    
    @IBOutlet weak var ArtistsCollectionView: UICollectionView!
    @IBOutlet weak var AlbumTableView: UITableView!
    @IBOutlet weak var SongsTableView: UITableView!
    
    
    
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
    
    private var arrDataSongs = [Song]()
    private var displaySongs: [Song] {
        Array(arrDataSongs.prefix(7))
    }
    
    
    private let viewModelArtists = ArtistsViewModelAsyncAwait()
    private let viewModelAlbums = AlbumViewModelAsyncAwait()
    private let viewModelSongs = songViewModelAsyncAwait()
    private var cancelLabel = Set<AnyCancellable>()
    private var loadingTasks: Task<Void, Never>?
    private var hasLoadedData = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        starting()
        bindingArtists()
        bindingAlbums()
        bindingSongs()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasLoadedData else {return}
        hasLoadedData = true
        loadingTasks = Task { [weak self] in
            await self?.viewModelArtists.loadingData()
            await self?.viewModelAlbums.loadingData()
            await self?.viewModelSongs.loadingData()
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
    
    private func bindingSongs() {
        viewModelSongs.$arrData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] songs in
                self?.arrDataSongs = songs
                self?.SongsTableView.reloadData()
            }
            .store(in: &cancelLabel)
        
        // show songs alert
        viewModelSongs.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
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
        
        SongsTableView.delegate = self
        SongsTableView.dataSource = self
        
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
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "profile") as? Profile {
            navigationController?.pushViewController(vc, animated: true)
        }
        
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
    
    @IBAction func viewAllSongs(_ sender: UIButton) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "allsongs") as? DisplayAllSongs {
            vc.title = "Songs"
            vc.arrData = arrDataSongs
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}

// Mark: - CollectionView - Artists

extension Home: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return disPlayArtists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = disPlayArtists[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artistcell", for: indexPath) as! ArtistsCell
        cell.setUp(item: items)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = arrDataArtists[indexPath.row]
        if let vc = storyboard?.instantiateViewController(withIdentifier: "showartistinfo") as? ShowArtistInfo {
            vc.artists = data
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// Mark: - TableView - Albums & Songs

extension Home: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == AlbumTableView {
            return disPlayAlbums.count
        } else if tableView == SongsTableView {
            return displaySongs.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if tableView == AlbumTableView {
            let itemsAlbums = disPlayAlbums[indexPath.row]
            guard  let cell = tableView.dequeueReusableCell(withIdentifier: "albumcell") as? AlbumCell else {
                return UITableViewCell()
            }
            cell.setUp(items: itemsAlbums)
            return cell
            
        } else if tableView == SongsTableView {
            let itemsSongs = displaySongs[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "songcell", for: indexPath) as? SongsCell else {
                return UITableViewCell()
            }
            cell.setUp(item: itemsSongs)
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if tableView == AlbumTableView {
            let albumData = disPlayAlbums[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            if let vc = storyboard?.instantiateViewController(withIdentifier: "showalbum") as? ShowAlbum {
                vc.album = albumData
                navigationController?.pushViewController(vc, animated: true)
            }
        } else if tableView == SongsTableView {
            let songData = displaySongs[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            if let vc = storyboard?.instantiateViewController(withIdentifier: "showsongs") as? ShowSongsInfo {
                vc.songs = songData
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// Mark: - Refresh Data

extension Home {
    
    private func setupRefreshController() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        AlbumTableView.refreshControl = refreshControl
        SongsTableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        loadingTasks = Task { [weak self] in
            await self?.viewModelAlbums.loadingData()
            await self?.viewModelArtists.loadingData()
            await self?.viewModelSongs.loadingData()
            
            await MainActor.run {
                self?.AlbumTableView.refreshControl?.endRefreshing()
                self?.ArtistsCollectionView.reloadData()  // تحديث يدوي
            }
        }
    }
}



