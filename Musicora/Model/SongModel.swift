//
//  SongModel.swift
//  Musicora
//
//  Created by Bora Gündoğu on 24.03.2025.
//

import Foundation
import UIKit

struct Song: Codable, Hashable {
    let trackName: String
    let artistName: String
    let artworkUrl100: String
    let previewUrl: String
    let primaryGenreName: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackName)
        hasher.combine(previewUrl)
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.trackName == rhs.trackName && lhs.previewUrl == rhs.previewUrl
    }
    
    let wrapperType: String?
}

struct SearchResponse: Decodable {
    let results: [Song]
}

struct GenreItem: Hashable {
    let name: String
    let genreId: Int
}

struct AppleMusicFeedResponse: Codable {
    let feed: Feed

    struct Feed: Codable {
        let results: [SongFeedItem]?
        let entry: [EntryItem]? 

        var songIds: [String] {
            if let results = results {
                return results.map { $0.id }
            } else if let entry = entry {
                return entry.compactMap { $0.id.attributes["im:id"] }
            } else {
                return []
            }
        }
    }

    struct SongFeedItem: Codable {
        let id: String
    }

    struct EntryItem: Codable {
        let id: EntryID
        struct EntryID: Codable {
            let attributes: [String: String]
        }
    }
}

enum ExploreSectionType: Int, CaseIterable {
    case newSongs
    case genres
}

enum ExploreItemType: Hashable {
    case song(Song)
    case genre(GenreItem)
}
