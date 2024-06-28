//
//  Router.swift
//  HealthApp
//
//  Created by Jared Davidson on 6/27/24.
//

import Foundation
import SwiftUIZ

@Singleton
class Router: ObservableObject {
    @Published var error: Swift.Error? = nil
    
    func showAlert(_ error: AppError) {
        self.error = error
    }
}


enum AppError: LocalizedError {
    case failedToIdentifyFood
    
    var errorDescription: String? {
        switch self {
        case .failedToIdentifyFood:
            return "Failed to identify food"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .failedToIdentifyFood:
            return "Please try again."
        }
    }
}
