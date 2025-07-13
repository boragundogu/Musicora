//
//  DetailViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 24.03.2025.
//

import UIKit
import SnapKit
import CoreMedia

final class DetailViewController: UIViewController {
    
    private let songs: [Song]
    private let selectedIndex: Int
    private let musicManager = MusicManager.shared
    private let detailView: DetailView
    private let shouldStartPlayback: Bool
    
    init(songs: [Song], selectedIndex: Int, shouldStartPlayback: Bool = true) {
        self.songs = songs
        self.selectedIndex = selectedIndex
        self.detailView = DetailView(song: songs[selectedIndex])
        self.shouldStartPlayback = shouldStartPlayback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialPlaybackSetup()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDelegateAndUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notifyMiniPlayer()
    }
    
    private func initialPlaybackSetup() {
        if shouldStartPlayback {
            musicManager.setSongs(self.songs, startingAt: self.selectedIndex)
            musicManager.playCurrentSong()
        }
    }
    
    private func configureDelegateAndUI() {
        musicManager.delegate = self
        if let currentSong = musicManager.getCurrentSong() {
            detailView.configureView(with: currentSong)
        }
        updatePlayButtonImage()
        updateWaveAnimation()
    }
    
    private func notifyMiniPlayer() {
        NotificationCenter.default.post(name: .miniPlayerShouldUpdate, object: nil)
    }
    
    private func setupActions() {
        detailView.previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        detailView.playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        detailView.nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        detailView.tenSecondBackward.addTarget(self, action: #selector(tenSecondBackward), for: .touchUpInside)
        detailView.tenSecondForward.addTarget(self, action: #selector(tenSecondForward), for: .touchUpInside)
        detailView.slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        detailView.slider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    private func updatePlayButtonImage() {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let imageName = musicManager.isPlaying ? "pause.circle.fill" : "play.circle.fill"
        detailView.playButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    private func updateWaveAnimation() {
        if musicManager.isPlaying {
            detailView.playWaveAnimation()
        } else {
            detailView.stopWaveAnimation()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        detailView.currentTimeLabel.text = formatTime(TimeInterval(sender.value))
    }
    
    @objc private func sliderTouchUp(_ sender: UISlider) {
        guard let player = musicManager.player else { return }
        let newTime = CMTime(seconds: Double(sender.value), preferredTimescale: 1000)
        player.seek(to: newTime) { [weak self] completed in
            if completed {
                self?.musicManager.updateNowPlayingPlaybackInfo()
            }
        }
    }
    
    @objc private func previousTapped() {
        musicManager.previous()
    }
    
    @objc private func playTapped() {
        if musicManager.isPlaying {
            musicManager.pause()
        } else {
            musicManager.play()
        }
        updatePlayButtonImage()
        updateWaveAnimation()
    }
    
    @objc private func nextTapped() {
        musicManager.next()
    }
    
    @objc private func tenSecondBackward() {
        guard let player = musicManager.player, let currentItem = player.currentItem else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTimeValue = max(0, currentTime - 10)
        player.seek(to: CMTime(seconds: newTimeValue, preferredTimescale: currentItem.duration.timescale))
    }
    
    @objc private func tenSecondForward() {
        guard let player = musicManager.player, let currentItem = player.currentItem, currentItem.duration.isNumeric else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let duration = CMTimeGetSeconds(currentItem.duration)
        let newTimeValue = min(duration, currentTime + 10)
        player.seek(to: CMTime(seconds: newTimeValue, preferredTimescale: currentItem.duration.timescale))
    }
}

extension DetailViewController: MusicManagerDelegate {
    func didChangeAudioBooks(_ audioBooks: AudioBook) {}
    
    func didChangeSong(_ song: Song) {
        detailView.configureView(with: song)
        updatePlayButtonImage()
        updateWaveAnimation()
    }
    
    func didUpdatePlayback(currentTime: TimeInterval, duration: TimeInterval) {
        guard duration.isFinite, !duration.isNaN, duration > 0 else {
            detailView.slider.value = 0
            detailView.slider.maximumValue = 1
            detailView.slider.isEnabled = false
            detailView.currentTimeLabel.text = formatTime(0)
            detailView.durationLabel.text = formatTime(0)
            return
        }

        detailView.slider.isEnabled = true
        detailView.slider.maximumValue = Float(duration)
        
        if !detailView.slider.isTracking {
            detailView.slider.value = Float(currentTime)
            detailView.currentTimeLabel.text = formatTime(currentTime)
        }
        detailView.durationLabel.text = formatTime(duration)
    }
}

extension DetailViewController: CustomModalPresentable {
    var longFormHeight: CGFloat {
        return UIScreen.main.bounds.height * 0.9
    }
    
    var cornerRadius: CGFloat {
        return 16
    }
    
    var allowsDismissalByPan: Bool {
        return true
    }
    
    var allowsDismissalByTap: Bool {
        return true
    }
}
