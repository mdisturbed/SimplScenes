import AVFoundation
import AVKit
import SwiftUI

/// AVPlayer wrapper for tvOS ambient video playback with looping support.
struct LoopingPlayerView: UIViewControllerRepresentable {
    let url: URL
    let onDismiss: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false // Ambient mode — no controls
        controller.allowsPictureInPicturePlayback = false
        
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        player.isMuted = false
        controller.player = player
        
        // Set up looping via notification
        context.coordinator.observeLoop(player: player, item: playerItem)
        
        player.play()
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        uiViewController.player?.pause()
        uiViewController.player = nil
        coordinator.cleanup()
    }
    
    class Coordinator {
        let onDismiss: () -> Void
        private var loopObserver: NSObjectProtocol?
        
        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
        
        func observeLoop(player: AVPlayer, item: AVPlayerItem) {
            loopObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }
        
        func cleanup() {
            if let observer = loopObserver {
                NotificationCenter.default.removeObserver(observer)
                loopObserver = nil
            }
        }
    }
}
