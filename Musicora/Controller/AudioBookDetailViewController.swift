//
//  AudioBookDetailViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 17.05.2025.
//

import UIKit
import SnapKit
import SwiftUI
import CoreMedia

final class AudioBookDetailViewController: UIViewController {
    
    private let audioBooks: [AudioBook]
    private let selectedIndex: Int
    private let musicManager = MusicManager.shared
    private let detailView: AudioBookDetailView
    private let shouldStartPlayback: Bool
    
    init(audioBooks: [AudioBook], selectedIndex: Int, shouldStartPlayback: Bool) {
        self.audioBooks = audioBooks
        self.selectedIndex = selectedIndex
        self.detailView = AudioBookDetailView(audioBook: audioBooks[selectedIndex])
        self.shouldStartPlayback = shouldStartPlayback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manageAudioBooks()
        updateUI()
        setupActions()
    }
    
    private func manageAudioBooks() {
        musicManager.delegate = self
        musicManager.setAudioBooks(audioBooks, startingAt: selectedIndex)
        musicManager.playCurrentAudioBooks()
    }
    
    private func updateUI() {
        if let currentAudioBook = musicManager.getCurrentAudioBook() {
            detailView.configureView(with: currentAudioBook)
        }
    }
    
    private func setupActions() {
        detailView.previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        detailView.playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        detailView.nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        detailView.tenSecondBackward.addTarget(self, action: #selector(tenSecondBackward), for: .touchUpInside)
        detailView.tenSecondForward.addTarget(self, action: #selector(tenSecondForward), for: .touchUpInside)
        detailView.slider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    private func updatePlayButtonImage() {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        if musicManager.isPlaying {
            detailView.playButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: config), for: .normal)
        } else {
            detailView.playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    @objc private func sliderTouchUp(_ sender: UISlider) {
        guard let player = musicManager.player else { return }
        let newTime = CMTime(seconds: Double(sender.value), preferredTimescale: 1000)
        player.seek(to: newTime)
    }
    
    @objc private func previousTapped() {
        musicManager.previousAudioBook()
    }
    
    @objc private func playTapped() {
        if musicManager.isPlaying {
            musicManager.pause()
            detailView.stopWaveAnimation()
        } else {
            musicManager.play()
            detailView.playWaveAnimation()
        }
        updatePlayButtonImage()
    }
    
    @objc private func nextTapped() {
        musicManager.nextAudioBook()
    }
    
    @objc private func tenSecondBackward() {
        guard let player = musicManager.player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = max(0, currentTime - 10)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1000))
    }
    
    @objc private func tenSecondForward() {
        guard let player = musicManager.player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = min(CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero), currentTime + 10)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1000))
    }
    
}

extension AudioBookDetailViewController: MusicManagerDelegate {
    func didChangeSong(_ song: Song) {
        
    }
    
    func didUpdatePlayback(currentTime: TimeInterval, duration: TimeInterval) {
  
        guard duration.isFinite, !duration.isNaN, duration > 0 else {
            detailView.slider.value = 0
            detailView.slider.maximumValue = 1
            detailView.slider.isEnabled = false
            detailView.currentTimeLabel.text = "0:00"
            detailView.durationLabel.text = "0:00"
            return
        }

        detailView.slider.isEnabled = true
        detailView.slider.maximumValue = Float(duration)
        detailView.slider.value = Float(currentTime)
        detailView.currentTimeLabel.text = formatTime(currentTime)
        detailView.durationLabel.text = formatTime(duration)
    }
    
    func didChangeAudioBooks(_ audioBooks: AudioBook) {
        detailView.configureView(with: audioBooks)
        updatePlayButtonImage()
        detailView.playWaveAnimation()
    }
}

extension AudioBookDetailViewController: CustomModalPresentable {
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
