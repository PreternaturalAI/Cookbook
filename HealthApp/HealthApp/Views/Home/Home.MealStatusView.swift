//
//  Home.MealStatusView.swift
//  HealthApp
//
//  Created by Jared Davidson on 6/27/24.
//

import Foundation
import SwiftUI

extension HomeView {
    struct MealStatusView: View {
        let status: MealStatus
        let image: UIImage
        @ObservedObject var dataController: MealController
        
        var body: some View {
            HStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                
                Text(status.description)
                    .font(.caption)
                
                Spacer()
                
                statusActionButton
            }
        }
        
        var statusActionButton: some View {
            switch status {
            case .analyzing, .uploading:
                return AnyView(ProgressView())
            case .failure:
                return AnyView(Button("Cancel") {
                    dataController.mealStatus = nil
                }
                    .bold()
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(5))
            default:
                return AnyView(EmptyView())
            }
        }
    }
}

