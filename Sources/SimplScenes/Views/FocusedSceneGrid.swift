import SwiftUI

/// tvOS-optimized focused grid with proper focus management
struct FocusedSceneGrid: View {
    let scenes: [SceneItem]
    @Binding var selectedScene: SceneItem?
    let isPremium: Bool
    let onPurchase: (() -> Void)?
    
    @FocusState private var focusedId: String?
    
    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 300, maximum: 350))],
            spacing: 20
        ) {
            ForEach(scenes, id: \.id) { scene in
                if isPremium {
                    PremiumSceneCard(scene: scene, onPurchase: onPurchase ?? {})
                        .focused($focusedId, equals: scene.id)
                        .onTapGesture {
                            onPurchase?()
                        }
                } else {
                    SceneCard(
                        scene: scene,
                        isSelected: selectedScene?.id == scene.id,
                        isFocused: focusedId == scene.id
                    )
                    .focused($focusedId, equals: scene.id)
                    .onTapGesture {
                        selectedScene = scene
                    }
                }
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Scene Card with focus visual feedback

struct SceneCard: View {
    let scene: SceneItem
    let isSelected: Bool
    var isFocused: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Thumbnail background with gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.12, green: 0.12, blue: 0.14),
                            Color(red: 0.08, green: 0.08, blue: 0.10)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Scene icon (placeholder for real thumbnails)
            VStack {
                Image(systemName: sceneIcon(for: scene.name))
                    .font(.system(size: 36))
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.7).opacity(0.4))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
            
            // Focus border (tvOS remote focus)
            if isFocused {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.6, green: 0.8, blue: 1.0), lineWidth: 4)
                    .shadow(color: Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.5), radius: 8)
            }
            
            // Selection indicator (when playing)
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.4, green: 0.6, blue: 1.0), lineWidth: 2)
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
        // Scale animation on focus
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
    
    /// Map scene names to SF Symbols for placeholder thumbnails
    private func sceneIcon(for name: String) -> String {
        switch name.lowercased() {
        case let n where n.contains("ocean"): return "water.waves"
        case let n where n.contains("forest") || n.contains("rain"): return "leaf.fill"
        case let n where n.contains("fire"): return "flame.fill"
        case let n where n.contains("northern") || n.contains("aurora"): return "sparkles"
        case let n where n.contains("desert") || n.contains("sunset"): return "sun.horizon.fill"
        case let n where n.contains("mountain") || n.contains("stream"): return "mountain.2.fill"
        case let n where n.contains("city") || n.contains("night"): return "building.2.fill"
        case let n where n.contains("cherry") || n.contains("blossom"): return "leaf.arrow.circlepath"
        case let n where n.contains("thunder") || n.contains("storm"): return "cloud.bolt.fill"
        case let n where n.contains("star"): return "star.fill"
        default: return "play.rectangle.fill"
        }
    }
}

// MARK: - Premium Scene Card

struct PremiumSceneCard: View {
    let scene: SceneItem
    let onPurchase: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.15, green: 0.13, blue: 0.08),
                            Color(red: 0.10, green: 0.08, blue: 0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
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
                
                Spacer()
                
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
