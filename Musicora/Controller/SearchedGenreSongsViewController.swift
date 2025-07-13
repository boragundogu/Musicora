//
//  SearchedGenreSongsViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 29.05.2025.
//

import UIKit
import SnapKit

final class SearchedGenreSongsViewController: UIViewController {

    private let genreName: String
    private let genreId: Int
    private var songs: [Song] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    init(genreName: String, genreId: Int) {
        self.genreName = genreName
        self.genreId = genreId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchSongsByGenreId()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "bg") ?? .systemBackground
        navigationController?.navigationBar.tintColor = .systemPurple
        navigationController?.navigationBar.barTintColor = UIColor(named: "bg")
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GenreSongCell.self, forCellReuseIdentifier: GenreSongCell.reuseIdentifier)
    }

    private func fetchSongsByGenreId() {
        let urlString = "https://itunes.apple.com/tr/rss/topsongs/limit=25/genre=\(genreId)/json"
        guard let url = URL(string: urlString) else {
            print("Invalid genreId URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error)")
                    return
                }
                guard let data = data else { return }
                do {
                    let feed = try JSONDecoder().decode(AppleMusicFeedResponse.self, from: data)
                    let ids = feed.feed.songIds.joined(separator: ",")
                    self.lookupSongs(by: ids)
                } catch {
                    print("Genre feed decoding error: \(error)")
                }
            }
        }.resume()
    }

    private func lookupSongs(by ids: String) {
        let lookupURL = "https://itunes.apple.com/lookup?id=\(ids)&country=tr"
        guard let url = URL(string: lookupURL) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Lookup error: \(error)")
                    return
                }
                guard let data = data else { return }
                do {
                    let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                    self.songs = response.results
                    self.tableView.reloadData()
                    self.animateTableViewAppearance()
                } catch {
                    print("Lookup decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    private func animateTableViewAppearance() {
        tableView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut) {
            self.tableView.alpha = 1
        }
    }
}

extension SearchedGenreSongsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GenreSongCell.reuseIdentifier, for: indexPath) as? GenreSongCell else {
            return UITableViewCell()
        }
        
        let song = songs[indexPath.row]
        cell.configure(with: song)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? GenreSongCell {
            cell.animateSelection()
        }
        
        MusicManager.shared.setSongs(songs, startingAt: indexPath.row)
        MusicManager.shared.playCurrentSong()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
