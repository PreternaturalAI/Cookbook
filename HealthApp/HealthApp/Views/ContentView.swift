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
                Image(systemName: currentTab == 0 ? .house : .houseFill)
                Text(
                    "Home"
                )
            }.tag(1)
            SideprojectAccountsView().tabItem {
                Image(systemName: currentTab == 1 ? .mailStack : .mailStackFill)
                Text(
                    "Accounts"
                )
            }.tag(2)
        }.errorAlert(error: self.$router.error)
    }
}
