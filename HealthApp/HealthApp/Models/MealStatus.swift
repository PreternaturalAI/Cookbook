//
//  MealStatus.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/14/24.
//

import Foundation
import SwiftUI

enum MealStatus: Equatable {
    case uploading
    case analyzing
    case cancelled
    case failure
    case complete
    
    var description: String {
        switch self {
        case .uploading:
            return "Uploading Image"
        case .analyzing:
            return "Analyzing Image"
        case .cancelled:
            return "Cancelled"
        case .failure:
            return "Item was not able to be identified."
        case .complete:
            return "Saved!"
        }
    }
}
