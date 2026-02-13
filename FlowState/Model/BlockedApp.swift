//
//  BlockedApp.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 13/2/26.
//

import SwiftData
import Foundation

@Model
class BlockedApp: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var path: String
    
    init(name: String, path: String) {
        self.name = name
        self.path = path
    }
}
