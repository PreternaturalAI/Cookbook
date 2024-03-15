//
//  Meal.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/11/24.
//

import Foundation
import SwiftUI
import CoreData

struct Meal: Identifiable {
    var id = UUID()
    var name: String
    var components: [String]
    var description: String
    var pros: [String]
    var cons: [String]
    var tags: [String]
    var image: UIImage
}

// Extend Meal to initialize from a MealEntity
extension Meal {
    init(mealEntity: MealEntity) {
        id = mealEntity.id ?? UUID()
        name = mealEntity.name ?? "Unknown"
        components = (mealEntity.components as? [String]) ?? []
        description = mealEntity.explanation ?? ""
        pros = (mealEntity.pros as? [String]) ?? []
        cons = (mealEntity.cons as? [String]) ?? []
        tags = (mealEntity.tags as? [String]) ?? []
        image = UIImage(data: mealEntity.image!)!
    }
}

// Add methods to save Meal and DailyData back to Core Data
extension Meal {
    func save(context: NSManagedObjectContext) {
        let mealEntity = MealEntity(context: context)
        mealEntity.id = id
        mealEntity.name = name
        mealEntity.components = components as NSArray
        mealEntity.explanation = description
        mealEntity.pros = pros as NSArray
        mealEntity.cons = cons as NSArray
        mealEntity.tags = tags as NSArray
        mealEntity.image = image.jpegData(compressionQuality: 0.8)
        // Save context
        do {
            try context.save()
        } catch {
            // Handle error
        }
    }
}

//
//let testData: [Meal] = [
//    Meal(
//        name: "Classic Breakfast",
//        components: ["2 eggs", "4 bacon strips", "2 slices of toast", "1 cup of orange juice"],
//        description: "A traditional American breakfast to start your day.",
//        pros: ["High Protein", "Provides Energy", "Rich in Iron"],
//        cons: ["High in Cholesterol", "May be high in sodium"],
//        tags: ["Breakfast", "High Protein", "American"],
//        image: "1"
//    ),
//    Meal(
//        name: "Avocado Salad",
//        components: ["1 ripe avocado", "Mixed greens", "Tomato", "Cucumber", "Red onion", "Olive oil", "Lemon juice"],
//        description: "A refreshing and nutritious salad with ripe avocados.",
//        pros: ["Rich in Vitamins", "Heart Healthy Fats", "High Fiber"],
//        cons: ["May be high in calories if overeaten", "Not a full meal"],
//        tags: ["Salad", "Vegan", "Low Carb"],
//        image: "2"
//    ),
//    Meal(
//        name: "Grilled Chicken",
//        components: ["1 chicken breast", "Olive oil", "Lemon juice", "Garlic", "Rosemary"],
//        description: "Perfectly grilled chicken breast with a side of vegetables.",
//        pros: ["High Protein", "Low Fat", "Rich in Selenium"],
//        cons: ["Can be dry if overcooked", "Requires marination"],
//        tags: ["Lunch", "Dinner", "Protein Rich"],
//        image: "3"
//    ),
//    Meal(
//        name: "Vegetable Stir Fry",
//        components: ["Broccoli", "Carrot", "Bell pepper", "Snow peas", "Soy sauce", "Olive oil"],
//        description: "A quick and easy stir fry full of colorful vegetables.",
//        pros: ["High in Vitamins", "Low Calories", "Quick to make"],
//        cons: ["May need additional protein source", "High sodium if too much soy sauce used"],
//        tags: ["Dinner", "Vegan", "Low Calorie"],
//        image: "4"
//    ),
//    Meal(
//        name: "Spaghetti Carbonara",
//        components: ["Spaghetti", "Pancetta", "Eggs", "Parmesan cheese", "Black pepper"],
//        description: "A classic Italian pasta dish with eggs, cheese, and pork.",
//        pros: ["Rich Flavor", "High Energy", "Comfort Food"],
//        cons: ["High in Calories", "Not for cholesterol-conscious"],
//        tags: ["Lunch", "Dinner", "Italian"],
//        image: "5"
//    )
//]
