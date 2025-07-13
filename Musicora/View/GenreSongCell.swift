//
//  GenreSongCell.swift
//  Musicora
//
//  Created by Bora Gündoğu on 25.06.2025.
//

import UIKit
import SnapKit

final class GenreSongCell: UITableViewCell {
    
    static let reuseIdentifier = "GenreSongCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var songImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor.systemGray5
        return imageView
    }()
    
    private lazy var songLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let pressedScale: CGFloat = 0.95
    private let pressedAlpha: CGFloat = 0.8
    private let animationDuration: TimeInterval = 0.15
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(songImageView)
        containerView.addSubview(songLabel)
        containerView.addSubview(artistLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
            make.height.equalTo(72)
        }
        
        songImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(56)
        }
        
        songLabel.snp.makeConstraints { make in
            make.left.equalTo(songImageView.snp.right).offset(12)
            make.top.equalTo(songImageView.snp.top).offset(8)
            make.right.equalToSuperview().offset(-16)
        }
        
        artistLabel.snp.makeConstraints { make in
            make.left.equalTo(songLabel)
            make.bottom.equalTo(songImageView.snp.bottom).offset(-8)
            make.right.equalTo(songLabel)
        }
    }
    
    func configure(with song: Song) {
        songLabel.text = song.trackName
        artistLabel.text = song.artistName
        songImageView.image = nil
        if let url = URL(string: song.artworkUrl100) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self?.songImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
    
    func animateSelection() {
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
            self.containerView.transform = CGAffineTransform(scaleX: self.pressedScale, y: self.pressedScale)
            self.containerView.alpha = self.pressedAlpha
        }, completion: { _ in
            UIView.animate(withDuration: self.animationDuration * 1.2,
                           delay: 0,
                           options: [.curveEaseInOut, .allowUserInteraction],
                           animations: {
                self.containerView.transform = .identity
                self.containerView.alpha = 1.0
            })
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.transform = .identity
        containerView.alpha = 1.0
        songImageView.image = nil
    }
}
