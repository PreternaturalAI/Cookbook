//
//  ContentView.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/9/24.
//

import SwiftUIX

struct HomeView: View {
    @StateObject private var dataController = MealController()
    @StateObject private var coreDataController = CoreDataController()
    @State private var cameraPresented = false
    @State private var subscriptionPresented = false
    @State private var offset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            #if os(iOS)
            Content(dataController: dataController, coreDataController: coreDataController)
                .navigationBarItems(
                    leading: subscriptionButton,
                    trailing: cameraButton
                )
                .overlay(CameraOverlayView(cameraPresented: $cameraPresented, offset: $offset, coreDataController: coreDataController, dataController: dataController))
                .sheet(isPresented: $subscriptionPresented) {
                    StoreKitView()
                }
                .task {
                    coreDataController.loadData()
                }
            #endif
            #if os(macOS)
            Content(dataController: dataController, coreDataController: coreDataController)
                .toolbar {
                    subscriptionButton
//                    cameraButton //TODO: Add PhotoPicker button
                }
            //FIXME: - Add a way to upload a photo using photoPicker
//                .overlay(CameraOverlayView(cameraPresented: $cameraPresented, offset: $offset, coreDataController: coreDataController, dataController: dataController))
                .sheet(isPresented: $subscriptionPresented) {
                    StoreKitView()
                }
                .task {
                    coreDataController.loadData()
                }
            #endif
        }
    }
    
    var subscriptionButton: some View {
        Button {
            subscriptionPresented.toggle()
        } label: {
            Image(systemName: "dollarsign.circle.fill")
        }
    }
    
    var cameraButton: some View {
        Button {
            cameraPresented.toggle()
        } label: {
            Image(systemName: "camera")
        }
    }
}
