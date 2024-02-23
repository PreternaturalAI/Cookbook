//
// Copyright (c) Vatsal Manot
//

import Cataphyl
import Lite
import SwiftUIX
import SwiftUIZ

@MainActor
final class SearchViewModel: ObservableObject {
    var cancellables: [AnyCancellable] = []
    let safariHistoryManager = SafariHistoryManager()
    
    @Published var searchHistory: IdentifierIndexingArrayOf<SafariHistoryRecord> = []
    
    struct Key: Codable, Hashable {
        let record: SafariHistoryRecord.ID
    }
    
    @UserDefault.Published("vectorIndex") var index = NaiveVectorIndex<Key>()
    
    @Published var searchText: String = "" {
        didSet {
            if searchText.isEmpty {
                searchResults = []
            }
        }
    }
    @Published var searchResults: IdentifierIndexingArrayOf<SafariHistoryRecord> = []
    
    init() {
        $searchText.debounce(
            for: .milliseconds(200),
            scheduler: DispatchQueue.main
        )
        .sink { _ in
            Task { @MainActor in
                do {
                    try await self.search()
                } catch {
                    runtimeIssue(error)
                }
            }
        }
        .store(in: &cancellables)
    }
    
    @MainActor
    func search() async throws {
        let searchEmbedding = try await Lite.shared.textEmbedding(
            for: searchText,
            model: OpenAI.Model.embedding(.text_embedding_3_large)
        )
        
        let searchVector: [Double] = searchEmbedding.rawValue
        
        let results = try index.query(
            .topMatches(for: searchVector, maximumNumberOfResults: 20)
        )
        
        let records: [SafariHistoryRecord] = try results
            .map({ $0.item.record })
            .map({ try self.searchHistory[id: $0].unwrap() })
        
        self.searchHistory = IdentifierIndexingArray(records)
    }
    
    @MainActor
    func load() async throws {
        let searchHistory = try await safariHistoryManager.fetchHistory()
        
        self.searchHistory = IdentifierIndexingArray(searchHistory.distinct(by: \.id))
        
        if index.isEmpty {
            print("Beginning embedding")
            
            try await embed()
            
            print("Finished embedding")
        } else {
            print("Skipping embedding because already done.")
        }
    }
    
    func embed() async throws {
        let textsByKeys: [(Key, String)] = searchHistory.map { (record: SafariHistoryRecord) -> (Key, String) in
            let key = Key(record: record.id)
            let text = "A Safari history item with the title: \(record.title ?? "Untitled"), url: \(record.url)"
            
            return (key, text)
        }
        
        let lite = Lite.shared
        
        let texts: [String] = textsByKeys.map(\.1)
        
        let embeddings: TextEmbeddings = try await lite.textEmbeddings(
            for: texts,
            model: OpenAI.Model.embedding(.text_embedding_3_large)
        )
        
        let keysAndVectors: [(Key, [Double])] = Array(textsByKeys.map(\.0).zip(embeddings.data.map(\.embedding.rawValue)))
        
        index.insert(contentsOf: keysAndVectors)
    }
}

struct SearchView: View {
    @StateObject var searchViewModel = SearchViewModel()
    
    @State var isEmbedding: Bool = false
    
    var body: some View {
        XStack(alignment: .top) {
            VStack {
                SearchBar(text: $searchViewModel.searchText)
                    .controlSize(.large)
                
                if isEmbedding {
                    ActivityIndicator()
                        .padding(.extraLarge)
                } else {
                    contentView
                }
            }
            .padding()
        }
        .task(priority: .high) {
            do {
                isEmbedding = true
                
                try await searchViewModel.load()
                
                isEmbedding = false
            } catch {
                runtimeIssue(error)
            }
        }
    }
    
    var contentView: some View {
        List {
            let data = !searchViewModel.searchResults.isEmpty ? searchViewModel.searchResults : searchViewModel.searchHistory
            
            ForEach(data) { record in
                Cell(record: record)
            }
        }
    }
}

extension SearchView {
    struct Cell: View {
        let record: SafariHistoryRecord
        
        var body: some View {
            VStack(alignment: .leading) {
                if let title = record.title {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)
                } else {
                    Text("Untitled")
                        .font(.body)
                        .italic()
                        .foregroundStyle(.secondary)
                }
                
                Text(record.url)
                    .textContentType(.URL)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}
