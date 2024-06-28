//
//  FoodCell.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/11/24.
//

import Foundation
import SwiftUI

struct MealCell: View {
    var meal: Meal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            mealImageView
            descriptiveSection(title: meal.name, content: nil, titleStyle: .title2)
            descriptiveSection(title: "Summary", content: meal.description)
            descriptiveSection(title: "Pros", content: meal.pros.first ?? "")
            descriptiveSection(title: "Cons", content: meal.cons.first ?? "")
            tagsScrollView
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .padding()
    }
    
    var mealImageView: some View {
        Image(image: meal.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 150)
            .clipShape(Rectangle())
    }
    
    func descriptiveSection(title: String, content: String?, titleStyle: Font.TextStyle = .title3) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.title)
                .bold()
                .padding(.horizontal)
            
            if let content = content {
                Text(content)
                    .font(.body)
                    .padding(.horizontal)
            }
        }
    }
    
    var tagsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(meal.tags, id: \.self) { tag in
                    tagView(tag: tag)
                }
            }
            .padding(.horizontal)
        }
    }
    
    func tagView(tag: String) -> some View {
        Text(tag)
            .padding(.all, 5)
            .background(Color.white)
            .cornerRadius(20)
    }
}
