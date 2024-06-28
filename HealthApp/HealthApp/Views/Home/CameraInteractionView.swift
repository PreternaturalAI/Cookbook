//
//  CameraInteractionsVierw.swift
//  HealthApp
//
//  Created by Jared Davidson on 6/27/24.
//

import Foundation
import SwiftUI

struct CameraInteractionView: View {
    @Binding var cameraPresented: Bool
    @Binding var offset: CGFloat
    var coreDataController: CoreDataController
    var dataController: MealController
    
    var body: some View {
        ZStack {
            Color.black
            CameraView(showing: $cameraPresented) { image in
                processCapturedImage(image)
            }
        }
    }
    
    private func processCapturedImage(_ image: UIImage) {
        cameraPresented = false
        Task {
            await handleMealImage(image)
        }
    }
    
    private func handleMealImage(_ image: UIImage) async {
        Task {
            if let _ = self.coreDataController.data.firstIndex(where: {$0.date.isSameDay(as: Date())}) {
                guard let meal = try await dataController.createMeal(image: image) else {
                    return
                }
                self.coreDataController.saveMeal(meal: meal)
            } else {
                self.coreDataController.saveDay(day: Day(date: Date(), shortSummary: "", longSummary: "", totalSummary: "", meals: []))
                guard let meal = try await dataController.createMeal(image: image) else {
                    return
                }
                self.coreDataController.saveMeal(meal: meal)
            }
        }
    }
}

// Preview provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

