//
//  DailySummaryView.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/11/24.
//

import Foundation
import SwiftUI

struct DailySummaryView: View {
    var daily: Day

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(daily.longSummary)
                .font(.title2)
                .bold()

            Text("Summary")
                .font(.callout)
                .padding(.top, 5)
        }
        .padding()
    }
}
