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

@Model
class BlockedAppItem: Identifiable, Equatable {
    var id = UUID()
    var appName: String  // Display name extracted from the .app bundle (e.g. "Discord")
    var appPath: String  // Full path to the .app (e.g. "/Applications/Discord.app")
    
    init(appName: String, appPath: String) {
        self.appName = appName
        self.appPath = appPath
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
                
                guard let host = extractHost(from: currentURL) else { return }
                
                // Check if the current host matches any blocked domain
                for blockedItem in list {
                    if isHostBlocked(host: host, blockedDomain: blockedItem.blockedURL) {
                        redirectToLocalPage()
                        break
                    }
                }
            }
        }
    }
    
    /// Extracts the host from a URL string and strips the "www." prefix.
    /// For example, "https://www.facebook.com/profile" becomes "facebook.com".
    private func extractHost(from urlString: String) -> String? {
        guard let url = URL(string: urlString), let host = url.host() else { return nil }
        
        var cleanedHost = host.lowercased()
        if cleanedHost.hasPrefix("www.") {
            cleanedHost = String(cleanedHost.dropFirst(4))
        }
        return cleanedHost
    }
    
    /// Checks if the host exactly matches the blocked domain or is a subdomain of it.
    /// For example, if blockedDomain is "facebook.com":
    ///   - "facebook.com" matches (exact)
    ///   - "m.facebook.com" matches (subdomain)
    ///   - "notfacebook.com" does NOT match
    private func isHostBlocked(host: String, blockedDomain: String) -> Bool {
        let domain = blockedDomain.lowercased()
        return host == domain || host.hasSuffix("." + domain)
    }
    
    // MARK: - App Blocking
    
    /// Checks if the currently frontmost app matches any blocked app and hides it.
    func hideBlockedApps(list: [BlockedAppItem]) {
        guard !list.isEmpty else { return }
        
        guard let frontAppName = getFrontmostAppName() else { return }
        
        for blockedApp in list {
            if frontAppName == blockedApp.appName {
                hideApp(named: blockedApp.appName)
                break
            }
        }
    }
    
    /// Uses System Events to get the name of the currently frontmost application.
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
    
    /// Uses System Events to hide a specific application process by name.
    private func hideApp(named appName: String) {
        let appleScript = """
            tell application "System Events"
                set visible of process "\(appName)" to false
            end tell
            """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: appleScript) {
            let _ = scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("Error hiding app \(appName): \(error)")
            }
        }
    }
    
    // MARK: - Redirect
    
    private func redirectToLocalPage() {
        guard let localPagePath = Bundle.main.path(forResource: "BlockPage", ofType: "html") else {
            print("Error: BlockPage.html not found in bundle")
            return
        }
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
