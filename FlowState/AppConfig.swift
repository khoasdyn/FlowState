//
//  AppConfig.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 29/6/25.
//

import SwiftUI

struct AppConfig {
    static let durationPresets: [Int] = [5, 10, 15, 25, 45, 60]
    static let defaultDuration: Int = 25
    
    struct ColorTheme {
        static let primaryText = Color.grayWarm900
        static let secondaryText = Color.grayWarm400
        static let secondaryStroke = Color.grayWarm200
    }
}
