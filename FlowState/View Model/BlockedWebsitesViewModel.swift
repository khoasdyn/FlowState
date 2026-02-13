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
