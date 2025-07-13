//
//  MiniPlayerView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 26.05.2025.
//

import UIKit
import SnapKit
import Lottie

final class MiniPlayerView: UIView {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    
    let playPauseButton: UIButton = { 
        let button = UIButton(type: .system)
        button.tintColor = .systemPurple
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        return button
    }()
    
    lazy var waveAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "music_wave")
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.isHidden = true
        animationView.backgroundBehavior = .pauseAndRestore
        return animationView
    }()

    var tapAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addSubviews()
        setupConstraints()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor.systemGray6.withAlphaComponent(0.95)
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }

    private func addSubviews() {
        addSubview(imageView)
        addSubview(labelsStackView)
        addSubview(waveAnimationView)
        addSubview(playPauseButton)
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }

        labelsStackView.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(waveAnimationView.snp.leading).offset(-8)
        }
        
        waveAnimationView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(playPauseButton.snp.leading).offset(40)
            make.width.height.equalTo(120)
        }

        playPauseButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(38)
        }
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
    }

    @objc private func viewTapped(_ gesture: UITapGestureRecognizer) {
   
        let location = gesture.location(in: self)
        if playPauseButton.frame.contains(location) {
            return
        }
        tapAction?()
    }
    
    func configure(imageURL: String?, title: String?, artist: String?) {
        if let urlString = imageURL, let url = URL(string: urlString) {
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }.resume()
        } else {
            imageView.image = UIImage(systemName: "music.note")
        }
        titleLabel.text = title ?? "Unknown Title"
        artistLabel.text = artist ?? "Unknown Artist"
    }
    
    func updatePlayPauseButton(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        if isPlaying {
            waveAnimationView.isHidden = false
            if !waveAnimationView.isAnimationPlaying {
                waveAnimationView.play()
            }
        } else {
            waveAnimationView.isHidden = true
            if waveAnimationView.isAnimationPlaying {
                waveAnimationView.stop()
            }
        }
    }
}
