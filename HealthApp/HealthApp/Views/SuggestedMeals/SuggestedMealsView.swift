//
//  SuggestedMealsView.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/9/24.
//

import Foundation
import SwiftUI

struct MealSuggestion: Codable {
    var name: String
    var calories: Int
    var tags: [String]
    var ingredients: [String]
}

struct SuggestedMealsView: View {
    let mealSuggestions: [MealSuggestion] = [
        MealSuggestion(
            name: "Spaghetti Bolognese",
            calories: 850,
            tags: ["High Carb", "Comfort Food"],
            ingredients: ["1 lb ground beef", "1 can tomato sauce", "1 lb spaghetti", "1 onion", "2 cloves garlic", "Salt", "Pepper"]
        ),
        MealSuggestion(
            name: "Caesar Salad",
            calories: 470,
            tags: ["Low Carb", "Healthy", "Quick"],
            ingredients: ["1 head romaine lettuce", "3 oz Parmesan cheese", "1 cup croutons", "Caesar dressing", "1 chicken breast"]
        ),
        MealSuggestion(
            name: "Vegetable Stir Fry",
            calories: 600,
            tags: ["Vegan", "High Fiber", "Nutritious"],
            ingredients: ["1 bell pepper", "2 carrots", "1 head broccoli", "5 mushrooms", "2 tablespoons soy sauce", "1 tablespoon olive oil", "1 cup rice"]
        ),
        MealSuggestion(
            name: "Salmon with Quinoa",
            calories: 700,
            tags: ["High Protein", "Omega-3 Fatty Acids", "Gluten-Free"],
            ingredients: ["1 salmon fillet", "1 cup quinoa", "1 lemon", "1 tablespoon honey", "2 cloves garlic", "Salt", "Pepper"]
        ),
        MealSuggestion(
            name: "Chicken Curry",
            calories: 550,
            tags: ["Spicy", "Flavorful"],
            ingredients: ["1 lb chicken breast", "2 cups coconut milk", "1 onion", "2 tablespoons curry powder", "1 cup rice", "Salt", "Cilantro for garnish"]
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(mealSuggestions.indices, id: \.self) { index in
                    SuggestedMealCell(meal: mealSuggestions[index])
                }
                .padding(.horizontal)
            }
            .navigationTitle("Suggested Meals")
        }
    }
}

// Preview provider for development and testing
struct SuggestedMealsView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestedMealsView()
    }
}

#Preview {
    SuggestedMealsView()
}
