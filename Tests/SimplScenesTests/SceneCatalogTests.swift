import XCTest
@testable import SimplScenes

final class SceneCatalogTests: XCTestCase {
    
    // MARK: - Scene Counts
    
    func testFreeScenesCount() {
        XCTAssertEqual(SceneCatalog.freeScenes.count, 10, "Should have exactly 10 free scenes")
    }
    
    func testArcticScenesCount() {
        XCTAssertEqual(SceneCatalog.arcticScenes.count, 3, "Arctic pack should have 3 scenes")
    }
    
    func testTropicalScenesCount() {
        XCTAssertEqual(SceneCatalog.tropicalScenes.count, 3, "Tropical pack should have 3 scenes")
    }
    
    func testCosmicScenesCount() {
        XCTAssertEqual(SceneCatalog.cosmicScenes.count, 3, "Cosmic pack should have 3 scenes")
    }
    
    func testAllPremiumScenesCount() {
        XCTAssertEqual(SceneCatalog.allPremiumScenes.count, 9, "Should have 9 premium scenes total")
    }
    
    func testTotalScenesCount() {
        XCTAssertEqual(SceneCatalog.allScenes.count, 19, "Should have 19 total scenes (10 free + 9 premium)")
    }
    
    // MARK: - Scene Properties
    
    func testFreeScenesAreNotPremium() {
        for scene in SceneCatalog.freeScenes {
            XCTAssertFalse(scene.isPremium, "\(scene.name) should not be premium")
            XCTAssertNil(scene.packProductID, "\(scene.name) should have no pack product ID")
        }
    }
    
    func testPremiumScenesHavePackIDs() {
        for scene in SceneCatalog.allPremiumScenes {
            XCTAssertTrue(scene.isPremium, "\(scene.name) should be premium")
            XCTAssertNotNil(scene.packProductID, "\(scene.name) should have a pack product ID")
        }
    }
    
    func testUniqueSceneIDs() {
        let allIDs = SceneCatalog.allScenes.map(\.id)
        let uniqueIDs = Set(allIDs)
        XCTAssertEqual(allIDs.count, uniqueIDs.count, "All scene IDs must be unique")
    }
    
    func testUniqueSceneNames() {
        let allNames = SceneCatalog.allScenes.map(\.name)
        let uniqueNames = Set(allNames)
        XCTAssertEqual(allNames.count, uniqueNames.count, "All scene names must be unique")
    }
    
    // MARK: - Scene Lookup
    
    func testSceneLookupByID() {
        let scene = SceneCatalog.scene(byID: "free-ocean-waves")
        XCTAssertNotNil(scene)
        XCTAssertEqual(scene?.name, "Ocean Waves")
    }
    
    func testSceneLookupReturnsNilForInvalidID() {
        let scene = SceneCatalog.scene(byID: "nonexistent-scene")
        XCTAssertNil(scene)
    }
    
    func testScenesForPack() {
        let arcticPack = SceneCatalog.packs.first { $0.id == "pack-arctic" }!
        let scenes = SceneCatalog.scenes(forPack: arcticPack)
        XCTAssertEqual(scenes.count, 3)
        XCTAssertTrue(scenes.allSatisfy { $0.category == .arctic })
    }
    
    // MARK: - Packs
    
    func testPackCount() {
        XCTAssertEqual(SceneCatalog.packs.count, 4, "Should have 4 packs (arctic, tropical, cosmic, all)")
    }
    
    func testPackProductIDs() {
        let packIDs = SceneCatalog.packs.map(\.productID)
        XCTAssertTrue(packIDs.contains(ProductIDs.arctic))
        XCTAssertTrue(packIDs.contains(ProductIDs.tropical))
        XCTAssertTrue(packIDs.contains(ProductIDs.cosmic))
        XCTAssertTrue(packIDs.contains(ProductIDs.allScenes))
    }
    
    func testAllScenesPackContainsAllPremium() {
        let allPack = SceneCatalog.packs.first { $0.productID == ProductIDs.allScenes }!
        XCTAssertEqual(allPack.sceneIDs.count, SceneCatalog.allPremiumScenes.count)
    }
    
    // MARK: - Product IDs
    
    func testProductIDsArray() {
        XCTAssertEqual(ProductIDs.all.count, 4, "Should have 4 product IDs")
    }
    
    func testProductIDFormat() {
        for id in ProductIDs.all {
            XCTAssertTrue(id.hasPrefix("com.sudobuiltapps.simplscenes."), "Product ID should use correct bundle prefix: \(id)")
        }
    }
    
    // MARK: - Scene Categories
    
    func testThumbnailSymbolsExist() {
        for scene in SceneCatalog.allScenes {
            XCTAssertFalse(scene.thumbnailSymbol.isEmpty, "\(scene.name) should have a thumbnail symbol")
        }
    }
}
