//
// Copyright (c) Vatsal Manot
//

import Cataphyl
import Lite
import SwiftUIX
import SwiftUIZ

@MainActor
final class SearchViewModel: ObservableObject {
    let safariHistoryManager = SafariHistoryManager(historyURL: URL.downloadsDirectory.appending("Safari-History/History.db"))
    
    @Published var searchHistory: [SafariHistoryRecord] = []
    
    func load() async throws {
        searchHistory = try await safariHistoryManager.fetchHistory()
    }
}

struct SearchView: View {
    @StateObject var searchViewModel = SearchViewModel()
    
    var body: some View {
        XStack {
            contentView
        }
        .task {
            do {
                try await searchViewModel.load()
            } catch {
                runtimeIssue(error)
            }
        }
    }
    
    var contentView: some View {
        List {
            ForEach(searchViewModel.searchHistory, id: \.hashValue) { record in
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
