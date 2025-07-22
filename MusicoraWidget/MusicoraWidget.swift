//
//  MusicoraWidget.swift
//  MusicoraWidget
//
//  Created by Bora Gündoğu on 11.07.2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    let sharedDefaults = UserDefaults(suiteName: "group.com.boragundogu.musicora")
    let playedSongsKey = "PlayedSongsKey"
    
    func placeholder(in context: Context) -> SongEntry {
        let placeholderSongs = [
            Song(trackName: "Müzik-1", artistName: "Bora", artworkUrl100: "", previewUrl: "", primaryGenreName: "", wrapperType: "")
            
        ]
        return SongEntry(date: Date(), songs: placeholderSongs, artworkData: [:])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SongEntry) -> Void) {
        let songs = loadSongsFromDefaults()
        
        Task {
            let artworkData = await fetchArtworkData(for: songs)
            let entry = SongEntry(date: Date(), songs: songs, artworkData: artworkData) // songs'a songs vermek ilk seçim ekranında live data kullanımını sağlıyor,
            completion(entry)
        }
        
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SongEntry>) -> Void) {
        let songs = loadSongsFromDefaults()
        
        Task {
            let artworkData = await fetchArtworkData(for: songs)
            let entry = SongEntry(date: Date(), songs: songs, artworkData: artworkData)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func fetchArtworkData(for songs: [Song]) async -> [String: Data] {
        var artworkData: [String: Data] = [:]
        
        await withTaskGroup(of: (String, Data?).self) { group in
            for song in songs {
                group.addTask {
                    guard let url = URL(string: song.artworkUrl100) else {
                        return (song.trackName, nil)
                    }
                    
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        return (song.trackName, data)
                    } catch {
                        return (song.trackName, nil)
                    }
                }
            }
            
            for await (trackName, data) in group {
                if let data = data {
                    artworkData[trackName] = data
                }
            }
        }
        return artworkData
    }
    
    private func loadSongsFromDefaults() -> [Song] {
        guard let defaults = sharedDefaults, let data = defaults.data(forKey: playedSongsKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Song].self, from: data)
        } catch {
            print("Widget veri hatası")
            return []
        }
    }
    
}

struct SongEntry: TimelineEntry {
    let date: Date
    let songs: [Song]
    let artworkData: [String: Data]
}

struct MusicoraWidgetEntryView: View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    private var songLimit: Int {
        switch family {
        case .systemMedium:
            return 2
        case .systemLarge:
            return 6
        default:
            return 1
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Son Çalınanlar")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary.opacity(0.8))
                .padding()
            
            if entry.songs.isEmpty {
                Spacer()
                Text("Henüz şarkı çalmadınız. Musicora ile şimdi başlayın!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            } else {
                ForEach(entry.songs.prefix(songLimit).reversed(), id: \.trackName) { song in
                    VStack(alignment: .leading) {
                        HStack {
                            if let data = entry.artworkData[song.trackName], let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill()
                                    .frame(width: 25, height: 25)
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .foregroundColor(.white.opacity(0.7))
                                    )
                            }
                            VStack(alignment: .leading) {
                                Text(song.trackName)
                                    .font(.system(size: 12, weight: .semibold))
                                    .lineLimit(1)
                                
                                Text(song.artistName)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(5)
                }
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct MusicoraWidget: Widget {
    let kind: String = "MusicoraWidget"
    @Environment(\.widgetFamily) var family
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MusicoraWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Son Çalınanlar")
        .description("En son çaldığınız şarkıları ana ekranınızda görüntüleyin.")
        .supportedFamilies([.systemMedium, .systemLarge])

    }
}
