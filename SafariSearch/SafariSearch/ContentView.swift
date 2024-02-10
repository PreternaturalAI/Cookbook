//
// Copyright (c) Vatsal Manot
//

import Lite
import SwiftUIZ

struct ContentView: View {
    var body: some View {
        _NavigationView {
            List {
                NavigationLink("Accounts") {
                    LTAccountsScene()
                }
                
                NavigationLink("Search") {
                    SearchView()
                }
            }
        }
    }
}
