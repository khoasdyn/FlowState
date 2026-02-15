//
//  BlockedWebsite.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 26/1/25.
//

import SwiftData
import Foundation

@Model
class BlockedWebsite {
    var id = UUID()
    var domain: String
    
    init(domain: String) {
        self.domain = domain
    }
}
