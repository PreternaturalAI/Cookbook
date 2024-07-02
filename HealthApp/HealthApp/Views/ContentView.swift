//
//  ContentVIew.swift
//  HealthApp
//
//  Created by Jared Davidson on 6/27/24.
//

import Foundation
import SwiftUI
import Sideproject

import SwiftUI

enum Tab: String, CaseIterable {
    case home
    case accounts
    
    var label: String {
        switch self {
        case .home: return "Home"
        case .accounts: return "Accounts"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .accounts: return "mail.stack"
        }
    }
    
    var filledIcon: String {
        switch self {
        case .home: return "house.fill"
        case .accounts: return "mail.stack.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: Tab? = .home
    @StateObject private var router = Router.shared
    
    var body: some View {
        #if os(macOS)
        NavigationView {
            List {
                ForEach(Tab.allCases, id: \.self) { tab in
                    NavigationLink(destination: destinationView(for: tab), tag: tab, selection: $selectedTab) {
                        Label(tab.label, systemImage: selectedTab == tab ? tab.filledIcon : tab.icon)
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200)
            if let selectedTab {
                destinationView(for: selectedTab)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .errorAlert(error: $router.error)
        #else
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                destinationView(for: tab)
                    .tabItem {
                        Image(systemName: selectedTab == tab ? tab.filledIcon : tab.icon)
                        Text(tab.label)
                    }
                    .tag(tab)
            }
        }
        .errorAlert(error: $router.error)
        #endif
    }
    
    @ViewBuilder
    func destinationView(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .accounts:
            SideprojectAccountsView()
        }
    }
}
