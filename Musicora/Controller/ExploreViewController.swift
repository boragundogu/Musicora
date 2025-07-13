//
//  ExploreViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 28.05.2025.
//

import UIKit
import SnapKit

final class ExploreViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<ExploreSectionType, ExploreItemType>!
    
    private var newSongs: [Song] = []
    private let popularGenres: [GenreItem] = [
        GenreItem(name: "Pop", genreId: 14),
        GenreItem(name: "Rock", genreId: 21),
        GenreItem(name: "Hip-Hop/Rap", genreId: 18),
        GenreItem(name: "Electronic", genreId: 7),
        GenreItem(name: "Jazz", genreId: 11),
        GenreItem(name: "Classical", genreId: 5),
        GenreItem(name: "R&B/Soul", genreId: 15),
        GenreItem(name: "Country", genreId: 6)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bg") ?? .systemBackground
        setupCollectionView()
        configureDataSource()
        fetchTopSongsViaLookup()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.register(SongCellExplore.self, forCellWithReuseIdentifier: SongCellExplore.reuseIdentifier)
        collectionView.register(GenreCellExplore.self, forCellWithReuseIdentifier: GenreCellExplore.reuseIdentifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeaderView.reuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<ExploreSectionType, ExploreItemType>(collectionView: collectionView) { collectionView, indexPath, itemType in
            switch itemType {
            case .song(let song):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCellExplore.reuseIdentifier, for: indexPath) as? SongCellExplore else {
                    return UICollectionViewCell()
                }
                cell.configure(with: song)
                return cell
            case .genre(let genre):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCellExplore.reuseIdentifier, for: indexPath) as? GenreCellExplore else {
                    return UICollectionViewCell()
                }
                cell.configure(with: genre, at: indexPath.row)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                                                                                   for: indexPath) as? SectionHeaderView else {
                return nil
            }
            if let sectionType = ExploreSectionType(rawValue: indexPath.section) {
                headerView.titleLabel.text = sectionType == .newSongs ? "Top Şarkılar" : "Müzik Türleri"
            }
            return headerView
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let sectionType = ExploreSectionType(rawValue: sectionIndex) else { return nil }
            return sectionType == .newSongs ? self.createNewSongsSection() : self.createGenresSection()
        }
    }
    
    private func createNewSongsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .absolute(180))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    private func createGenresSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }
    
    private func fetchTopSongsViaLookup() {
        let topSongsFeed = "https://rss.applemarketingtools.com/api/v2/tr/music/most-played/20/songs.json"
        guard let feedURL = URL(string: topSongsFeed) else { return }
        
        URLSession.shared.dataTask(with: feedURL) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else { return }
            do {
                let feedResponse = try JSONDecoder().decode(AppleMusicFeedResponse.self, from: data)
                let ids = feedResponse.feed.songIds.joined(separator: ",")
                self.lookupSongs(by: ids)
            } catch {
                print("Feed parsing error: \(error)")
            }
        }.resume()
    }
    
    private func lookupSongs(by ids: String) {
        let lookupURL = "https://itunes.apple.com/lookup?id=\(ids)&country=tr"
        guard let url = URL(string: lookupURL) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else { return }
            do {
                let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.newSongs = searchResponse.results
                    self.applySnapshot()
                }
            } catch {
                print("Lookup decoding error: \(error)")
            }
        }.resume()
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<ExploreSectionType, ExploreItemType>()
        
        if !newSongs.isEmpty {
            snapshot.appendSections([.newSongs])
            let songItems = newSongs.map { ExploreItemType.song($0) }
            snapshot.appendItems(songItems, toSection: .newSongs)
        }
        
        if !popularGenres.isEmpty {
            snapshot.appendSections([.genres])
            let genreItems = popularGenres.map { ExploreItemType.genre($0) }
            snapshot.appendItems(genreItems, toSection: .genres)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ExploreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemType = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch itemType {
        case .song(let song):
            MusicManager.shared.setSongs(newSongs, startingAt: newSongs.firstIndex(of: song) ?? 0)
            MusicManager.shared.playCurrentSong()
        case .genre(let genre):
            let searchVC = SearchedGenreSongsViewController(genreName: genre.name, genreId: genre.genreId)
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }
}
