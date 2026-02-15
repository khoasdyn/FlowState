//
//  WebsiteBlocker.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 26/1/25.
//

import Foundation

class WebsiteBlocker {
    
    /// Pre-compiled script that reads Chrome's active tab URL.
    /// Created once in init() and reused on every check.
    private let compiledGetURL: NSAppleScript?
    
    /// Pre-compiled script that redirects Chrome's active tab to the block page.
    /// The block page path from Bundle.main does not change at runtime, so
    /// this script can be fully compiled once and reused.
    private let compiledRedirect: NSAppleScript?
    
    init() {
        // Compile the "get URL" script once
        let getURLSource = """
            tell application "Google Chrome"
                set currentTabURL to URL of active tab of window 1
            end tell
            return currentTabURL
            """
        let getURLScript = NSAppleScript(source: getURLSource)
        getURLScript?.compileAndReturnError(nil)
        compiledGetURL = getURLScript
        
        // Compile the "redirect" script once using the bundle path
        if let path = Bundle.main.path(forResource: "BlockPage", ofType: "html") {
            let fileURL = URL(fileURLWithPath: path).absoluteString
            let redirectSource = """
                tell application "Google Chrome"
                    set URL of active tab of window 1 to "\(fileURL)"
                end tell
                """
            let redirectScript = NSAppleScript(source: redirectSource)
            redirectScript?.compileAndReturnError(nil)
            compiledRedirect = redirectScript
        } else {
            print("Error: BlockPage.html not found in bundle")
            compiledRedirect = nil
        }
    }
    
    /// Checks Chrome's active tab URL against the blocklist and redirects if matched.
    func check(against blocklist: [String]) {
        guard !blocklist.isEmpty else { return }
        
        var error: NSDictionary?
        let output = compiledGetURL?.executeAndReturnError(&error)
        
        if error != nil { return }
        
        let currentURL = output?.stringValue ?? ""
        guard let host = extractHost(from: currentURL) else { return }
        
        for domain in blocklist {
            if isHostBlocked(host: host, blockedDomain: domain) {
                redirectToBlockPage()
                break
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
    
    /// Executes the pre-compiled redirect script to send Chrome's active tab
    /// to the bundled block page.
    private func redirectToBlockPage() {
        guard let compiledRedirect else {
            print("Error: Redirect script was not compiled (BlockPage.html missing)")
            return
        }
        
        var error: NSDictionary?
        compiledRedirect.executeAndReturnError(&error)
        if let error {
            print("Error redirecting: \(error)")
        }
    }
}
