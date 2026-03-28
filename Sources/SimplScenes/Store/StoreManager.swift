import StoreKit
import Foundation

/// StoreKit2 IAP Manager for SimplScenes
@MainActor
final class StoreManager: NSObject, ObservableObject {
    @Published var purchasedProductIDs = Set<String>()
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var lastError: Error?
    
    static let shared = StoreManager()
    
    private let productIDs = [
        "com.sudobuiltapps.simplscenes.arctic",      // Arctic Collection - $1.99
        "com.sudobuiltapps.simplscenes.tropical",    // Tropical Collection - $1.99
        "com.sudobuiltapps.simplscenes.cosmic",      // Cosmic Collection - $2.99
        "com.sudobuiltapps.simplscenes.all"          // All Scenes - $4.99
    ]
    
    private var updateListenerTask: Task<Void, Never>? = nil
    
    override init() {
        super.init()
        setupTransactionListener()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    /// Load available products from App Store
    @MainActor
    private func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await Product.products(for: productIDs).sorted { $0.price < $1.price }
        } catch {
            lastError = error
            print("Failed to load products: \(error)")
        }
    }
    
    /// Update purchased products
    @MainActor
    private func updatePurchasedProducts() async {
        var purchasedIDs = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedIDs.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchasedIDs
    }
    
    /// Purchase a product
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if let transaction = try checkVerified(verification) {
                await updatePurchasedProducts()
                return transaction
            }
        case .pending:
            print("Purchase pending for \(product.id)")
        case .userCancelled:
            print("User cancelled purchase")
        @unknown default:
            break
        }
        
        return nil
    }
    
    /// Check if product is purchased
    func isPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
    
    /// Setup transaction listener
    private func setupTransactionListener() {
        updateListenerTask = Task(priority: .background) {
            for await _ in Transaction.updates {
                await updatePurchasedProducts()
            }
        }
    }
    
    /// Verify transaction signature
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T? {
        switch result {
        case .unverified:
            print("Warning: unverified transaction")
            return nil
        case .verified(let safe):
            return safe
        }
    }
}

/// Extension for convenience
extension StoreManager {
    var arcticPack: Product? {
        products.first { $0.id == "com.sudobuiltapps.simplscenes.arctic" }
    }
    
    var tropicalPack: Product? {
        products.first { $0.id == "com.sudobuiltapps.simplscenes.tropical" }
    }
    
    var cosmicPack: Product? {
        products.first { $0.id == "com.sudobuiltapps.simplscenes.cosmic" }
    }
    
    var allScenesUnlock: Product? {
        products.first { $0.id == "com.sudobuiltapps.simplscenes.all" }
    }
}
