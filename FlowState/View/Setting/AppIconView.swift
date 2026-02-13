//
//  AppIconView.swift
//  FlowState
//
//  Created by Claude on 13/2/26.
//

import SwiftUI

/// Displays the icon of a macOS application given its file path.
/// Uses NSWorkspace to extract the app's icon from the bundle.
struct AppIconView: View {
    let appPath: String
    
    var body: some View {
        Image(nsImage: NSWorkspace.shared.icon(forFile: appPath))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 28, height: 28)
    }
}
