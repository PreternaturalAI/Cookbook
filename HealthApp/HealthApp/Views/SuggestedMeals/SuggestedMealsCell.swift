//
//  SuggestedMealsCell.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/11/24.
//

import Foundation
import SwiftUI

struct SuggestedMealCell: View {
    var meal: MealSuggestion // Pass the meal suggestion here
    @State var saved: Bool = false
    @State var date: Date = Date()

    var body: some View {
        VStack(alignment: .leading) {
            mealHeader
            Text("\(meal.calories) Calories")
                .padding(.horizontal)
            tagsScrollView
            ingredientsSection
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }

    private var mealHeader: some View {
        HStack {
            Text(meal.name)
                .font(.title2)
                .bold()
            Spacer()
            DatePicker("", selection: $date, displayedComponents: .date)
            saveButton
        }
        .padding([.horizontal, .top])
    }

    private var saveButton: some View {
        Button {
            saved.toggle()
        } label: {
            Image(systemName: saved ? "heart.fill" : "heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(saved ? Color.red : Color.black)
        }
    }

    private var tagsScrollView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(meal.tags, id: \.self) { tag in
                    Text(tag)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(20)
                }
            }
            .padding([.leading, .trailing])
        }
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading) {
            Text("Ingredients")
                .font(.headline)
                .bold()
                .padding([.horizontal])
                .opacity(0.6)

            ForEach(meal.ingredients, id: \.self) { ingredient in
                HStack {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 5, height: 5)
                    Text(ingredient)
                }
            }
        }
        .padding([.horizontal, .bottom], 30)
        .opacity(0.6)
    }
}
