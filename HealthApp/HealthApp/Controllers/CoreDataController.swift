//
//  CoreDataController.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/12/24.
//

import Foundation
import CoreData

class CoreDataController: ObservableObject {
    @Published var data: [Day] = []
    
    // CoreData stack
    let context: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "Data")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load CoreData stack: \(error)")
            }
        })
        return container.viewContext
    }()
    
    func loadData() {
        let dayFetchRequest: NSFetchRequest<DayEntity> = DayEntity.fetchRequest()
        do {
            let dayEntities = try context.fetch(dayFetchRequest)
            var dailyData = dayEntities.map { Day(dayEntity: $0) }
            let mealFetchRequest: NSFetchRequest<MealEntity> = MealEntity.fetchRequest()
            do {
                let mealEntities = try context.fetch(mealFetchRequest)
                let meals = mealEntities.map { Meal(mealEntity: $0) }
                for day in dailyData.indices {
                    dailyData[day].meals = meals
                }
                self.data = dailyData
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            // Handle error
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveMeal(meal: Meal) {
        meal.save(context: context)
        self.loadData()
    }
    
    func saveDay(day: Day) {
        day.save(context: context)
        self.loadData()
    }
    
}
