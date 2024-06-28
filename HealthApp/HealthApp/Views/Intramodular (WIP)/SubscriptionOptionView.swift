//
//  SubscriptionOptionView.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/14/24.
//

import Foundation
import SwiftUI
import StoreKit

// TODO: This should be extracted as part of a `SubscriptionsUI` package

struct SubscriptionOptionView: View {
    var product: Product
    var isYearly: Bool
    
    var purchase: (_ product: Product) -> ()

    var body: some View {
        Button {
            self.purchase(product)
        } label: {
            HStack {
                Text(product.displayName)
                    .foregroundColor(.white)
                    .padding()
                Spacer()
                if isYearly {
                    Text("Save 15%")
                        .bold()
                        .foregroundColor(.white)
                        .padding([.leading, .trailing], 8)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(5)
                }
                Text(product.displayPrice)
                    .foregroundColor(.white)
                    .padding(.trailing, 10)
            }
            .background(Color.blue)
            .cornerRadius(15)
        }
    }
}
