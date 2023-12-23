//
// Copyright (c) Vatsal Manot
//

import ChatKit
import Lite

@MainActor
class ChatSession: Logging, ObservableObject {
    @Published var document = ChatDocument()
    @Published var activityPhaseOfLastItem: ChatItemActivityPhase = .idle
    
    let llm: LargeLanguageModelServices = OpenAI.APIClient(apiKey: "---")
    
    var messages: IdentifierIndexingArrayOf<ChatDocument.Message> {
        document.messages
    }
    
    init() {
        
    }
    
    public func send(
        _ message: ChatDocument.Message
    ) async {
        do {
            var wantsStream: Bool = true
            
            if let existingMessageIndex = self.document.messages.index(ofElementIdentifiedBy: message.id) {
                if self.document.messages[existingMessageIndex].content != message.content {
                    self.document.messages[existingMessageIndex] = message
                    
                    if existingMessageIndex == self.document.messages.lastIndex {
                        wantsStream = false
                    } else {
                        self.document.messages.removeAll(after: existingMessageIndex)
                    }
                }
            } else {
                self.document.messages.append(message)
            }
            
            guard wantsStream else {
                return
            }
            
            try await _send()
            
            self.activityPhaseOfLastItem = .idle
        } catch {
            self.logger.error(error)
            
            self.activityPhaseOfLastItem = .failed(error)
        }
    }
    
    public func send(_ body: String) async {
        await send(ChatDocument.Message(id: .random(), role: .user, content: body))
    }
    
    @MainActor
    private func _send() async throws {
        let systemMessage = ChatDocument.Message(AbstractLLM.ChatMessage.system("You are a friendly assistant"))
        let messages = [systemMessage] + self.document.messages
        
        self.activityPhaseOfLastItem = .sending
        
        let latestID: ChatDocument.Message.ID = .random()
        var latestMessage: ChatDocument.Message?
        
        let completion = try await self.llm.completion(
            for: messages.map({ $0.__conversion() }),
            model: OpenAI.Model.chat(.gpt_3_5_turbo)
        )
        
        try await withTaskCancellationHandler { @MainActor in
            for try await _ in completion.values {
                if let message = completion.message {
                    let _message = ChatDocument.Message(id: latestID, base: message)
                    latestMessage = _message
                    
                    withAnimation {
                        self.document.messages.updateOrAppend(_message)
                    }
                }
            }
            
            self.activityPhaseOfLastItem = .idle
        } onCancel: {
            Task { @MainActor in
                if let latestMessage {
                    delete(latestMessage.id)
                }
                
                self.activityPhaseOfLastItem = .idle
            }
        }
        
        self.activityPhaseOfLastItem = .idle
    }
    
    public func delete(
        _ message: ChatDocument.Message.ID
    ) {
        document.messages.removeAll(where: { message == $0.id })
    }
}
