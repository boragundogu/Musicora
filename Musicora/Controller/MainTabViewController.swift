//
//  MainTabViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 17.05.2025.
//

import UIKit
import SnapKit

final class MainTabViewController: UIViewController {

    private var searchController = UISearchController(searchResultsController: nil)
    private let segmentedControl = UISegmentedControl(items: ["Şarkılar", "Sesli Kitaplar"])
    private let scrollView = UIScrollView()
    
    private let songListVC = SongListViewController()
    private let audioBookVC = AudioBookListViewController()
    
    private var searchTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupUI()
        setupChildVCs()
    }
    
    private func setupSearchController() {
        searchController.searchBar.placeholder = "Şarkı veya Sesli Kitap Ara"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "bg")

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .systemPurple
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.systemPurple], for: .normal)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        view.addSubview(segmentedControl)
        view.addSubview(scrollView)
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupChildVCs() {
        addChild(songListVC)
        scrollView.addSubview(songListVC.view)
        songListVC.didMove(toParent: self)

        addChild(audioBookVC)
        scrollView.addSubview(audioBookVC.view)
        audioBookVC.didMove(toParent: self)

        songListVC.view.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.equalTo(scrollView.snp.height)
        }

        audioBookVC.view.snp.makeConstraints { make in
            make.leading.equalTo(songListVC.view.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.equalTo(scrollView.snp.height)
            make.trailing.equalToSuperview()
        }
    }
    
    @objc private func segmentChanged() {
        let index = segmentedControl.selectedSegmentIndex
        let offset = CGPoint(x: CGFloat(index) * scrollView.frame.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
}

extension MainTabViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        segmentedControl.selectedSegmentIndex = index
    }
}

extension MainTabViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            if segmentedControl.selectedSegmentIndex == 0 {
                MusicManager.shared.loadPlayedSongs()
                songListVC.updateSongs(MusicManager.shared.playedSongs)
            } else {
                MusicManager.shared.loadPlayedAudioBooks()
                audioBookVC.updateAudioBooks(MusicManager.shared.playedAudioBooks)
            }
            return
        }

        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if self.segmentedControl.selectedSegmentIndex == 0 {
                MusicManager.shared.searchSongs(query: searchText) { result in
                    switch result {
                    case .success(let fetchedSongs):
                        DispatchQueue.main.async {
                            self.songListVC.updateSongs(fetchedSongs)
                        }
                    case .failure(let error):
                        print("Şarkı arama hatası: \(error.localizedDescription)")
                    }
                }
            } else {
                MusicManager.shared.searchAudioBooks(query: searchText) { result in
                    switch result {
                    case .success(let fetchedAudioBooks):
                        DispatchQueue.main.async {
                            self.audioBookVC.updateAudioBooks(fetchedAudioBooks)
                        }
                    case .failure(let error):
                        print("audio book arama hatası: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTimer?.invalidate()
        if segmentedControl.selectedSegmentIndex == 0 {
            MusicManager.shared.loadPlayedSongs()
            songListVC.updateSongs(MusicManager.shared.playedSongs)
        } else {
            MusicManager.shared.loadPlayedAudioBooks()
            audioBookVC.updateAudioBooks(MusicManager.shared.playedAudioBooks)
        }
    }
}
