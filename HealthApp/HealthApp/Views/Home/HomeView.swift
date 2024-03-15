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
            mainContent
                .navigationBarItems(
                    leading: subscriptionButton,
                    trailing: cameraButton
                )
                .overlay(cameraOverlay)
                .sheet(isPresented: $subscriptionPresented) {
                    StoreKitView()
                }
                .task {
                    coreDataController.loadData()
                }
        }
    }

    var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                statusGroup
                NavigationButton(title: "Suggested Meals", destination: AnyView(SuggestedMealsView()))
                mealsList
            }
            .padding()
        }
    }

    var statusGroup: some View {
        Group {
            if let status = dataController.mealStatus,
               let image = dataController.currentImage {
                mealStatusView(status: status, image: image)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(15)
                    .transition(.slide)
                    .animation(.spring, value: dataController.mealStatus)
            }
        }
    }

    func mealStatusView(status: MealStatus, image: UIImage) -> some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .cornerRadius(20)

            Text(status.description)
                .font(.caption)

            Spacer()

            statusActionButton(for: status)
        }
    }

    func statusActionButton(for status: MealStatus) -> some View {
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

    var mealsList: some View {
        ForEach(coreDataController.data, id: \.id) { daily in
            NavigationLink(destination: DayView(dailyData: daily)) {
                DailyCell(dailyData: daily)
            }
            .buttonStyle(.plain)
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

    var cameraOverlay: some View {
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

struct CameraInteractionView: View {
    @Binding var cameraPresented: Bool
    @Binding var offset: CGFloat
    var coreDataController: CoreDataController
    var dataController: MealController
    
    var body: some View {
        ZStack {
            Color.black
            CameraView(showing: $cameraPresented) { image in
                processCapturedImage(image)
            }
        }
    }
    
    private func processCapturedImage(_ image: UIImage) {
        cameraPresented = false
        Task {
            await handleMealImage(image)
        }
    }
    
    private func handleMealImage(_ image: UIImage) async {
        Task {
            if let _ = self.coreDataController.data.firstIndex(where: {$0.date.isSameDay(as: Date())}) {
                guard let meal = try await dataController.createMeal(image: image) else {
                    return
                }
                self.coreDataController.saveMeal(meal: meal)
            } else {
                self.coreDataController.saveDay(day: Day(date: Date(), shortSummary: "", longSummary: "", totalSummary: "", meals: []))
                guard let meal = try await dataController.createMeal(image: image) else {
                    return
                }
                self.coreDataController.saveMeal(meal: meal)
            }
        }
    }
}

// Preview provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
