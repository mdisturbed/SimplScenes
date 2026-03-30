import SwiftUI

struct ContentView: View {
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedScene: SceneItem?
    @State private var isPresentingStore = false
    @FocusState private var focusedSceneID: String?
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Free scenes section
                        sectionHeader("Free Scenes", subtitle: "10 ambient scenes included")
                        sceneGrid(scenes: SceneCatalog.freeScenes)
                        
                        // Premium scenes section
                        sectionHeader("Premium Packs", subtitle: "Unlock curated collections")
                        premiumPacksRow
                    }
                    .padding(.horizontal, 48)
                    .padding(.bottom, 60)
                }
            }
            
            // Full-screen scene player overlay
            if let scene = selectedScene {
                ScenePlayerOverlay(scene: scene, storeManager: storeManager) {
                    selectedScene = nil
                }
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $isPresentingStore) {
            StoreSheetView(storeManager: storeManager, isPresented: $isPresentingStore)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("SimplScenes")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Text("4K Ambient Scenes")
                    .font(.system(size: 16))
                    .foregroundColor(Color(white: 0.5))
            }
            Spacer()
            Button(action: { isPresentingStore = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "bag")
                    Text("Store")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(white: 0.15))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 30)
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.5))
        }
    }
    
    // MARK: - Scene Grid
    
    private func sceneGrid(scenes: [SceneItem]) -> some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 280, maximum: 350))],
            spacing: 24
        ) {
            ForEach(scenes) { scene in
                SceneCardView(scene: scene, isFocused: focusedSceneID == scene.id)
                    .focused($focusedSceneID, equals: scene.id)
                    .onTapGesture { selectedScene = scene }
            }
        }
    }
    
    // MARK: - Premium Packs Row
    
    private var premiumPacksRow: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 280, maximum: 350))],
            spacing: 24
        ) {
            ForEach(SceneCatalog.packs) { pack in
                PackCardView(
                    pack: pack,
                    storeManager: storeManager,
                    isFocused: focusedSceneID == pack.id
                )
                .focused($focusedSceneID, equals: pack.id)
                .onTapGesture { isPresentingStore = true }
            }
        }
    }
}

// MARK: - Scene Card

struct SceneCardView: View {
    let scene: SceneItem
    let isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background with scene-specific color
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.12), Color(white: 0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Category icon
            Image(systemName: scene.thumbnailSymbol)
                .font(.system(size: 44))
                .foregroundColor(Color(white: 0.2))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
            // Label
            VStack(alignment: .leading, spacing: 6) {
                Spacer()
                Text(scene.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Text("Free")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(4)
            }
            .padding(16)
        }
        .frame(height: 180)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused ? Color(red: 0.5, green: 0.7, blue: 1.0) : Color.clear,
                    lineWidth: isFocused ? 3 : 0
                )
        )
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .shadow(color: isFocused ? Color(red: 0.5, green: 0.7, blue: 1.0).opacity(0.3) : .clear, radius: 12)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Pack Card

struct PackCardView: View {
    let pack: IAPPack
    @ObservedObject var storeManager: StoreManager
    let isFocused: Bool
    
    private var isPurchased: Bool {
        storeManager.isPurchased(pack.productID)
    }
    
    /// Display price from StoreKit — never hardcoded
    private var priceText: String {
        if isPurchased { return "Owned" }
        return storeManager.displayPrice(for: pack.productID) ?? "—"
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.14), Color(white: 0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pack.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Text("\(pack.sceneCount) scenes")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.5))
                    }
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Text(priceText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isPurchased ? .green : .yellow)
                    Spacer()
                    if !isPurchased {
                        Text("Unlock")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.yellow)
                            .cornerRadius(6)
                    }
                }
            }
            .padding(16)
            
            // Premium badge
            Image(systemName: isPurchased ? "checkmark.seal.fill" : "crown.fill")
                .font(.system(size: 18))
                .foregroundColor(isPurchased ? .green : .yellow)
                .padding(12)
        }
        .frame(height: 180)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused ? Color.yellow.opacity(0.7) : Color.clear,
                    lineWidth: isFocused ? 3 : 0
                )
        )
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Scene Player Overlay

struct ScenePlayerOverlay: View {
    let scene: SceneItem
    let storeManager: StoreManager
    let onDismiss: () -> Void
    
    @State private var videoURL: URL?
    @State private var isLoading = true
    @State private var showControls = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isLoading {
                loadingView
            } else if let url = videoURL {
                // Real video playback
                LoopingPlayerView(url: url, onDismiss: onDismiss)
                    .ignoresSafeArea()
                
                if showControls {
                    controlsOverlay
                }
            } else {
                unavailableView
            }
        }
        .task {
            await loadVideo()
        }
        .onAppear {
            // Auto-hide controls after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation { showControls = false }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            Text("Loading \(scene.name)…")
                .font(.system(size: 18))
                .foregroundColor(Color(white: 0.5))
        }
    }
    
    private var unavailableView: some View {
        VStack(spacing: 20) {
            Image(systemName: scene.thumbnailSymbol)
                .font(.system(size: 64))
                .foregroundColor(Color(white: 0.3))
            Text(scene.name)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
            Text("Video coming soon")
                .font(.system(size: 16))
                .foregroundColor(Color(white: 0.5))
            Button(action: onDismiss) {
                Text("Back")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.6))
                    .cornerRadius(8)
            }
        }
    }
    
    private var controlsOverlay: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(scene.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Ambient Scene")
                        .font(.system(size: 14))
                        .foregroundColor(Color(white: 0.5))
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(white: 0.7))
                }
            }
            .padding(30)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.8), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            Spacer()
        }
    }
    
    private func loadVideo() async {
        let url = await VideoAssetManager.shared.videoURL(for: scene)
        await MainActor.run {
            videoURL = url
            isLoading = false
        }
    }
}

// MARK: - Store Sheet

struct StoreSheetView: View {
    @ObservedObject var storeManager: StoreManager
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Scene Packs")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(white: 0.5))
                    }
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 24)
                
                if storeManager.isLoading {
                    Spacer()
                    ProgressView("Loading products…")
                        .tint(.white)
                        .foregroundColor(.white)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(SceneCatalog.packs) { pack in
                                StorePackRow(pack: pack, storeManager: storeManager)
                            }
                            
                            // Restore purchases button
                            Button(action: {
                                Task { await storeManager.restorePurchases() }
                            }) {
                                Text("Restore Purchases")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(white: 0.5))
                                    .padding(.top, 20)
                            }
                        }
                        .padding(.horizontal, 48)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

struct StorePackRow: View {
    let pack: IAPPack
    @ObservedObject var storeManager: StoreManager
    
    private var isPurchased: Bool {
        storeManager.isPurchased(pack.productID)
    }
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(pack.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Text("\(pack.sceneCount) scenes")
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.5))
            }
            Spacer()
            
            if isPurchased {
                Label("Owned", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.green)
            } else {
                Button(action: {
                    Task {
                        guard let product = storeManager.product(for: pack.productID) else { return }
                        _ = try? await storeManager.purchase(product)
                    }
                }) {
                    Text(storeManager.displayPrice(for: pack.productID) ?? "—")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.yellow)
                        .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(Color(white: 0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
}
