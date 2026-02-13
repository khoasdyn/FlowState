//
//  AppBlocker.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 13/2/26.
//

import Foundation

@Observable
class AppBlocker {
    
    /// Checks if the frontmost app matches any blocked app and hides it.
    func check(against blocklist: [BlockedApp]) {
        guard !blocklist.isEmpty else { return }
        guard let frontAppName = getFrontmostAppName() else { return }
        
        for app in blocklist {
            if frontAppName == app.name {
                hide(appNamed: app.name)
                break
            }
        }
    }
    
    // MARK: - Private
    
    /// Gets the name of the currently frontmost application via System Events.
    private func getFrontmostAppName() -> String? {
        let appleScript = """
            tell application "System Events"
                set frontApp to name of first application process whose frontmost is true
            end tell
            return frontApp
            """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: appleScript) {
            let output = scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("Error getting frontmost app: \(error)")
                return nil
            }
            return output.stringValue
        }
        return nil
    }
    
    /// Hides a specific application by setting its visibility to false via System Events.
    private func hide(appNamed name: String) {
        let appleScript = """
            tell application "System Events"
                set visible of process "\(name)" to false
            end tell
            """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: appleScript) {
            let _ = scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("Error hiding app \(name): \(error)")
            }
        }
    }
}
