//
// Copyright (c) Vatsal Manot
//

import Lite
import SwallowUI

struct ContentView: View {
    var body: some View {
        _NavigationView {
            List {
                NavigationLink("Accounts") {
                    LTAccountsScene()
                }
                
                NavigationLink("Embeddings") {
                    EmbeddingsView()
                }
            }
        }
    }
}

struct EmbeddingsView: View {
    @StateObject private var session = LTEmbeddingsPlaygroundSession(
        document: PublishedAsyncBinding.unsafelyUnwrapping(
            AppModel.shared,
            \.data,
            as: LTEmbeddingsPlayground.self
        )!
    )
    
    var body: some View {
        contentView
            .inspector(isPresented: .constant(true)) {
                inspectorView
            }
    }
    
    var inspectorView: some View {
        List {
            
        }
        .frame(minWidth: 256)
    }
    
    var contentView: some View {
        Form {
            authenticationSection
            
            Section {
                inputField
            } header: {
                Text("Query")
            } footer: {
                Text("This is the string that all the data will be compared against.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Section {
                Focusable { proxy in
                    dataList
                }
                .fixedSize(horizontal: false, vertical: false)
            } header: {
                VStack(spacing: 0) {
                    HStack {
                        Text("Data")
                        
                        Spacer()
                        
                        insertRowButton
                    }
                    
                    Divider()
                }
            }
            .multilineTextAlignment(.leading)
            .lineLimit(4)
        }
        .padding()
    }
    
    @ViewBuilder
    private var authenticationSection: some View {
        Section {
            SecureField(
                "",
                text: $session.document.openAIKey.withDefaultValue(""),
                prompt: Text("Enter your OpenAI key here...")
            )
        } header: {
            Text("OpenAI Key:")
        } footer: {
            PresentationLink {
                WebView(url: URL(string: "https://platform.openai.com/api-keys")!) {
                    ActivityIndicator()
                }
                .frame(minWidth: 512 * 1.5, minHeight: 512 * 1.25)
            } label: {
                Text("If you don't have an OpenAI key, you can obtain one here.")
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
        }
        .multilineTextAlignment(.leading)
    }
    
    private var inputField: some View {
        TextField(
            "",
            text: $session.document.query.withDefaultValue(""),
            prompt: Text("Enter your query here..")
        )
        .frame(width: .greedy, alignment: .leading)
        .multilineTextAlignment(.leading)
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
                Cell(
                    index: index,
                    text: text,
                    score: session.document.cache.comparison.scoresByIndex[index]
                )
                .padding(.vertical, .extraSmall)
                .contextMenu {
                    Button("Delete") {
                        session.document.data.remove(at: index)
                    }
                }
            }
            .onDelete {
                session.document.data.remove(at: $0)
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .cornerRadius(4)
        .animation(.default, value: session.document.data)
    }
    
    private var insertRowButton: some View {
        Button {
            session.document.data.append("Enter your text here!")
        } label: {
            Label("New", systemImage: .plus)
                .imageScale(.medium)
        }
    }
}

extension EmbeddingsView {
    fileprivate struct Cell: View {
        let index: Int
        
        @Binding var text: String
        
        let score: Double?
        
        @FocusState var isFocused: Bool
        
        var body: some View {
            HStack(alignment: .top) {
                HStack(alignment: .top, spacing: 2) {
                    indexView
                        .padding(.top, 1)
                    
                    TextEditor(text: $text)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .scrollDisabled(true)
                        .frame(width: .greedy)
                        .padding(.top, .extraSmall)
                        .focused($isFocused)
                        .opacity(text == "Enter your text here!" ? 0.75 : 1.0)
                }
                .padding(.trailing)
                
                scoreView
                    .help("Similarity Score")
                    .padding(.top, .extraSmall)
            }
            .scrollContentBackground(.hidden)
        }
        
        private var indexView: some View {
            Text(index.description)
                .font(.subheadline.monospaced())
                .foregroundStyle(.primary)
                .fixedSize()
                .padding(.extraSmall)
                .background {
                    Circle()
                        .fill(.tertiary)
                }
        }
        
        private var scoreView: some View {
            Group {
                if let score {
                    Text(verbatim: String(format: "%.4f", score))
                        .monospaced()
                        .frame(minWidth: 44, maxWidth: 64)
                        .fixedSize()
                } else {
                    ProgressView()
                        .controlSize(.mini)
                        .padding(.top, .extraSmall)
                }
            }
        }
    }
}
