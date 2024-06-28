//
//  Health.ButtonStyle.swift
//  HealthApp
//
//  Created by Jared Davidson on 6/27/24.
//

import Foundation
import SwiftUI

public struct Health { }

extension Health {
    public enum ButtonVariant {
        case navigation
    }
    
    public struct ButtonStyle: SwiftUI.ButtonStyle {
        public let variant: ButtonVariant
        
        public func makeBody(
            configuration: Configuration
        ) -> some View {
            ButtonContent(variant: variant, label: configuration.label)
        }
    }
}

extension Health {
    private struct ButtonContent<Label: View>: View {
        @Environment(\.controlSize) var controlSize
        
        @State var hovering: Bool = false
        
        let label: Label
        let variant: Health.ButtonVariant
        
        public init(
            variant: Health.ButtonVariant,
            label: Label
        ) {
            self.variant = variant
            self.label = label
        }
        
        public var body: some View {
            Group {
                switch variant {
                case .navigation:
                    label
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                default:
                    EmptyView()
                }
            }
        }
    }
}

extension ButtonStyle where Self == Health.ButtonStyle {
    static public func health(_ variant: Health.ButtonVariant) -> Self {
        .init(variant: variant)
    }
}
