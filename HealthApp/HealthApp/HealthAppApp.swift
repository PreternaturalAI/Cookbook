//
//  HealthAppApp.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/9/24.
//

import SwiftUI

@main
struct HealthAppApp: App {
    @StateObject
    private var entitlementManager: EntitlementManager

    @StateObject
    private var storeManager: StoreManager

    init() {
        let entitlementManager = EntitlementManager()
        let storeManager = StoreManager(entitlementManager: entitlementManager)
        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._storeManager = StateObject(wrappedValue: storeManager)
    }
    
    var body: some Scene {
        WindowGroup(.dynamic) {
            ContentView()
                .environmentObject(entitlementManager)
                .environmentObject(storeManager)
                .task {
                    await storeManager.updatePurchasedProducts()
                }
        }
    }
}
