//
//  SongListViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 24.03.2025.
//

import UIKit
import SnapKit

final class SongListViewController: UIViewController {
    
    private let songListView = SongListView()
    
    private var songs: [Song] = []

    override func loadView() {
        view = songListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        playedSongsLoaded()
        updateStatus()
    }
    
    private func setupTableView() {
        songListView.tableView.backgroundColor = UIColor(named: "bg")
        songListView.tableView.delegate = self
        songListView.tableView.dataSource = self
    }

    @objc private func playedSongsLoaded() {
        MusicManager.shared.loadPlayedSongs()
        let playedSongs = MusicManager.shared.playedSongs
        self.songs = playedSongs
        songListView.tableView.reloadData()
    }
    
    @objc private func updateStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatus), name: .musicStatusUpdate, object: nil)
        songListView.tableView.reloadData()
    }
    
    func updateSongs(_ newSongs: [Song]) {
        self.songs = newSongs
        songListView.tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SongListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? SongCell else {
            return UITableViewCell()
        }
        
        let song = songs[indexPath.row]
        cell.configure(with: song)
        
        cell.backgroundColor = UIColor(named: "bg")
        
        cell.longPressAction = { [weak self] in
            guard self != nil else { return }
        }

        let selectedView = UIView()
        selectedView.backgroundColor = .darkGray
        cell.selectedBackgroundView = selectedView

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicManager.shared.setSongs(songs, startingAt: indexPath.row)
        MusicManager.shared.playCurrentSong()
        NotificationCenter.default.post(name: .musicStatusUpdate, object: nil)
        
        if let parent = self.parent as? MainTabBarController {
            parent.updateMiniPlayerAppearance()
        }

        tableView.reloadData()
        
    }
}
