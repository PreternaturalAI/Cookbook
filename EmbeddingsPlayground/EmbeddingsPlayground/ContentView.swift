//
// Copyright (c) Vatsal Manot
//

import Accelerate
import Cataphyl
import Merge
import LargeLanguageModels
import OpenAI
import SwiftUI
import TabularData

struct ContentView: View {
    @StateObject private var session = TextEmbeddingsPlaygroundSession(document: .unsafelyUnwrapping(AppModel.shared, \.data))
    
    var body: some View {
        Form {
            Section("OpenAI Key:") {
                TextField("", text: $session.document.openAIKey.withDefaultValue(""), prompt: Text("Enter your OpenAI key here..."))
            }
            .multilineTextAlignment(.leading)
            
            Section {
                TextField("", text: $session.document.query.withDefaultValue(""), prompt: Text("Enter your query here.."))
                
                dataList
            } header: {
                HStack {
                    Text("Data")
                    
                    Spacer()
                    
                    insertRowButton
                }
            }
            .multilineTextAlignment(.leading)
            .lineLimit(4)
        }
        .formStyle(.grouped)
        .padding()
    }
    
    @ViewBuilder
    private var dataList: some View {
        List {
            let data: [(Int, Binding<String>)] = $session.document.data.enumerated()
                .sorted(
                    by: { (index, element) -> Double? in
                        return session.document.cache.comparison.scoresByIndex[index] ?? 0
                    },
                    order: .reverse
                )
            
            
            ForEach(data, id: \.0) { (index, text) in
                HStack {
                    Text(index.description)
                        .monospaced()
                        .bold()
                        .fixedSize()
                    
                    TextEditor(text: text)
                        .font(.body)
                        .frame(width: .greedy)
                    
                    if let score = session.document.cache.comparison.scoresByIndex[index] {
                        Text(verbatim: String(format: "%.3f", score))
                            .monospaced()
                            .frame(maxWidth: 64)
                            .fixedSize()
                            .frame(minWidth: 44)
                    }
                }
                .padding(.small)
            }
        }
    }
    
    private var insertRowButton: some View {
        Button {
            session.document.data.append("This is a string.")
        } label: {
            Label("New", systemImage: .plus)
                .imageScale(.medium)
        }
        .buttonStyle(.borderless)
    }
}

public struct TextEmbeddingsPlaygroundDocument: Codable, Hashable, Sendable {
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
    
    var cache = Cache()
    
    public init() {
        
    }
}

public final class TextEmbeddingsPlaygroundSession: _CancellablesProviding, ObservableObject {
    @Dependency(\.textEmbeddingsProvider) var textEmbeddingsProvider
    
    @PublishedAsyncBinding var document: TextEmbeddingsPlaygroundDocument
    
    init(document: PublishedAsyncBinding<TextEmbeddingsPlaygroundDocument>) {
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
                data: try await textEmbeddingsProvider.textEmbeddings(for: data).data.map({ $0.embedding })
            ),
            query: query,
            data: data
        )
    }
}
