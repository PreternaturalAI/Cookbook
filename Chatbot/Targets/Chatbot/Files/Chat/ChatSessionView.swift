//
// Copyright (c) Vatsal Manot
//

import ChatKit

struct ChatSessionView: View {
    @PersistentObject var session = ChatSession()
    
    var body: some View {
        chatView
            .toolbar {
                refreshButton
            }
            .navigationTitle("Chatbot")
    }
    
    private var refreshButton: some View {
        Button("Refresh") {
            session = ChatSession()
        }
        .keyboardShortcut("r")
    }
    
    private var chatView: some View {
        ChatView {
            ChatMessageList(session.document.messages)
        } input: {
            ChatInputBar { input in
                Task { @MainActor in
                    await session.send(input)
                }
            }
        }
        .activityPhaseOfLastItem(session.activityPhaseOfLastItem)
    }
}
