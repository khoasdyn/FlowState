//
//  BlockedWebsitesViewModel.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 26/1/25.
//

import SwiftData
import Foundation

@Model
class BlockedItem: Identifiable, Equatable {
    var id = UUID()
    var blockedURL: String
    
    init(blockedURL: String) {
        self.blockedURL = blockedURL
    }
}

@Observable
class BlockedWebsitesViewModel {    
    
    func checkChromeURL(list: [BlockedItem]) {
        let appleScript = """
            tell application "Google Chrome"
                set currentTabURL to URL of active tab of window 1
            end tell
            return currentTabURL
            """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: appleScript) {
            let output = scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("Error: \(error)")
            } else {
                let currentURL = output.stringValue ?? "Failed to get URL"
                
                // Check if the current URL matches any of the blocked websites
                for blockedItem in list {
                    if currentURL.contains(blockedItem.blockedURL) {
                        redirectToLocalPage()
                        break
                    }
                }
            }
        }
    }
    
    private func redirectToLocalPage() {
        // The path to your local HTML file
        let localPagePath = Bundle.main.path(forResource: "BlockPage", ofType: "html")!
        let localPageURL = URL(fileURLWithPath: localPagePath).absoluteString
        
        let appleScriptRedirect = """
            tell application "Google Chrome"
                set URL of active tab of window 1 to "\(localPageURL)"
            end tell
            """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: appleScriptRedirect) {
            let _ = scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
}
