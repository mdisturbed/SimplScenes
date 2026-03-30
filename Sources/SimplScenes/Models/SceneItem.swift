import Foundation

/// Represents a single ambient scene
struct SceneItem: Identifiable {
    let id: String
    let name: String
    let price: String
    
    /// Computed video URL using VideoAssetManager
    var videoUrl: URL? {
        VideoAssetManager.videoURL(forSceneID: id)
    }
    
    /// Whether this is a free or premium scene
    var isPremium: Bool {
        id.hasPrefix("prem-")
    }
}

/// Represents an IAP product pack
struct IAPPack: Identifiable {
    let id: String
    let name: String
    let sceneCount: Int
    let price: String
    let productId: String
}
