import SwiftUI

struct ContentView: View {
    @State private var selectedScene: SceneItem?
    @State private var isPresentingStore = false
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SimplScenes")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        Text("4K Ambient Scenes")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: { isPresentingStore = true }) {
                        Image(systemName: "bag")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .cornerRadius(8)
                    }
                    .focusable()
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 30)
                
                // Scene Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                        ForEach(SceneManager.freeScenes, id: \.id) { scene in
                            SceneCard(scene: scene, isSelected: selectedScene?.id == scene.id)
                                .onTapGesture {
                                    selectedScene = scene
                                }
                                .focusable()
                        }
                        
                        ForEach(SceneManager.premiumScenes, id: \.id) { scene in
                            PremiumSceneCard(scene: scene, onPurchase: {
                                isPresentingStore = true
                            })
                            .focusable()
                        }
                    }
                    .padding(40)
                }
            }
            
            // Scene Player (overlay)
            if let selected = selectedScene {
                ScenePlayerView(scene: selected, isPresented: Binding(
                    get: { selectedScene != nil },
                    set: { if !$0 { selectedScene = nil } }
                ))
            }
        }
        .sheet(isPresented: $isPresentingStore) {
            StoreView(isPresented: $isPresentingStore)
        }
    }
}

// MARK: - Scene Card Views

struct SceneCard: View {
    let scene: SceneItem
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Thumbnail
            Rectangle()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
            
            // Selection indicator
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.4, green: 0.6, blue: 1.0), lineWidth: 3)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text(scene.name)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                Text("Free")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.1, green: 0.3, blue: 0.1))
                    .cornerRadius(4)
            }
            .padding(20)
        }
        .frame(height: 180)
        .cornerRadius(12)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
}

struct PremiumSceneCard: View {
    let scene: SceneItem
    let onPurchase: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(scene.name)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                        Text(scene.price)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.yellow)
                    }
                    Spacer()
                }
                
                Button(action: onPurchase) {
                    Text("Unlock")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.yellow)
                        .cornerRadius(6)
                }
                .focusable()
            }
            .padding(20)
            
            // Premium badge
            Image(systemName: "crown.fill")
                .font(.system(size: 16))
                .foregroundColor(.yellow)
                .padding(12)
        }
        .frame(height: 180)
        .cornerRadius(12)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
}

// MARK: - Scene Player

struct ScenePlayerView: View {
    let scene: SceneItem
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .focusable()
                    Spacer()
                }
                .padding(20)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Text(scene.name)
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    Text("Video player placeholder")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Store View

struct StoreView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Scene Packs")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    .focusable()
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(SceneManager.iapPacks, id: \.id) { pack in
                            PackCard(pack: pack)
                                .focusable()
                        }
                    }
                    .padding(40)
                }
            }
        }
    }
}

struct PackCard: View {
    let pack: IAPPack
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(pack.name)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                Text("\(pack.sceneCount) scenes")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {}) {
                Text(pack.price)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.yellow)
                    .cornerRadius(6)
            }
            .focusable()
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .cornerRadius(10)
    }
}

// MARK: - Data Models

struct SceneItem: Identifiable {
    let id: String
    let name: String
    let price: String
    let videoUrl: String?
}

struct IAPPack: Identifiable {
    let id: String
    let name: String
    let sceneCount: Int
    let price: String
    let productId: String
}

// MARK: - Scene Manager

struct SceneManager {
    static let freeScenes: [SceneItem] = [
        SceneItem(id: "free-1", name: "Ocean Waves", price: "Free", videoUrl: nil),
        SceneItem(id: "free-2", name: "Forest Rain", price: "Free", videoUrl: nil),
        SceneItem(id: "free-3", name: "Fireplace", price: "Free", videoUrl: nil),
        SceneItem(id: "free-4", name: "Northern Lights", price: "Free", videoUrl: nil),
        SceneItem(id: "free-5", name: "Desert Sunset", price: "Free", videoUrl: nil),
        SceneItem(id: "free-6", name: "Mountain Stream", price: "Free", videoUrl: nil),
        SceneItem(id: "free-7", name: "City Night", price: "Free", videoUrl: nil),
        SceneItem(id: "free-8", name: "Cherry Blossoms", price: "Free", videoUrl: nil),
        SceneItem(id: "free-9", name: "Thunderstorm", price: "Free", videoUrl: nil),
        SceneItem(id: "free-10", name: "Starfield", price: "Free", videoUrl: nil)
    ]
    
    static let premiumScenes: [SceneItem] = [
        SceneItem(id: "prem-1", name: "Arctic Aurora", price: "$1.99", videoUrl: nil),
        SceneItem(id: "prem-2", name: "Tropical Paradise", price: "$1.99", videoUrl: nil),
        SceneItem(id: "prem-3", name: "Space Nebula", price: "$1.99", videoUrl: nil),
        SceneItem(id: "prem-4", name: "Volcano Eruption", price: "$2.99", videoUrl: nil),
        SceneItem(id: "prem-5", name: "Ocean Shipwreck", price: "$2.99", videoUrl: nil)
    ]
    
    static let iapPacks: [IAPPack] = [
        IAPPack(id: "pack-arctic", name: "Arctic Collection", sceneCount: 3, price: "$1.99", productId: "com.sudobuiltapps.simplscenes.arctic"),
        IAPPack(id: "pack-tropical", name: "Tropical Collection", sceneCount: 3, price: "$1.99", productId: "com.sudobuiltapps.simplscenes.tropical"),
        IAPPack(id: "pack-cosmic", name: "Cosmic Collection", sceneCount: 3, price: "$2.99", productId: "com.sudobuiltapps.simplscenes.cosmic"),
        IAPPack(id: "pack-all", name: "All Scenes Unlock", sceneCount: 15, price: "$4.99", productId: "com.sudobuiltapps.simplscenes.all")
    ]
}

#Preview {
    ContentView()
}
