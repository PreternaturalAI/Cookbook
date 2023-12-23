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
    }
}

@MainActor
public class AppModel: Logging, ObservableObject {
    static let shared = AppModel()
    
    @FileStorage(
        .userDocuments,
        path: "data.json",
        coder: JSONCoder(),
        options: .init(readErrorRecoveryStrategy: .discardAndReset)
    )
    var data = EmbeddingsPlayground()
}
