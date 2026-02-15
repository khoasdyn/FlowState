//
//  AppBlocker.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 13/2/26.
//

import Foundation

class AppBlocker {
    
    /// Pre-compiled script that asks System Events for the frontmost app name.
    /// Created once in init() and reused on every check, avoiding repeated
    /// string-to-script compilation on each call.
    private let compiledGetFrontApp: NSAppleScript?
    
    /// Caches one compiled "hide app" script per app name, so each script
    /// is only compiled the first time that specific app is blocked.
    private var hideScriptCache: [String: NSAppleScript] = [:]
    
    init() {
        let source = """
            tell application "System Events"
                set frontApp to name of first application process whose frontmost is true
            end tell
            return frontApp
            """
        let script = NSAppleScript(source: source)
        script?.compileAndReturnError(nil)
        compiledGetFrontApp = script
    }
    
    /// Checks if the frontmost app matches any blocked app and hides it.
    func check(against blocklist: [String]) {
        guard !blocklist.isEmpty else { return }
        guard let frontAppName = getFrontmostAppName() else { return }
        
        for appName in blocklist {
            if frontAppName == appName {
                hide(appNamed: appName)
                break
            }
        }
    }
    
    // MARK: - Private
    
    /// Executes the pre-compiled script to get the frontmost app name.
    private func getFrontmostAppName() -> String? {
        var error: NSDictionary?
        let output = compiledGetFrontApp?.executeAndReturnError(&error)
        if error != nil { return nil }
        return output?.stringValue
    }
    
    /// Hides a specific application by setting its visibility to false via System Events.
    /// Uses a cached compiled script for each app name so the script is only
    /// compiled once per unique app name, not on every call.
    private func hide(appNamed name: String) {
        let script: NSAppleScript
        
        if let cached = hideScriptCache[name] {
            script = cached
        } else {
            let source = """
                tell application "System Events"
                    set visible of process "\(name)" to false
                end tell
                """
            guard let newScript = NSAppleScript(source: source) else { return }
            newScript.compileAndReturnError(nil)
            hideScriptCache[name] = newScript
            script = newScript
        }
        
        var error: NSDictionary?
        script.executeAndReturnError(&error)
        if let error {
            print("Error hiding app \(name): \(error)")
        }
    }
}
