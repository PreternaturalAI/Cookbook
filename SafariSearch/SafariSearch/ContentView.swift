//
// Copyright (c) Vatsal Manot
//

import Lite
import SwiftUIIntrospect
import SwiftUIZ
import SwiftUIX

struct ContentView: View {
    public enum NavigationSelection: String, Codable, Hashable {
        case accounts
        case search
    }
    
    @UserStorage("navigationSelection") var selection: NavigationSelection = .accounts
    
    var body: some View {
        _NavigationView {
            List(selection: $selection) {
                NavigationLink("Accounts", _tag: .accounts, selection: $selection) {
                    LTAccountsScene()
                }
                
                NavigationLink("Search", _tag: .search, selection: $selection) {
                    SearchView()
                }
            }
        }
        ._navigationSplitViewColumnCollapsible(false)
    }
}
