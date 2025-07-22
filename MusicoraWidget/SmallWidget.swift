//
//  SmallWidget.swift
//  Musicora
//
//  Created by BoraGündoğdu on 16.07.2025.
//

import WidgetKit
import SwiftUI
import AppIntents

struct SmallWidgetEntry: TimelineEntry {
    let date: Date
    let song: Song
    let isPlaying: Bool
    let artworkImage: UIImage?
}

struct SmallWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SmallWidgetEntry {
        let placeholderSong = Song(trackName: "Musicora", artistName: "Select a Song", artworkUrl100: "nil", previewUrl: "", primaryGenreName: "", wrapperType: "")
        let placeholderImage = UIImage(systemName: "music.note")
        return SmallWidgetEntry(date: Date(), song: placeholderSong, isPlaying: false, artworkImage: placeholderImage)
    }

    func getSnapshot(in context: Context, completion: @escaping (SmallWidgetEntry) -> Void) {
        Task {
            let entry = await createTimelineEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SmallWidgetEntry>) -> Void) {
            Task {
                let entry = await createTimelineEntry()
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }

    private func createTimelineEntry() async -> SmallWidgetEntry {
            let musicManager = MusicManager.shared
            
            let song = musicManager.getCurrentSong()
            let isPlaying = musicManager.isPlaying && musicManager.currentMediaType == .song
            
            guard let currentSong = song else {
            
                let placeholderSong = Song(trackName: "Musicora",
                                           artistName: "Select a Song", artworkUrl100: "nil", previewUrl: "", primaryGenreName: "", wrapperType: "")
                return SmallWidgetEntry(date: Date(), song: placeholderSong, isPlaying: false, artworkImage: UIImage(systemName: "music.note"))
            }
            
            let artworkImage = await fetchArtwork(from: currentSong.artworkUrl100)
            return SmallWidgetEntry(date: Date(), song: currentSong, isPlaying: isPlaying, artworkImage: artworkImage)
        }

    private func fetchArtwork(from urlString: String?) async -> UIImage? {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return UIImage(systemName: "music.note")
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return UIImage(systemName: "music.note")
        }
    }
}

struct SmallWidgetEntryView: View {
    var entry: SmallWidgetProvider.Entry
    
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Image(uiImage: entry.artworkImage ?? UIImage(systemName: "music.note")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                VStack {
                    Text(entry.song.trackName)
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .lineLimit(1)
                    
                    Text(entry.song.artistName)
                        .font(.system(size: 11, weight: .regular, design: .default))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            HStack(spacing: 12) {
                Button(intent: PreviousSongIntent()) {
                    Image(systemName: "backward.fill")
                }
                .tint(.primary)
                
                Button(intent: PlayPauseIntent()) {
                    Image(systemName: entry.isPlaying ? "pause.fill" : "play.fill")
                }
                .tint(.primary)
                
                Button(intent: NextSongIntent()) {
                    Image(systemName: "forward.fill")
                }
                .tint(.primary)
            }
            .font(.system(size: 14))
            .padding(.top, 2)
        }
    }
}

struct SmallWidget: Widget {
    let kind: String = "SmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SmallWidgetProvider()) { entry in
            SmallWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Musicora Player")
        .description("Müzik listeni kontrol et.")
        .supportedFamilies([.systemSmall])
    }
}
