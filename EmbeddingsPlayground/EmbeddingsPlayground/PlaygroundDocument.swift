//
// Copyright (c) Vatsal Manot
//

import Accelerate
import Cataphyl
import Merge
import LargeLanguageModels
import OpenAI
import SwiftUI

public struct PlaygroundDocument: Codable, Hashable, Sendable {
    var openAIKey: String?
    
    var query: String? {
        didSet {
            cache = .init()
        }
    }
    var data: [String] = [] {
        didSet {
            cache = .init()
        }
    }
        
    var cache = Cache()
    
    public init() {
        
    }
}

public final class PlaygroundDocumentSession: _CancellablesProviding, ObservableObject {
    @Dependency(\.textEmbeddingsProvider) var textEmbeddingsProvider
    
    @PublishedAsyncBinding var document: PlaygroundDocument
    
    init(document: PublishedAsyncBinding<PlaygroundDocument>) {
        self._document = document
        
        $document
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { _ in
                Task { @MainActor in
                    try await self.embed()
                }
            }
            .store(in: cancellables)
    }
    
    @MainActor
    func embed() async throws {
        guard document.cache.embeddings.query == nil || document.cache.embeddings.data == nil || document.cache.comparison == .init() else {
            return
        }
        
        let apiKey = try document.openAIKey.unwrap()
        let textEmbeddingsProvider = OpenAI.APIClient(apiKey: apiKey)
        
        let query = try document.query.unwrap()
        let data = document.data
        
        self.document.cache = try .init(
            embeddings: .init(
                query: try await textEmbeddingsProvider.textEmbedding(for: query),
                data: try await textEmbeddingsProvider.textEmbeddings(for: data).data.map {
                    $0.embedding
                }
            ),
            query: query,
            data: data
        )
    }
}

// MARK: - Auxiliary

extension PlaygroundDocument {
    struct Cache: Codable, Hashable, Sendable {
        struct Embeddings: Codable, Hashable, Sendable {
            var query: _RawTextEmbedding?
            var data: [_RawTextEmbedding]?
        }
        
        struct Comparison: Codable, Hashable, Sendable {
            var scoresByIndex: [Int: Double] = [:]
        }
        
        var embeddings = Embeddings()
        var comparison = Comparison()
        
        init(embeddings: Embeddings, query: String, data: [String]) throws {
            self.embeddings = embeddings
            self.comparison = .init(scoresByIndex: try Dictionary(uniqueKeysWithValues: data.indices.map { index in
                let queryEmbedding = try embeddings.query.unwrap().rawValue
                let dataEmbedding = try embeddings.data.unwrap()[index].rawValue
                
                let similarity = (vDSP.cosineSimilarity(lhs: queryEmbedding, rhs: dataEmbedding))
                
                return (index, similarity)
            }))
        }
        
        init() {
            
        }
    }
}
