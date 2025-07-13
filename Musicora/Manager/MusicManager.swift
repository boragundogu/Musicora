//
//  MusicManager.swift
//  Musicora
//
//  Created by Bora Gündoğu on 1.04.2025.
//

import Foundation
import AVFoundation
import Alamofire
import MediaPlayer
import WidgetKit

protocol MusicManagerDelegate: AnyObject {
    func didChangeSong(_ song: Song)
    func didChangeAudioBooks(_ audioBooks: AudioBook)
    
    func didUpdatePlayback(currentTime: TimeInterval, duration: TimeInterval)
}

// swiftlint:disable:next type_body_length
final class MusicManager: NSObject {
    
    static let shared = MusicManager()
    
    var player: AVPlayer?
    private var currentPlayerItem: AVPlayerItem?
    
    var nowPlayingInfo = [String: Any]()
    
    private var songs: [Song] = []
    private var audioBooks: [AudioBook] = []
    
    private let sharedDefaults = UserDefaults(suiteName: "group.com.boragundogu.musicora")
    
    var playedSongs: [Song] = []
    var playedAudioBooks: [AudioBook] = []
    
    private let playedSongsKey = "PlayedSongsKey"
    private let playedAudioBooksKey = "PlayedAudioBooksKey"
    
    private var playerItemStatusObservation: NSKeyValueObservation?
    
    private var currentIndex: Int = 0
    private var currentAudioBookIndex: Int = 0
    private(set) var isPlaying: Bool = false
    private var timeObserver: Any?
    
    enum MediaType {
        case song, audiobook, none
    }
    
    private(set) var currentMediaType: MediaType = .none
    
    weak var delegate: MusicManagerDelegate?
    
    private override init() {
        super.init()
        setupAudioSession()
        setupRemoteTransportControls()
        loadPlayedSongs()
        loadPlayedAudioBooks()
    }
    
    func setSongs(_ newSongs: [Song], startingAt index: Int) {
        guard !newSongs.isEmpty, index < newSongs.count else {
            return
        }
        
        self.songs = newSongs
        self.currentIndex = index
    }
    
    func setAudioBooks(_ newAudioBooks: [AudioBook], startingAt index: Int) {
        guard !newAudioBooks.isEmpty, index < newAudioBooks.count else {
            return
        }
        
        self.audioBooks = newAudioBooks
        self.currentAudioBookIndex = index
    }
    
