//
//  NavigationButton.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/11/24.
//

import Foundation
import SwiftUI

struct NavigationButton: View {
    var title: String
    var destination: AnyView
    var backgroundColor: Color = .blue
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor.opacity(0.1))
            .cornerRadius(15)
        }
        .buttonStyle(.plain)
    }
}
