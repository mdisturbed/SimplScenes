import Foundation
import AVFoundation

/// Manages video asset resolution and caching.
///
/// Architecture:
/// - Free scenes: bundled .mp4 files in the app bundle (Resources/)
/// - Premium scenes: streamed from remote CDN (configurable base URL)
/// - Fallback: If no video found, returns nil (UI shows "video not available")
///
/// When CDN is set up, update `remoteBaseURL` via the config plist or environment.
actor VideoAssetManager {
    static let shared = VideoAssetManager()
    
    /// Remote base URL for premium video content.
    /// Format: {baseURL}/{sceneID}.mp4
    /// Set via Info.plist key "VideoBaseURL" or defaults to nil (bundled-only mode).
    private let remoteBaseURL: URL?
    
    /// Cache directory for downloaded premium videos
    private let cacheDirectory: URL
    
    /// Track active downloads to avoid duplicates
    private var activeDownloads: Set<String> = []
    
    init() {
        // Read base URL from Info.plist (runtime configurable, not hardcoded)
        if let urlString = Bundle.main.infoDictionary?["VideoBaseURL"] as? String,
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            self.remoteBaseURL = url
        } else {
            self.remoteBaseURL = nil
        }
        
        // Set up cache directory
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = caches.appendingPathComponent("SimplScenes/Videos", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Resolve a playable video URL for a scene.
    /// Returns a local bundle URL, cached URL, or remote streaming URL — in that priority order.
    func videoURL(for scene: SceneItem) -> URL? {
        // 1. Check app bundle first (free scenes ship bundled)
        if let bundledURL = Bundle.main.url(forResource: scene.id, withExtension: "mp4") {
            return bundledURL
        }
        
        // 2. Check local cache (previously downloaded premium content)
        let cachedFile = cacheDirectory.appendingPathComponent("\(scene.id).mp4")
        if FileManager.default.fileExists(atPath: cachedFile.path) {
            return cachedFile
        }
        
        // 3. Remote streaming URL (premium content, requires CDN)
        if let base = remoteBaseURL {
            return base.appendingPathComponent("\(scene.id).mp4")
        }
        
        return nil
    }
    
    /// Check if a video is available locally (bundled or cached)
    func isAvailableOffline(sceneID: String) -> Bool {
        if Bundle.main.url(forResource: sceneID, withExtension: "mp4") != nil {
            return true
        }
        let cachedFile = cacheDirectory.appendingPathComponent("\(sceneID).mp4")
        return FileManager.default.fileExists(atPath: cachedFile.path)
    }
    
    /// Download a remote video to local cache for offline playback
    func downloadForOffline(scene: SceneItem) async throws {
        guard !activeDownloads.contains(scene.id) else { return }
        guard let base = remoteBaseURL else {
            throw VideoAssetError.noCDNConfigured
        }
        
        activeDownloads.insert(scene.id)
        defer { activeDownloads.remove(scene.id) }
        
        let remoteURL = base.appendingPathComponent("\(scene.id).mp4")
        let destination = cacheDirectory.appendingPathComponent("\(scene.id).mp4")
        
        let (tempURL, response) = try await URLSession.shared.download(from: remoteURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw VideoAssetError.downloadFailed
        }
        
        // Move from temp to cache
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.moveItem(at: tempURL, to: destination)
    }
    
    /// Clear all cached videos
    func clearCache() throws {
        if FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try FileManager.default.removeItem(at: cacheDirectory)
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    /// Get cache size in bytes
    func cacheSize() -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: .skipsHiddenFiles
        ) else { return 0 }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }
        return totalSize
    }
}

enum VideoAssetError: LocalizedError {
    case noCDNConfigured
    case downloadFailed
    case videoNotFound
    
    var errorDescription: String? {
        switch self {
        case .noCDNConfigured: return "Video CDN is not configured"
        case .downloadFailed: return "Failed to download video"
        case .videoNotFound: return "Video file not found"
        }
    }
}
