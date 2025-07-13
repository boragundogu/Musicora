//
//  AudioBookModel.swift
//  Musicora
//
//  Created by Bora Gündoğu on 17.05.2025.
//

import Foundation

struct AudioBook: Codable, Equatable {
    
    let collectionName: String
    let artistName: String
    let artworkUrl100: String
    let previewUrl: String
}

struct AudioBookSearchResponse: Codable {
    let results: [AudioBook]
}
