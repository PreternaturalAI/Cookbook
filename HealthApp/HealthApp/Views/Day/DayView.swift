//
//  DayView.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/11/24.
//

import Foundation
import SwiftUI

struct DayView: View {
    var dailyData: Day // Ensure that Day is your data model

    var body: some View {
        ScrollView {
            VStack(spacing: 10) { // Added spacing between elements for better visual separation
                Text(dailyData.longSummary)
                    .font(.title2)
                    .bold() // Use .bold() for consistency
                    .padding()

                mealsList
            }
        }
    }

    private var mealsList: some View {
        ForEach(dailyData.meals.indices.reversed(), id: \.self) { index in
            MealCell(meal: dailyData.meals[index]) // Using index to avoid reversing complex data structures directly
                .padding(.horizontal) // Added horizontal padding for alignment with the summary text
        }
    }
}
