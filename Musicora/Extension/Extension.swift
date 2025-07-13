//
//  Extension.swift
//  Musicora
//
//  Created by Bora Gündoğu on 29.04.2025.
//

import Foundation
import UIKit

extension Notification.Name {
    static let playedSongsLoaded = Notification.Name("playedSongsLoaded")
    static let musicStatusUpdate = Notification.Name("musicStatusUpdate")
    
    static let playbackStateDidChange = Notification.Name("playbackStateDidChange")
    static let currentTrackDidChange = Notification.Name("currentTrackDidChange")
    static let playbackProgressDidUpdate = Notification.Name("playbackProgressDidUpdate")
    
    static let miniPlayerShouldUpdate = Notification.Name("miniPlayerShouldUpdate")
}

extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { self.image = nil; return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.image = nil
                }
            }
        }
    }
}

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    private var runningRequests = [UUID: URLSessionDataTask]()

    private init() {}

    @discardableResult
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) -> UUID? {
        if let cached = cache.object(forKey: url as NSURL) {
            completion(cached)
            return nil
        }

        let uuid = UUID()

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            defer { self?.runningRequests.removeValue(forKey: uuid) }

            guard
                let data = data,
                let image = UIImage(data: data),
                error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            self?.cache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async { completion(image) }
        }

        task.resume()
        runningRequests[uuid] = task
        return uuid
    }

    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}
