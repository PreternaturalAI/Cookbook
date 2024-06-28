//
//  Home.StatusGroup.swift
//  HealthApp
//
//  Created by Jared Davidson on 6/27/24.
//

import Foundation
import SwiftUI

extension HomeView {
    struct StatusGroupView: View {
        @ObservedObject var dataController: MealController
        
        var body: some View {
            Group {
                if let status = dataController.mealStatus,
                   let image = dataController.currentImage {
                    MealStatusView(status: status, image: image, dataController: dataController)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(15)
                        .transition(.slide)
                        .animation(.spring, value: dataController.mealStatus)
                }
            }
        }
    }
}
