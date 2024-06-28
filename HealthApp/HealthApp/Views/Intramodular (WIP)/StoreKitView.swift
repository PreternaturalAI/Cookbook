//
//  StoreKitView.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/13/24.
//

import Foundation
import SwiftUI
import StoreKit

// TODO: This should be extracted as part of a `SubscriptionsUI` package

struct StoreKitView: View {
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var storeManager: StoreManager

    var body: some View {
        ZStack {
            backgroundGradient
            contentStack
        }
        .task {
            Task {
                try await storeManager.loadProducts()
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.2), Color.blue.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }

    private var contentStack: some View {
        VStack(alignment: .leading) {
            headerSection
            featureList
            Spacer()
            subscriptionSection
            footerSection
        }
        .padding()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HealthApp PRO")
                .font(.largeTitle)
                .bold()
            Text("Get the best insights to your health with PRO.")
                .font(.subheadline)
        }
        .padding()
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(storeManager.features, id: \.self) { feature in
                FeatureView(feature: feature)
            }
        }
        .padding()
    }

    private var subscriptionSection: some View {
        VStack {
            if entitlementManager.hasPro {
                subscribedView
            } else {
                ForEach(storeManager.products, id: \.id) { product in
                    SubscriptionOptionView(product: product, isYearly: product.id.contains("year")) {
                        product in
                        Task {
                            try await storeManager.purchase(product)
                        }
                    }
                }
            }
        }
    }

    private var footerSection: some View {
        HStack {
            Link("Privacy and Terms", destination: URL(string: "https://example.com/privacy")!)
            Spacer()
            Button("Restore", action: {
                Task {
                    storeManager.restorePurchases()
                }
            })
        }
        .padding()
    }

    private var subscribedView: some View {
        HStack {
            Spacer()
            Text("Subscribed")
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
        .background(Color.black)
        .cornerRadius(15)
    }
}
