//
//  MainTabBarController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 28.05.2025.
//

import UIKit
import SnapKit

final class MainTabBarController: UITabBarController {
    
    private let miniPlayer = MiniPlayerView()
    private var miniPlayerBottomConstraint: Constraint?
    private var miniPlayerHeightConstraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupMiniPlayer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMiniPlayerFromNotification), name: .musicStatusUpdate, object: nil)
        updateMiniPlayerAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(miniPlayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true) // navigation bar gizleme üstteki boşluk için
    }
    
    private func setupTabs() {
        
        let mainTabVC = MainTabViewController()
        let mainNavController = UINavigationController(rootViewController: mainTabVC)
        mainNavController.tabBarItem = UITabBarItem(title: "Ana Sayfa", image: UIImage(systemName: "music.note.house"),
                                                    selectedImage: UIImage(systemName: "music.note.house.fill"))
        
        let exploreVC = ExploreViewController()
        let exploreNavController = UINavigationController(rootViewController: exploreVC)
        exploreNavController.tabBarItem = UITabBarItem(title: "Keşfet", image: UIImage(systemName: "safari"), selectedImage: UIImage(systemName: "safari.fill"))
        
        let profileVC = ProfileViewController()
        let profileNavController = UINavigationController(rootViewController: profileVC)
        profileNavController.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        viewControllers = [mainNavController, exploreNavController, profileNavController]
        
        tabBar.tintColor = .systemPurple
        tabBar.unselectedItemTintColor = .gray
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "bg") ?? .systemGray6
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes  = [.foregroundColor: UIColor.gray]
        appearance.stackedLayoutAppearance.selected.iconColor = .systemPurple
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemPurple]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
    }
    
    private func setupMiniPlayer() {
        miniPlayer.isUserInteractionEnabled = true
        miniPlayer.isHidden = true
        view.addSubview(miniPlayer)
        
        miniPlayer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            miniPlayerBottomConstraint = make.bottom.equalTo(tabBar.snp.top).offset(-8).constraint
            miniPlayerHeightConstraint = make.height.equalTo(70).constraint
        }
        
        miniPlayer.playPauseButton.addTarget(self, action: #selector(didTapMiniPlayerPlayPause), for: .touchUpInside)
        miniPlayer.tapAction = { [weak self] in self?.presentDetailPlayer() }
    }
    
    func updateMiniPlayerAppearance() {
        var imageURL: String?
        var title: String?
        var artist: String?
        var showMiniPlayer = false
        
        if let currentSong = MusicManager.shared.getCurrentSong() {
            imageURL = currentSong.artworkUrl100
            title = currentSong.trackName
            artist = currentSong.artistName
            showMiniPlayer = true
        } else if let currentAudioBook = MusicManager.shared.getCurrentAudioBook() {
            imageURL = currentAudioBook.artworkUrl100
            title = currentAudioBook.collectionName
            artist = currentAudioBook.artistName
            showMiniPlayer = true
        }
        
        let targetHeight: CGFloat = showMiniPlayer ? 70 : 0
        let targetAlpha: CGFloat = showMiniPlayer ? 1 : 0
        let targetHidden = !showMiniPlayer
        
        if miniPlayer.isHidden == targetHidden && miniPlayer.alpha == targetAlpha {
            if showMiniPlayer {
                miniPlayer.configure(imageURL: imageURL, title: title, artist: artist)
                miniPlayer.updatePlayPauseButton(isPlaying: MusicManager.shared.isPlaying)
            }
            return
        }
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.miniPlayer.alpha = targetAlpha
                self.miniPlayerHeightConstraint?.update(offset: targetHeight)
                self.view.layoutIfNeeded()
            },
            completion: { completed in
                if completed {
                    self.miniPlayer.isHidden = targetHidden
                    if showMiniPlayer {
                        self.miniPlayer.configure(imageURL: imageURL, title: title, artist: artist)
                        self.miniPlayer.updatePlayPauseButton(isPlaying: MusicManager.shared.isPlaying)
                    } else {
                        self.miniPlayer.updatePlayPauseButton(isPlaying: false)
                    }
                }
            }
        )
        
    }
    
    func presentDetailPlayer() {
        if let song = MusicManager.shared.getCurrentSong() {
            let index = MusicManager.shared.playedSongs.firstIndex(where: { $0.previewUrl == song.previewUrl }) ?? 0
            let viewController = DetailViewController(
                songs: MusicManager.shared.playedSongs,
                selectedIndex: index,
                shouldStartPlayback: false
            )
            presentCustomModal(viewController)
        } else if let book = MusicManager.shared.getCurrentAudioBook() {
            let index = MusicManager.shared.playedAudioBooks.firstIndex(where: { $0.previewUrl == book.previewUrl }) ?? 0
            let viewController = AudioBookDetailViewController(
                audioBooks: MusicManager.shared.playedAudioBooks,
                selectedIndex: index,
                shouldStartPlayback: false
            )
            presentCustomModal(viewController)
        }
    }
    
    @objc private func didTapMiniPlayerPlayPause() {
        if MusicManager.shared.isPlaying {
            MusicManager.shared.pause()
        } else {
            MusicManager.shared.play()
        }
        updateMiniPlayerAppearance()
    }
    
    @objc private func updateMiniPlayerFromNotification() {
        updateMiniPlayerAppearance()
    }
    
}
