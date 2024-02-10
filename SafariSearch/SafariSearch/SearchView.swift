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
    let safariHistoryManager = SafariHistoryManager(historyURL: URL.downloadsDirectory.appending("Safari-History/History.db"))
    
    @Published var searchHistory: [SafariHistoryRecord] = []
    
    struct Key: Codable, Hashable {
        let record: SafariHistoryRecord
    }
    
    @UserDefault.Published("vectorIndex)") var index = NaiveVectorIndex<Key>()

    @Published var searchText: String = "" {
        didSet {
            if searchText.isEmpty {
                searchResults = []
            }
        }
    }
    @Published var searchResults: [SafariHistoryRecord] = []
    
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
    
    func search() async throws {
        let searchEmbedding = try await Lite.shared.textEmbedding(
            for: searchText,
            model: OpenAI.Model.embedding(.text_embedding_3_large)
        )
        
        let searchVector: [Double] = searchEmbedding.rawValue
        
        let results = try index.query(.topMatches(for: searchVector, maximumNumberOfResults: 20))
        
        let records: [SafariHistoryRecord] = results.map({ $0.item.record })
        
        self.searchHistory = records
    }
    
    func load() async throws {
        let searchHistory = try await safariHistoryManager.fetchHistory()
        
        self.searchHistory = Array(searchHistory.prefix(500).distinct())
        
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
            let key = Key(record: record)
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
        XStack {
            VStack {
                SearchBar(text: $searchViewModel.searchText)
                
                if isEmbedding {
                    ActivityIndicator()
                } else {
                    contentView
                }
            }
        }
        .task {
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

            ForEach(data, id: \.hashValue) { record in
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
