import StoreKit
import Foundation

/// StoreKit2 IAP Manager for SimplScenes.
/// Prices are always fetched from StoreKit at runtime — never hardcoded.
@MainActor
final class StoreManager: ObservableObject {
    @Published var purchasedProductIDs = Set<String>()
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var lastError: Error?
    
    static let shared = StoreManager()
    
    private var updateListenerTask: Task<Void, Never>?
    
    init() {
        setupTransactionListener()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public API
    
    /// Purchase a product. Returns the verified transaction on success.
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if let transaction = try? checkVerified(verification) {
                await transaction.finish()
                await updatePurchasedProducts()
                return transaction
            }
            return nil
        case .pending:
            return nil
        case .userCancelled:
            return nil
        @unknown default:
            return nil
        }
    }
    
    /// Check if a product ID has been purchased
    func isPurchased(_ productID: String) -> Bool {
        // "All scenes" unlock also grants access to individual packs
        if purchasedProductIDs.contains(ProductIDs.allScenes) {
            return true
        }
        return purchasedProductIDs.contains(productID)
    }
    
    /// Check if a scene is unlocked (free scenes are always unlocked)
    func isSceneUnlocked(_ scene: SceneItem) -> Bool {
        if !scene.isPremium { return true }
        guard let packID = scene.packProductID else { return false }
        return isPurchased(packID)
    }
    
    /// Get the StoreKit Product for a given product ID
    func product(for productID: String) -> Product? {
        products.first { $0.id == productID }
    }
    
    /// Get display price string from StoreKit (never hardcoded)
    func displayPrice(for productID: String) -> String? {
        product(for: productID)?.displayPrice
    }
    
    /// Restore purchases
    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    // MARK: - Private
    
    private func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await Product.products(for: ProductIDs.all)
                .sorted { $0.price < $1.price }
        } catch {
            lastError = error
        }
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedIDs.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchasedIDs
    }
    
    private func setupTransactionListener() {
        updateListenerTask = Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.updatePurchasedProducts()
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T? {
        switch result {
        case .unverified:
            return nil
        case .verified(let safe):
            return safe
        }
    }
}
