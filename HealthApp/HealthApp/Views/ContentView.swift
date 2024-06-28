//
//  ContentVIew.swift
//  HealthApp
//
//  Created by Jared Davidson on 6/27/24.
//

import Foundation
import SwiftUI
import Sideproject

struct ContentView: View {
    @State var currentTab: Int = 0
    @StateObject var router = Router.shared
    
    var body: some View {
        TabView(selection: self.$currentTab) {
            HomeView().tabItem {
                Text(
                    "Home"
                )
            }.tag(1)
            SideprojectAccountsView().tabItem {
                Text(
                    "Accounts"
                )
            }.tag(2)
        }.errorAlert(error: self.$router.error)
    }
}
