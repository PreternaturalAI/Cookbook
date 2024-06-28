//
//  Home.MealsList.swift
//  HealthApp
//
//  Created by Jared Davidson on 6/27/24.
//

import Foundation
import SwiftUI

extension HomeView {
    struct MealsListView: View {
        @ObservedObject var coreDataController: CoreDataController
        
        var body: some View {
            ForEach(coreDataController.data, id: \.id) { daily in
                NavigationLink(destination: DayView(dailyData: daily)) {
                    DailyCell(dailyData: daily)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
