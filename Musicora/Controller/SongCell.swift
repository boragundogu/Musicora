//
//  SongCell.swift
//  Musicora
//
//  Created by Bora Gündoğu on 24.03.2025.
//

import UIKit
import SnapKit
import Lottie

final class SongCell: UITableViewCell {
    
    private lazy var songImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    lazy var songLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .lightGray
        return label
    }()
    
    private let pressedScale: CGFloat = 0.98 // küçülme
    private let pressedAlpha: CGFloat = 0.7 // soluklaşma
    private let animationDuration: TimeInterval = 0.10 // tepki
    
    var longPressAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        addLongPressGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.selectionStyle = .none
        contentView.addSubview(songImageView)
        contentView.addSubview(songLabel)
        contentView.addSubview(artistLabel)
        
        songImageView.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        songLabel.snp.makeConstraints { make in
            make.top.equalTo(songImageView.snp.top).offset(5)
            make.left.equalTo(songImageView.snp.left).offset(60)
            
        }
        
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(songLabel.snp.bottom).offset(3)
            make.left.equalTo(songLabel)
            make.right.equalTo(songLabel)
        }
    }
    
    func configure(with song: Song) {
        songLabel.text = song.trackName
        artistLabel.text = song.artistName
        
        if let url = URL(string: song.artworkUrl100) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    DispatchQueue.main.async {
                        self.songImageView.image = UIImage(data: data)
                    }
                } else {
                    print("resim hata \(error?.localizedDescription ?? "")")
                }
            }.resume()
        }
    }
    
    private func addLongPressGesture() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.05
        longPressRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            animateOnPress()
        case .ended, .cancelled:
            animateOnRelease {
                if gestureRecognizer.state == .ended {
                    let touchPoint = gestureRecognizer.location(in: self)
                    if self.bounds.contains(touchPoint) {
                        self.longPressAction?()
                    }
                }
            }
        case .changed:
            let touchPoint = gestureRecognizer.location(in: self)
            if !self.bounds.contains(touchPoint) {
                animateOnRelease(resetOnly: true)
                gestureRecognizer.isEnabled = false
                gestureRecognizer.isEnabled = true
            }
        default:
            break
        }
    }
    
    private func animateOnPress() {
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
            self.contentView.transform = CGAffineTransform(scaleX: self.pressedScale, y: self.pressedScale)
            self.contentView.alpha = self.pressedAlpha
        }, completion: nil)
    }
    
    private func animateOnRelease(resetOnly: Bool = false, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration * 1.5,
                       delay: 0,
                       options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.contentView.transform = .identity
            self.contentView.alpha = 1.0
        }, completion: { finished in
            if finished {
                if !resetOnly {
                    completion?()
                }
            }
        })
    }
    
    override func prepareForReuse() { // hücreyi yeniden kullanımadan önce sıfırlamaa
        super.prepareForReuse()
        contentView.transform = .identity
        contentView.alpha = 1.0
    }
}
