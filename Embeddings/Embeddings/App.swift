//
// Copyright (c) Vatsal Manot
//

import Lite

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commandsRemoved()
    }
}
