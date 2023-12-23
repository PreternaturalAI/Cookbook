//
// Copyright (c) Vatsal Manot
//

import ChatKit
import Lite

/// A document that represents a chat with an AI assistant.
public struct ChatDocument: Codable, Hashable, Identifiable, PersistentIdentifierConvertible {
    public typealias ID = _TypeAssociatedID<Self, UUID>
    
    public struct Metadata: Codable, Hashable, Sendable {
        public var creationDate: Date = Date()
        public var sendDate: Date?
        public var displayName: String = "Untitled"
    }
    
    public var id: ID
    public var metadata = Metadata()
    public var messages: IdentifierIndexingArrayOf<Message> = []
    
    public init(id: ID) {
        self.id = .random()
    }
    
    public init() {
        self.init(id: .random())
    }
}

extension ChatDocument {
    @dynamicMemberLookup
    public struct Message: Codable, Hashable, Identifiable, Sendable {
        public typealias ID = _TypeAssociatedID<Self, UUID>
        
        public struct Metadata: Codable, Hashable, Sendable {
            public var creationDate: Date = Date()
            public var sendDate: Date?
        }
        
        public let id: ID
        public let base: AbstractLLM.ChatMessage
        public var metadata = Metadata()
        
        public init(id: ID, base: AbstractLLM.ChatMessage) {
            self.base = base
            self.id = id
            self.metadata = .init()
        }
        
        public subscript<T>(
            dynamicMember keyPath: KeyPath<AbstractLLM.ChatMessage, T>
        ) -> T {
            get {
                base[keyPath: keyPath]
            }
        }
    }
}

extension ChatDocument.Message {
    public init(_ message: AbstractLLM.ChatMessage) {
        self.init(id: .random(), base: message)
    }
    
    public init(id: ID = .random(), role: AbstractLLM.ChatRole, content: String) {
        self.init(id: id, base: .init(id: nil, role: role, content: content))
    }
}

extension ChatDocument.Message: AbstractLLM.ChatMessageConvertible {
    public func __conversion() -> AbstractLLM.ChatMessage {
        base
    }
}

extension ChatDocument.Message: AnyChatMessageConvertible {
    public func __conversion() -> AnyChatMessage {
        .init(
            id: self.id,
            isSender: self.role == .user,
            body: (try? self.content._stripToText()) ?? "<error>"
        )
    }
}
