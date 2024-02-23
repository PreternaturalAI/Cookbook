//
// Copyright (c) Vatsal Manot
//

import Lite
import SwiftUIZ

struct ContentView: View {
    var body: some View {
        _NavigationView {
            sidebar
                .frame(minWidth: 256, idealWidth: 256)
            
            detail
                .frame(minWidth: 256, maxWidth: 256 * 3)
        }
        .onAppear {
            withoutAnimation(after: .seconds(1)) {
                _SidebarProxy._keyActive.unhide()
            }
        }
    }
    
    private var sidebar: some View {
        List {
            Section("General") {
                NavigationLink("Accounts") {
                    LTAccountsScene()
                }
                
                NavigationLink("Text Embeddings") {
                    TextEmbeddingsPlaygroundScene()
                }
            }
        }
        .navigationSplitViewColumnWidth(256)
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 256, ideal: 256)
    }
    
    private var detail: some View {
        Text("No Selection")
            .font(.title)
            .foregroundStyle(.secondary)
    }
}
