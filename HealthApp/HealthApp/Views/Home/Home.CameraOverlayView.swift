//
//  Home.CameraOverlayView.swift
//  HealthApp
//
//  Created by Jared Davidson on 6/27/24.
//

import Foundation
import SwiftUI

struct CameraOverlayView: View {
    @Binding var cameraPresented: Bool
    @Binding var offset: CGFloat
    var coreDataController: CoreDataController
    var dataController: MealController
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(cameraPresented ? 0.3 : 0)
                .allowsHitTesting(cameraPresented)
                .ignoresSafeArea()
                .onTapGesture {
                    cameraPresented = false
                }
            CameraInteractionView(cameraPresented: $cameraPresented, offset: $offset, coreDataController: coreDataController, dataController: dataController)
                .frame(height: 500)
                .cornerRadius(20)
                .padding()
                .offset(y: (cameraPresented ? 0 : 600) + offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in offset = value.translation.height }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                cameraPresented = false
                                offset = 0
                            } else {
                                offset = 0
                            }
                        }
                )
        }
        .animation(.snappy, value: cameraPresented)
        .animation(.snappy, value: offset)
    }
}

