//
//  WebsiteBlocker.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 26/1/25.
//

import Foundation

@Observable
class WebsiteBlocker {
    
    /// Checks Chrome's active tab URL against the blocklist and redirects if matched.
    func check(against blocklist: [BlockedWebsite]) {
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
                let currentURL = output.stringValue ?? ""
                
                guard let host = extractHost(from: currentURL) else { return }
                
                for item in blocklist {
                    if isHostBlocked(host: host, blockedDomain: item.domain) {
                        redirectToBlockPage()
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - Private
    
    /// Extracts the host from a URL string and strips the "www." prefix.
    private func extractHost(from urlString: String) -> String? {
        guard let url = URL(string: urlString), let host = url.host() else { return nil }
        
        var cleaned = host.lowercased()
        if cleaned.hasPrefix("www.") {
            cleaned = String(cleaned.dropFirst(4))
        }
        return cleaned
    }
    
    /// Checks for exact domain match or subdomain match.
    private func isHostBlocked(host: String, blockedDomain: String) -> Bool {
        let domain = blockedDomain.lowercased()
        return host == domain || host.hasSuffix("." + domain)
    }
    
    /// Redirects Chrome's active tab to the bundled block page.
    private func redirectToBlockPage() {
        guard let path = Bundle.main.path(forResource: "BlockPage", ofType: "html") else {
            print("Error: BlockPage.html not found in bundle")
            return
        }
        let fileURL = URL(fileURLWithPath: path).absoluteString
        
        let appleScript = """
            tell application "Google Chrome"
                set URL of active tab of window 1 to "\(fileURL)"
            end tell
            """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: appleScript) {
            let _ = scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
}
