//
//  Item.swift
//  MediTracker
//
//  Created by Igor Gorelik on 10/1/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
