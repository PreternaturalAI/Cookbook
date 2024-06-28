//
//  Home.Content.swift
//  HealthApp
//
//  Created by Jared Davidson on 6/27/24.
//

import Foundation
import SwiftUI

extension HomeView {
    struct Content: View {
        @ObservedObject var dataController: MealController
        @ObservedObject var coreDataController: CoreDataController
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    StatusGroupView(dataController: dataController)
                    NavigationLink {
                        SuggestedMealsView()
                    } label: {
                        HStack {
                            Text("Suggested Meals")
                                .frame(width: .greedy, alignment: .leading)
                            Image(systemName: .chevronRight)
                        }
                    }
                    .buttonStyle(.health(.navigation))
                    MealsListView(coreDataController: coreDataController)
                }
                .padding()
            }
        }
    }
}
