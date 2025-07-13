//
//  ExploreCell.swift
//  Musicora
//
//  Created by Bora Gündoğu on 4.06.2025.
//

import UIKit
import SnapKit

final class SongCellExplore: UICollectionViewCell {
    static let reuseIdentifier = "SongCellExplore"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(contentView.snp.width)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with song: Song) {
        titleLabel.text = song.trackName
        artistLabel.text = song.artistName
        imageView.image = nil
        if let url = URL(string: song.artworkUrl100) {
            ImageLoader.shared.loadImage(from: url) { [weak self] image in
                self?.imageView.image = image
            }
        }
    }
}

final class GenreCellExplore: UICollectionViewCell {
    static let reuseIdentifier = "GenreCellExplore"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(nameLabel)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.0).cgColor,
                                 UIColor.black.withAlphaComponent(0.6).cgColor]
        gradientLayer.locations = [0.5, 1.0]
        gradientLayer.frame = bounds
        backgroundImageView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradient = backgroundImageView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradient.frame = bounds
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with genre: GenreItem, at index: Int) {
        nameLabel.text = genre.name
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemOrange,
            .systemPurple, .systemTeal, .systemIndigo, .systemBrown
        ]
        let color = colors[index % colors.count]
        backgroundImageView.backgroundColor = color.withAlphaComponent(0.8)
    }

}

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
