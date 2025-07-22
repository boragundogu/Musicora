//
//  AppIntent.swift
//  MusicoraWidget
//
//  Created by BoraGündoğdu on 14.07.2025.
//

import WidgetKit
import AppIntents

struct PlayPauseIntent: AppIntent {
    static var title: LocalizedStringResource = "Play/Pause"

    func perform() async throws -> some IntentResult {
        let musicManager = MusicManager.shared
        if musicManager.currentMediaType != .song {
            if !musicManager.playedSongs.isEmpty {
                musicManager.setSongs(musicManager.playedSongs, startingAt: 0)
                musicManager.playCurrentSong()
            }
        } else if musicManager.isPlaying {
            musicManager.pause()
        } else {
            musicManager.play()
        }
        return .result()
    }
}

struct NextSongIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Song"

    func perform() async throws -> some IntentResult {
        MusicManager.shared.next()
        return .result()
    }
}

struct PreviousSongIntent: AppIntent {
    static var title: LocalizedStringResource = "Previous Song"

    func perform() async throws -> some IntentResult {
        MusicManager.shared.previous()
        return .result()
    }
}
