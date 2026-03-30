import Foundation

/// A single ambient scene
struct SceneItem: Identifiable, Equatable {
    let id: String
    let name: String
    let category: SceneCategory
    let isPremium: Bool
    let packProductID: String?
    
    /// Thumbnail SF Symbol for the scene category
    var thumbnailSymbol: String {
        switch category {
        case .ocean: return "water.waves"
        case .forest: return "tree.fill"
        case .fire: return "flame.fill"
        case .sky: return "sparkles"
        case .desert: return "sun.max.fill"
        case .mountain: return "mountain.2.fill"
        case .city: return "building.2.fill"
        case .nature: return "leaf.fill"
        case .weather: return "cloud.bolt.fill"
        case .space: return "star.fill"
        case .arctic: return "snowflake"
        case .tropical: return "sun.haze.fill"
        case .cosmic: return "moon.stars.fill"
        }
    }
    
    static func == (lhs: SceneItem, rhs: SceneItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// Scene categories for visual organization
enum SceneCategory: String, CaseIterable {
    case ocean, forest, fire, sky, desert, mountain, city, nature, weather, space
    case arctic, tropical, cosmic
}

/// An IAP pack containing multiple scenes
struct IAPPack: Identifiable {
    let id: String
    let name: String
    let productID: String
    let sceneIDs: [String]
    
    var sceneCount: Int { sceneIDs.count }
}
