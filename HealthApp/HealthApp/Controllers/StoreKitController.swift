//
//  StoreKitController.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/13/24.
//

import Foundation
import StoreKit
import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "group.archetapp.healthapp")!
    
    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}

@MainActor
class StoreManager: NSObject, ObservableObject {
    
    private let productIds = ["pro_monthly_1", "pro_yearly_1"]
    
    @Published
    var products: [Product] = []
    @Published
    var purchasedProductIDs = Set<String>()
    
    private let entitlementManager: EntitlementManager
    private var productsLoaded = false
    private var updates: Task<Void, Never>? = nil
    
    var features = ["Unlimited Food 🍔", "Daily Summaries 📋", "Weekly Summaries 📈", "Dietary Analysis 📊"]
    
    init(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
        super.init()
        self.updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        self.updates?.cancel()
    }
    
    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
            case let .success(.verified(transaction)):
                // Successful purchase
                await transaction.finish()
                await self.updatePurchasedProducts()
            case let .success(.unverified(_, error)):
                print(error)
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                break
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                // ^^^
                break
            @unknown default:
                break
        }
    }
    
    func restorePurchases() {
        _ = Task<Void, Never> {
            do {
                try await AppStore.sync()
            } catch {
                print(error)
            }
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
        
        self.entitlementManager.hasPro = !self.purchasedProductIDs.isEmpty
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
}

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
