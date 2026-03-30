import AVFoundation
import AVKit
import SwiftUI

/// AVPlayer wrapper for tvOS video playback
struct AVPlayerView: UIViewControllerRepresentable {
    let url: URL?
    let sceneName: String
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = true
        controller.allowsPictureInPicturePlayback = false
        
        if let url = url {
            let player = AVPlayer(url: url)
            // Loop the ambient scene
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
            controller.player = player
            player.play()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No dynamic updates needed
    }
}

/// Scene video model with streaming support
struct SceneVideo {
    let id: String
    let sceneName: String
    let videoURL: URL?
    let thumbnailURL: URL?
    let duration: TimeInterval
    let description: String
}

/// Video cache manager for efficient streaming
actor VideoCache {
    static let shared = VideoCache()
    private var urlSession: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 300 // 5 min timeout
        self.urlSession = URLSession(configuration: config)
    }
    
    /// Fetch video metadata (lightweight header check)
    func getVideoInfo(url: URL) async -> (size: Int64?, duration: TimeInterval?) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        do {
            let (_, response) = try await urlSession.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                let size = httpResponse.value(forHTTPHeaderField: "Content-Length").flatMap(Int64.init)
                return (size, nil)
            }
        } catch {
            return (nil, nil)
        }
        
        return (nil, nil)
    }
}
