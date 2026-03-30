import Foundation

/// Central catalog of all scenes and packs.
/// Scene metadata is defined here; video URLs are resolved at runtime by VideoAssetManager.
enum SceneCatalog {
    
    // MARK: - Free Scenes (10 bundled)
    
    static let freeScenes: [SceneItem] = [
        SceneItem(id: "free-ocean-waves", name: "Ocean Waves", category: .ocean, isPremium: false, packProductID: nil),
        SceneItem(id: "free-forest-rain", name: "Forest Rain", category: .forest, isPremium: false, packProductID: nil),
        SceneItem(id: "free-fireplace", name: "Fireplace", category: .fire, isPremium: false, packProductID: nil),
        SceneItem(id: "free-northern-lights", name: "Northern Lights", category: .sky, isPremium: false, packProductID: nil),
        SceneItem(id: "free-desert-sunset", name: "Desert Sunset", category: .desert, isPremium: false, packProductID: nil),
        SceneItem(id: "free-mountain-stream", name: "Mountain Stream", category: .mountain, isPremium: false, packProductID: nil),
        SceneItem(id: "free-city-night", name: "City Night", category: .city, isPremium: false, packProductID: nil),
        SceneItem(id: "free-cherry-blossoms", name: "Cherry Blossoms", category: .nature, isPremium: false, packProductID: nil),
        SceneItem(id: "free-thunderstorm", name: "Thunderstorm", category: .weather, isPremium: false, packProductID: nil),
        SceneItem(id: "free-starfield", name: "Starfield", category: .space, isPremium: false, packProductID: nil),
    ]
    
    // MARK: - Premium Scenes (organized by pack)
    
    static let arcticScenes: [SceneItem] = [
        SceneItem(id: "prem-arctic-aurora", name: "Arctic Aurora", category: .arctic, isPremium: true, packProductID: ProductIDs.arctic),
        SceneItem(id: "prem-forest-frost", name: "Forest Frost", category: .arctic, isPremium: true, packProductID: ProductIDs.arctic),
        SceneItem(id: "prem-polar-night", name: "Polar Night", category: .arctic, isPremium: true, packProductID: ProductIDs.arctic),
    ]
    
    static let tropicalScenes: [SceneItem] = [
        SceneItem(id: "prem-tropical-paradise", name: "Tropical Paradise", category: .tropical, isPremium: true, packProductID: ProductIDs.tropical),
        SceneItem(id: "prem-jungle-rain", name: "Jungle Rain", category: .tropical, isPremium: true, packProductID: ProductIDs.tropical),
        SceneItem(id: "prem-beach-sunset", name: "Beach Sunset", category: .tropical, isPremium: true, packProductID: ProductIDs.tropical),
    ]
    
    static let cosmicScenes: [SceneItem] = [
        SceneItem(id: "prem-space-nebula", name: "Space Nebula", category: .cosmic, isPremium: true, packProductID: ProductIDs.cosmic),
        SceneItem(id: "prem-galaxy-swirl", name: "Galaxy Swirl", category: .cosmic, isPremium: true, packProductID: ProductIDs.cosmic),
        SceneItem(id: "prem-black-hole", name: "Black Hole", category: .cosmic, isPremium: true, packProductID: ProductIDs.cosmic),
    ]
    
    static var allPremiumScenes: [SceneItem] {
        arcticScenes + tropicalScenes + cosmicScenes
    }
    
    static var allScenes: [SceneItem] {
        freeScenes + allPremiumScenes
    }
    
    // MARK: - IAP Packs
    
    static let packs: [IAPPack] = [
        IAPPack(id: "pack-arctic", name: "Arctic Collection", productID: ProductIDs.arctic, sceneIDs: arcticScenes.map(\.id)),
        IAPPack(id: "pack-tropical", name: "Tropical Collection", productID: ProductIDs.tropical, sceneIDs: tropicalScenes.map(\.id)),
        IAPPack(id: "pack-cosmic", name: "Cosmic Collection", productID: ProductIDs.cosmic, sceneIDs: cosmicScenes.map(\.id)),
        IAPPack(id: "pack-all", name: "All Scenes Unlock", productID: ProductIDs.allScenes, sceneIDs: allPremiumScenes.map(\.id)),
    ]
    
    /// Look up a scene by ID
    static func scene(byID id: String) -> SceneItem? {
        allScenes.first { $0.id == id }
    }
    
    /// Get scenes belonging to a pack
    static func scenes(forPack pack: IAPPack) -> [SceneItem] {
        pack.sceneIDs.compactMap { scene(byID: $0) }
    }
}

/// Product ID constants — single source of truth
enum ProductIDs {
    static let arctic = "com.sudobuiltapps.simplscenes.arctic"
    static let tropical = "com.sudobuiltapps.simplscenes.tropical"
    static let cosmic = "com.sudobuiltapps.simplscenes.cosmic"
    static let allScenes = "com.sudobuiltapps.simplscenes.all"
    
    static var all: [String] {
        [arctic, tropical, cosmic, allScenes]
    }
}
