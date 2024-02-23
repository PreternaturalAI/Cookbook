//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Lite
import Merge

@MainActor
public class AppModel: Logging, ObservableObject {
    static let shared = AppModel()
    
    @FileStorage(
        .appDocuments,
        path: "data.json",
        coder: JSONCoder(),
        options: .init(readErrorRecoveryStrategy: .discardAndReset)
    )
    var data = LTTextEmbeddingsPlayground()
}
