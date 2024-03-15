//
//  DailyCell.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/9/24.
//

import Foundation
import SwiftUI

struct DailyCell: View {
    var dailyData: Day

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dailyData.date.formatDateWithOrdinal())
                .font(.title2)
                .bold()
                .padding(.top)
                .padding(.leading)

            Text(dailyData.shortSummary)
                .padding(.horizontal)

            mealsScrollView
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }

    var mealsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(dailyData.meals.reversed()) { meal in
                    mealImageView(meal: meal)
                }
            }
            .padding(.leading)
            .padding(.bottom)
        }
    }

    func mealImageView(meal: Meal) -> some View {
        Image(uiImage: meal.image)
            .resizable()
            .frame(width: 50, height: 50) // Removed alignment as it's not necessary with fixed size
            .clipShape(Circle()) // Creates a circular image
    }
}
