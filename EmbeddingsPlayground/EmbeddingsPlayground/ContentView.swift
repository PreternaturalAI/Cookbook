//
// Copyright (c) Vatsal Manot
//

import Cataphyl
import Merge
import LargeLanguageModels
import OpenAI
import SwiftUIX

struct ContentView: View {
    @StateObject private var session = PlaygroundDocumentSession(
        document: PublishedAsyncBinding.unsafelyUnwrapping(AppModel.shared, \.data, as: PlaygroundDocument.self)!
    )
    
    var body: some View {
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
        .padding()
    }
    
    private var authenticationSection: some View {
        Section("OpenAI Key:") {
            SecureField(
                "",
                text: $session.document.openAIKey.withDefaultValue(""), 
                prompt: Text("Enter your OpenAI key here...")
            )
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

extension ContentView {
    fileprivate struct Cell: View {
        let index: Int
        
        @Binding var text: String
        
        let score: Double?
        
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
