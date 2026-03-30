import SwiftUI
import AVFoundation
import AVKit
import StoreKit

struct ContentView: View {
    @StateObject private var storeManager = StoreManager.shared
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
                
                // Scene Grid — uses FocusedSceneGrid for proper tvOS focus management
                ScrollView {
                    VStack(spacing: 30) {
                        // Free scenes section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Free Scenes")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                            
                            FocusedSceneGrid(
                                scenes: SceneManager.freeScenes,
                                selectedScene: $selectedScene,
                                isPremium: false,
                                onPurchase: nil
                            )
                        }
                        
                        // Premium scenes section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Premium Scenes")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 40)
                            
                            FocusedSceneGrid(
                                scenes: SceneManager.premiumScenes,
                                selectedScene: $selectedScene,
                                isPremium: true,
                                onPurchase: { isPresentingStore = true }
                            )
                        }
                    }
                }
            }
            
            // Scene Player (fullscreen overlay)
            if let selected = selectedScene {
                ScenePlayerView(scene: selected, isPresented: Binding(
                    get: { selectedScene != nil },
                    set: { if !$0 { selectedScene = nil } }
                ))
            }
        }
        .sheet(isPresented: $isPresentingStore) {
            StoreView(isPresented: $isPresentingStore, storeManager: storeManager)
        }
    }
}

// MARK: - Scene Player

struct ScenePlayerView: View {
    let scene: SceneItem
    @Binding var isPresented: Bool
    @State private var videoURL: URL?
    @State private var isLoading = true
    @State private var showControls = true
    @State private var controlsTimer: Timer?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Loading \(scene.name)...")
                        .font(.system(size: 18, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                }
            } else if let url = videoURL {
                // Real AVPlayer for video playback
                AVPlayerView(url: url, sceneName: scene.name) {
                    isPresented = false
                }
                .ignoresSafeArea()
                
                // Controls overlay
                if showControls {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(scene.name)
                                    .font(.system(size: 28, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                Text("Ambient Scene")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: { isPresented = false }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                            .focusable()
                        }
                        .padding(30)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.8),
                                    Color.black.opacity(0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        Spacer()
                    }
                    .onAppear {
                        scheduleControlsHide()
                    }
                }
            } else {
                // No video available — show placeholder
                VStack(spacing: 20) {
                    Image(systemName: "play.rectangle")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    Text(scene.name)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    Text("Video content coming soon")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                    Button(action: { isPresented = false }) {
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(.black)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .focusable()
                }
            }
        }
        .onAppear {
            loadVideo()
        }
        .onDisappear {
            controlsTimer?.invalidate()
        }
    }
    
    private func loadVideo() {
        Task {
            let url = scene.videoUrl
            await MainActor.run {
                self.videoURL = url
                self.isLoading = false
            }
        }
    }
    
    private func scheduleControlsHide() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            withAnimation {
                showControls = false
            }
        }
    }
}

// MARK: - Store View

struct StoreView: View {
    @Binding var isPresented: Bool
    @ObservedObject var storeManager: StoreManager
    
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
                
                if storeManager.isLoading {
                    Spacer()
                    ProgressView("Loading products...")
                        .tint(.white)
                        .foregroundColor(.gray)
                    Spacer()
                } else if storeManager.products.isEmpty {
                    // Fallback to static pack data when StoreKit products aren't available
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(SceneManager.iapPacks, id: \.id) { pack in
                                PackCard(
                                    pack: pack,
                                    isPurchased: storeManager.isPurchased(pack.productId),
                                    onPurchase: {
                                        // Products not loaded — show info
                                    }
                                )
                                .focusable()
                            }
                        }
                        .padding(40)
                    }
                } else {
                    // Real StoreKit products available
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(storeManager.products, id: \.id) { product in
                                ProductCard(
                                    product: product,
                                    isPurchased: storeManager.isPurchased(product.id),
                                    onPurchase: {
                                        Task {
                                            _ = try? await storeManager.purchase(product)
                                        }
                                    }
                                )
                                .focusable()
                            }
                        }
                        .padding(40)
                    }
                }
                
                if let error = storeManager.lastError {
                    Text("Error: \(error.localizedDescription)")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 10)
                }
            }
        }
    }
}

// MARK: - Product Card (StoreKit Product)

struct ProductCard: View {
    let product: Product
    let isPurchased: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(product.displayName)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                Text(product.description)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.gray)
            }
            Spacer()
            if isPurchased {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            } else {
                Button(action: onPurchase) {
                    Text(product.displayPrice)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.yellow)
                        .cornerRadius(6)
                }
                .focusable()
            }
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .cornerRadius(10)
    }
}

// MARK: - Pack Card (Static fallback)

struct PackCard: View {
    let pack: IAPPack
    let isPurchased: Bool
    let onPurchase: () -> Void
    
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
            if isPurchased {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            } else {
                Button(action: onPurchase) {
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
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .cornerRadius(10)
    }
}

// MARK: - Scene Manager

struct SceneManager {
    static let freeScenes: [SceneItem] = [
        SceneItem(id: "free-1", name: "Ocean Waves", price: "Free"),
        SceneItem(id: "free-2", name: "Forest Rain", price: "Free"),
        SceneItem(id: "free-3", name: "Fireplace", price: "Free"),
        SceneItem(id: "free-4", name: "Northern Lights", price: "Free"),
        SceneItem(id: "free-5", name: "Desert Sunset", price: "Free"),
        SceneItem(id: "free-6", name: "Mountain Stream", price: "Free"),
        SceneItem(id: "free-7", name: "City Night", price: "Free"),
        SceneItem(id: "free-8", name: "Cherry Blossoms", price: "Free"),
        SceneItem(id: "free-9", name: "Thunderstorm", price: "Free"),
        SceneItem(id: "free-10", name: "Starfield", price: "Free")
    ]
    
    static let premiumScenes: [SceneItem] = [
        SceneItem(id: "prem-1", name: "Arctic Aurora", price: "$1.99"),
        SceneItem(id: "prem-2", name: "Tropical Paradise", price: "$1.99"),
        SceneItem(id: "prem-3", name: "Space Nebula", price: "$1.99"),
        SceneItem(id: "prem-4", name: "Volcano Eruption", price: "$2.99"),
        SceneItem(id: "prem-5", name: "Ocean Shipwreck", price: "$2.99")
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
