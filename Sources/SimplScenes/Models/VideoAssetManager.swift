import Foundation

/// Manages video asset URLs and configuration for SimplScenes
struct VideoAssetManager {
    // MARK: - Configuration
    static let videoBaseURL = "https://cdn.sudobuiltapps.com/simplscenes/videos"
    static let fallbackBaseURL = "file:///Library/Caches/SimplScenes/videos"
    
    // MARK: - Video Mapping (Free Scenes)
    static let freeSceneVideos: [String: String] = [
        "free-1": "ocean-waves.mp4",
        "free-2": "forest-rain.mp4",
        "free-3": "fireplace.mp4",
        "free-4": "northern-lights.mp4",
        "free-5": "desert-sunset.mp4",
        "free-6": "mountain-stream.mp4",
        "free-7": "city-night.mp4",
        "free-8": "cherry-blossoms.mp4",
        "free-9": "thunderstorm.mp4",
        "free-10": "starfield.mp4"
    ]
    
    // MARK: - Video Mapping (Premium Scenes)
    static let premiumSceneVideos: [String: String] = [
        "prem-1": "arctic-aurora.mp4",
        "prem-2": "tropical-paradise.mp4",
        "prem-3": "space-nebula.mp4",
        "prem-4": "volcano-eruption.mp4",
        "prem-5": "ocean-shipwreck.mp4"
    ]
    
    // MARK: - URL Resolution
    /// Returns the video URL for a given scene ID, attempting CDN first, then fallback, then local cache
    static func videoURL(forSceneID sceneID: String) -> URL? {
        guard let filename = freeSceneVideos[sceneID] ?? premiumSceneVideos[sceneID] else {
            return nil
        }
        
        // Try CDN first
        if let cdnURL = URL(string: "\(videoBaseURL)/\(filename)"),
           isURLAvailable(cdnURL) {
            return cdnURL
        }
        
        // Try fallback cache
        if let fallbackURL = URL(string: "\(fallbackBaseURL)/\(filename)"),
           isURLAvailable(fallbackURL) {
            return fallbackURL
        }
        
        // Return CDN URL anyway (app will handle unavailable gracefully)
        return URL(string: "\(videoBaseURL)/\(filename)")
    }
    
    /// Check if a URL is reachable (synchronous, used for local caching only)
    private static func isURLAvailable(_ url: URL) -> Bool {
        guard url.isFileURL else {
            // Don't block on network checks in development
            return false
        }
        
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// Preload video manifest and cache locally for offline playback
    static func preloadVideoCache() {
        // Implementation for background caching of video manifest
        // Can use URLSession background tasks
    }
    
    /// Returns all video filenames for asset bundling/deployment
    static var allVideoFilenames: [String] {
        Array(freeSceneVideos.values) + Array(premiumSceneVideos.values)
    }
}
