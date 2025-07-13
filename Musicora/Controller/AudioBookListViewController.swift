//
//  AudioBookListViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 17.05.2025.
//

import UIKit
import SnapKit

final class AudioBookListViewController: UIViewController {
    
    private let audioBookListView = AudioBookListView()
    
    private var audioBooks: [AudioBook] = []
    
    override func loadView() {
        view = audioBookListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        playedAudioBooksLoad()
        updateStatus()
    }
    
    private func setupTableView() {
        audioBookListView.tableView.backgroundColor = UIColor(named: "bg")
        audioBookListView.tableView.delegate = self
        audioBookListView.tableView.dataSource = self
    }
    
    @objc private func playedAudioBooksLoad() {
        MusicManager.shared.loadPlayedAudioBooks()
        let playedAudioBooks = MusicManager.shared.playedAudioBooks
        self.audioBooks = playedAudioBooks
        audioBookListView.tableView.reloadData()
    }
    
    @objc private func updateStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatus), name: .musicStatusUpdate, object: nil)
        audioBookListView.tableView.reloadData()
    }
    
    func updateAudioBooks(_ newAudioBooks: [AudioBook]) {
        self.audioBooks = newAudioBooks
        audioBookListView.tableView.reloadData()
    }
    
}

extension AudioBookListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioBookCell", for: indexPath) as? AudioBookCell else {
            return UITableViewCell()
        }
        
        let audioBook = audioBooks[indexPath.row]
        cell.configure(with: audioBook)
        
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
        MusicManager.shared.setAudioBooks(audioBooks, startingAt: indexPath.row)
        MusicManager.shared.playCurrentAudioBooks()
        NotificationCenter.default.post(name: .musicStatusUpdate, object: nil)
        
        if let parent = self.parent as? MainTabBarController {
            parent.updateMiniPlayerAppearance()
        }
        
        tableView.reloadData()
        
    }
}
