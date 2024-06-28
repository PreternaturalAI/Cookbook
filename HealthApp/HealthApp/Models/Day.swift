//
//  Day.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/11/24.
//

import Foundation
import SwiftUI
import CoreData

struct Day: Identifiable {
    var id = UUID()
    var date: Date
    var shortSummary: String
    var longSummary: String
    var totalSummary: String
    var meals: [Meal]
}


// Extend DailyData to initialize from a DayEntity
extension Day {
    init(dayEntity: DayEntity) {
        id = dayEntity.id ?? UUID()
        date = dayEntity.date ?? Date()
        shortSummary = dayEntity.shortSummary ?? ""
        longSummary = dayEntity.longSummary ?? ""
        totalSummary = dayEntity.totalSummary ?? ""
        meals = (dayEntity.meals as? Set<MealEntity>)?.map(Meal.init) ?? []
    }
}


extension Day {
    func save(context: NSManagedObjectContext) {
        let dayEntity = DayEntity(context: context)
        dayEntity.id = id
        dayEntity.date = date
        dayEntity.shortSummary = shortSummary
        dayEntity.longSummary = longSummary
        // Relate meals
        let mealEntities = meals.map { meal -> MealEntity in
            let mealEntity = MealEntity(context: context)
            mealEntity.id = meal.id
            mealEntity.name = meal.name
            mealEntity.components = meal.components as NSArray
            mealEntity.explanation = meal.description
            mealEntity.pros = meal.pros as NSArray
            mealEntity.cons = meal.cons as NSArray
            mealEntity.tags = meal.tags as NSArray
            mealEntity.image = meal.image.jpegData
            return mealEntity
        }
        dayEntity.meals = NSSet(array: mealEntities)
        // Save context
        do {
            try context.save()
        } catch {
            // Handle error
        }
    }
}