    func searchSongs(query: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        let urlString = "https://itunes.apple.com/search?term=\(query)&entity=song"
        
        guard let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "Url Encoding Failed", code: 1)))
            return
        }
        
        AF.request(encodedUrl)
            .validate()
            .responseDecodable(of: SearchResponse.self) { response in
                switch response.result {
                case .success(let searchResponse):
                    completion(.success(searchResponse.results))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func searchAudioBooks(query: String, completion: @escaping (Result<[AudioBook], Error>) -> Void) {
        let urlString = "https://itunes.apple.com/search?term=\(query)&entity=audiobook"
        
        guard let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "URL encoding error", code: 1)))
            return
        }
        
        AF.request(encodedUrl)
            .validate()
            .responseDecodable(of: AudioBookSearchResponse.self) { response in
                switch response.result {
                case .success(let response):
                    completion(.success(response.results))
                case .failure(let error):
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("audiosession hata: \(error)")
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            self.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            self.pause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            if self.currentMediaType == .song {
                self.next()
            } else if self.currentMediaType == .audiobook {
                self.nextAudioBook()
            } else {
                return .noSuchContent
            }
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            if self.currentMediaType == .song {
                self.previous()
            } else if self.currentMediaType == .audiobook {
                self.previousAudioBook()
            } else {
                return .noSuchContent
            }
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget {[weak self] event -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                let time = CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                player?.seek(to: time) { [weak self] completed in
                    if completed {
                        self?.updateNowPlayingPlaybackInfo()
                    }
                }
                return .success
            }
            return .commandFailed
        }
    }
    
    private func updateNowPlayingInfo(title: String, artist: String?, albumTitle: String?, artworkURLString: String?, duration: TimeInterval?) {
        nowPlayingInfo = [:]
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        if let artist = artist, !artist.isEmpty {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        
        if let album = albumTitle, !album.isEmpty {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        }
        
        if let duration = duration, !duration.isNaN, !duration.isInfinite {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate ?? 0.0
        
        if let currentTime = player?.currentTime() {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(currentTime)
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        if let artworkURLString = artworkURLString, let artworkURL = URL(string: artworkURLString) {
            URLSession.shared.dataTask(with: artworkURL) { [weak self] data, _, error in
                guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else {
                    return
                }
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                
                self.nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                
                DispatchQueue.main.async {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
                }
            }.resume()
        }
    }
    
    func updateNowPlayingPlaybackInfo() {
        guard let player = player else {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            return
        }
        
        if let currentItem = player.currentItem, currentItem.status == .readyToPlay {
            let duration = CMTimeGetSeconds(currentItem.duration)
            if !duration.isNaN && !duration.isInfinite {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            }
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func playCurrentSong() {
        guard !songs.isEmpty, currentIndex < songs.count else {
            print("şarkı bulunamıyor || index hatalı")
            
            player?.pause()
            nowPlayingInfo = [:]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            return
        }
        
        player?.pause()
        
        removePeriodicTimeObserver()
        removePlayerItemObservers()
        
        let song = songs[currentIndex]
        
        guard let url = URL(string: song.previewUrl) else {
            print("şarkı dosyası bulunamıyor")
            currentMediaType = .none
            return
        }
        
        if !playedSongs.contains(where: { $0.previewUrl == song.previewUrl }) {
            playedSongs.append(song)
            savePlayedSongs()
        }
        
        let playerItem = AVPlayerItem(url: url)
        addPlayerItemObservers(for: playerItem)
        
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        currentMediaType = .song
        player?.play()
        isPlaying = true
        delegate?.didChangeSong(song)
        
        updateNowPlayingInfo(title: song.trackName,
                             artist: song.artistName,
                             albumTitle: song.trackName,
                             artworkURLString: song.artworkUrl100,
                             duration: nil)
        
        addPeriodicTimeObserver()
        observeNextSong()
        NotificationCenter.default.post(name: .musicStatusUpdate, object: nil)
    }
    
    func playCurrentAudioBooks() {
        guard !audioBooks.isEmpty, currentAudioBookIndex < audioBooks.count else {
            print("audiobooks bulunamıyor || index hatalı")
            player?.pause()
            nowPlayingInfo = [:]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            return
        }
        
        player?.pause()
        removePeriodicTimeObserver()
        removePlayerItemObservers()
        
        let audioBooks = audioBooks[currentAudioBookIndex]
        
        guard let url = URL(string: audioBooks.previewUrl) else {
            print("şarkı dosyası bulunamadı")
            currentMediaType = .none
            return
        }
        
        if !playedAudioBooks.contains(where: {$0.previewUrl == audioBooks.previewUrl}) {
            playedAudioBooks.append(audioBooks)
            savePlayedAudioBooks()
        }
        
        let playerItem = AVPlayerItem(url: url)
        addPlayerItemObservers(for: playerItem)
        
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        currentMediaType = .audiobook
        player?.play()
        isPlaying = true
        delegate?.didChangeAudioBooks(audioBooks)
        
        updateNowPlayingInfo(title: audioBooks.collectionName,
                             artist: audioBooks.artistName,
                             albumTitle: audioBooks.collectionName,
                             artworkURLString: audioBooks.artworkUrl100,
                             duration: nil)
        
        addPeriodicTimeObserver()
        observeNextAudioBook()
        NotificationCenter.default.post(name: .musicStatusUpdate, object: nil)
    }
    
    func savePlayedSongs() {
        guard let defaults = sharedDefaults else { return }
        do {
            let data = try JSONEncoder().encode(playedSongs)
            defaults.set(data, forKey: playedSongsKey)
            WidgetCenter.shared.reloadTimelines(ofKind: "MusicoraWidget")
        } catch {
            print("Played songs kaydetme hatası: \(error.localizedDescription)")
        }
    }

    func savePlayedAudioBooks() {
        do {
            let data = try JSONEncoder().encode(playedAudioBooks)
            UserDefaults.standard.set(data, forKey: playedAudioBooksKey)
        } catch {
            print("played audio books kaydetme hatası: \(error.localizedDescription)")
        }
    }
    
    func loadPlayedSongs() {
        guard let defaults = sharedDefaults, let data = defaults.data(forKey: playedSongsKey) else { return }
           do {
               playedSongs = try JSONDecoder().decode([Song].self, from: data)
           } catch {
               print("Played songs yükleme hatası: \(error.localizedDescription)")
           }

       }
    
    func loadPlayedAudioBooks() {
        guard let data = UserDefaults.standard.data(forKey: playedAudioBooksKey) else { return }
        do {
            playedAudioBooks = try JSONDecoder().decode([AudioBook].self, from: data)
        } catch {
            print("played audio books yükleme hatası: \(error.localizedDescription)")
        }
    }
        private func addPeriodicTimeObserver() {
            guard let player = player else { return }
            
            removePeriodicTimeObserver()

            let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard let self = self, let currentPlayer = self.player, let currentItem = currentPlayer.currentItem else { return }
                
                let currentTime = CMTimeGetSeconds(time)
                
                let duration = currentItem.duration.isNumeric ? CMTimeGetSeconds(currentItem.duration) : 0.0
                
                self.delegate?.didUpdatePlayback(currentTime: currentTime, duration: duration)
            
                self.updateNowPlayingPlaybackInfo()
            }
        }
    
    private func removePeriodicTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    private func observeNextSong() {
        NotificationCenter.default.removeObserver(self, name: AVPlayerItem.didPlayToEndTimeNotification, object: player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(reachNextSong), name: AVPlayerItem.didPlayToEndTimeNotification, object: player?.currentItem)
    }
    
    private func observeNextAudioBook() {
        NotificationCenter.default.removeObserver(self, name: AVPlayerItem.didPlayToEndTimeNotification, object: player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(reachNextAudioBook),
                                               name: AVPlayerItem.didPlayToEndTimeNotification, object: player?.currentItem)
    }
    
    private func observeStatusChanged() {
        NotificationCenter.default.post(name: .musicStatusUpdate, object: nil)
        
    }
    
    @objc private func reachNextSong() {
        next()
    }
    
    @objc private func reachNextAudioBook() {
        nextAudioBook()
    }
    
    func play() {
        player?.play()
        isPlaying = true
        NotificationCenter.default.post(name: .miniPlayerShouldUpdate, object: nil)
        updateNowPlayingPlaybackInfo()
        observeStatusChanged()
        
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        NotificationCenter.default.post(name: .miniPlayerShouldUpdate, object: nil)
        updateNowPlayingPlaybackInfo()
        observeStatusChanged()
    }
    
    func next() {
        guard !songs.isEmpty else { return }
        
        currentIndex = (currentIndex + 1) % songs.count
        NotificationCenter.default.post(name: .miniPlayerShouldUpdate, object: nil)
        playCurrentSong()
        observeStatusChanged()
    }
    
    func nextAudioBook() {
        guard !audioBooks.isEmpty else { return }
        
        currentAudioBookIndex = (currentAudioBookIndex + 1) % audioBooks.count
        NotificationCenter.default.post(name: .miniPlayerShouldUpdate, object: nil)
        playCurrentAudioBooks()
        observeStatusChanged()
    }
    
    func previous() {
        guard !songs.isEmpty else { return }
        
        currentIndex = (currentIndex - 1 + songs.count) % songs.count
        NotificationCenter.default.post(name: .miniPlayerShouldUpdate, object: nil)
        playCurrentSong()
        observeStatusChanged()
    }
    
    func previousAudioBook() {
        guard !audioBooks.isEmpty else { return }
        currentAudioBookIndex = (currentAudioBookIndex - 1 + audioBooks.count) % audioBooks.count
        
        playCurrentAudioBooks()
        observeStatusChanged()
    }
    
    func getCurrentSong() -> Song? {
            guard currentMediaType == .song, currentIndex < songs.count else { return nil }
            return songs[currentIndex]
        }
    
    func getCurrentAudioBook() -> AudioBook? {
            guard currentMediaType == .audiobook, currentAudioBookIndex < audioBooks.count else { return nil }
            return audioBooks[currentAudioBookIndex]
        }

    private func addPlayerItemObservers(for playerItem: AVPlayerItem) {
        removePlayerItemObservers()
        currentPlayerItem = playerItem
        playerItemStatusObservation = playerItem.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
            guard let self = self else { return }
            let status = item.status
            switch status {
            case .readyToPlay:
                if let duration = self.player?.currentItem?.duration, duration.isNumeric {
                    self.nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration.seconds
                    self.updateNowPlayingPlaybackInfo()
                } else {
                    print("Duration is not numeric or not available yet.")
                }
            case .failed:
                print("Player item failed. Error: \(String(describing: self.player?.currentItem?.error))")
                self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
            case .unknown:
                print("Player item status is unknown.")
            @unknown default:
                print("Unknown AVPlayerItem.Status")
            }
        }
    }
    
    private func removePlayerItemObservers() {
        playerItemStatusObservation?.invalidate()
        playerItemStatusObservation = nil
        currentPlayerItem = nil
    }
}
