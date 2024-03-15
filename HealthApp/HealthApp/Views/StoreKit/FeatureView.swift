//
//  FeatureView.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/14/24.
//

import Foundation
import SwiftUI

struct FeatureView: View {
    var feature: String

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.black)
            Text(feature)
                .font(.system(size: 20, weight: .regular, design: .default))
        }
    }
}
