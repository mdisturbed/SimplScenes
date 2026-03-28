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
                        .focusable()
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
                    .focusable()
                }
            }
        }
        .padding(40)
    }
}

/// Updated SceneCard with focus visual feedback
struct SceneCard: View {
    let scene: SceneItem
    let isSelected: Bool
    let isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Thumbnail background
            Rectangle()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
            
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
        // Add scale animation on focus
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
