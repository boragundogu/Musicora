//
//  AudioBookDetailView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 17.05.2025.
//

import UIKit
import SnapKit
import Lottie

final class AudioBookDetailView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var audioBookLabel: UILabel = {
       let label = UILabel()
       label.font = .boldSystemFont(ofSize: 18)
       label.textColor = .white
       return label
   }()
   
    lazy var artistLabel: UILabel = {
       let label = UILabel()
       label.font = .boldSystemFont(ofSize: 16)
       label.textColor = .gray
       return label
   }()
    
    lazy var previousButton: UIButton = {
       let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        button.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: config), for: .normal)
       button.tintColor = .white
       return button
   }()
   
    lazy var playButton: UIButton = {
       let button = UIButton()
       button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
       button.tintColor = .white
       return button
   }()
   
    lazy var nextButton: UIButton = {
       let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
       button.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: config), for: .normal)
       button.tintColor = .white
       return button
   }()
   
   lazy var tenSecondBackward: UIButton = {
       let button = UIButton()
       let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
       button.setImage(UIImage(systemName: "gobackward.10", withConfiguration: config), for: .normal)
       button.tintColor = .white
       return button
   }()
   
   lazy var tenSecondForward: UIButton = {
       let button = UIButton()
       let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
       button.setImage(UIImage(systemName: "goforward.10", withConfiguration: config), for: .normal)
       button.tintColor = .white
       return button
   }()
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .systemPurple
        slider.maximumTrackTintColor = .lightGray
        slider.thumbTintColor = .white
        slider.minimumValue = 0
        slider.maximumValue = 1
        return slider
    }()
    
    lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .lightGray
        return label
    }()
    
    lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .lightGray
        return label
    }()
    
    lazy var waveAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "music_wave")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    convenience init(audioBook: AudioBook) {
        self.init()
        configureView(with: audioBook)
        setupUI()
    }
    
    // swiftlint:disable:next function_body_length
    private func setupUI() {
        
        setupGradientBackground()
        backgroundColor = UIColor(named: "bg")
        
        [imageView, audioBookLabel, artistLabel, previousButton, playButton, nextButton,
         tenSecondBackward, tenSecondForward, slider, currentTimeLabel, durationLabel, waveAnimationView
        ].forEach {addSubview($0)}
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(350)
        }
        
        audioBookLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(50)
            make.leading.equalTo(imageView.snp.leading)
        }
        
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(audioBookLabel.snp.bottom).offset(20)
            make.leading.equalTo(audioBookLabel.snp.leading)
        }
        
        waveAnimationView.snp.makeConstraints { make in
            make.centerY.equalTo(audioBookLabel)
            make.width.height.equalTo(250)
            make.centerX.equalTo(imageView.snp.trailing).offset(-40)
        }
        
        slider.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(4)
            make.leading.equalTo(slider.snp.leading)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(4)
            make.trailing.equalTo(slider.snp.trailing)
        }
        
        playButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(slider.snp.bottom).offset(40)
            make.width.height.equalTo(70)
        }
        
        previousButton.snp.makeConstraints { make in
            make.trailing.equalTo(playButton.snp.leading).offset(-5)
            make.centerY.equalTo(playButton)
            make.width.height.equalTo(50)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(playButton.snp.trailing).offset(5)
            make.centerY.equalTo(playButton)
            make.width.height.equalTo(50)
        }
        
        tenSecondBackward.snp.makeConstraints { make in
            make.trailing.equalTo(previousButton.snp.leading).offset(-5)
            make.centerY.equalTo(previousButton)
            make.width.height.equalTo(50)
        }
        
        tenSecondForward.snp.makeConstraints { make in
            make.leading.equalTo(nextButton.snp.trailing).offset(5)
            make.centerY.equalTo(nextButton)
            make.width.height.equalTo(50)
        }
        
    }
 
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemPurple.cgColor,
            UIColor(named: "bg")!
        ]
        gradientLayer.locations = [0.2, 1.0]
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at: 0) // mevcut view'ın alt katmanına yerleştirir
        
        // layer.masksToBounds = true cornerRadius gibi durumlarda dışarı taşmayı engeller.
        self.layoutIfNeeded() // view'ın layout güncellemelerini hemen şimdi uygula der.
        
        DispatchQueue.main.async {
            gradientLayer.frame = self.bounds
        }
    }
    
    func playWaveAnimation() {
        waveAnimationView.play()
    }
    
    func stopWaveAnimation() {
        waveAnimationView.stop()
    }
    
    func configureView(with audioBook: AudioBook) {
        audioBookLabel.text = audioBook.collectionName
        artistLabel.text = audioBook.artistName
        
        if let url = URL(string: audioBook.artworkUrl100.replacingOccurrences(of: "100x100bb", with: "600x600bb")) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                } else {
                    print("resim hatası \(error?.localizedDescription ?? "")")
                }
            }.resume()
        }
    }
}
