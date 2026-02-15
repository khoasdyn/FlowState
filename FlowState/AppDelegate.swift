//
//  AppDelegate.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// A reference to the main ViewModel so the delegate can check
    /// whether a focus session is currently active.
    var viewModel: ViewModel?
    
    /// macOS calls this method whenever the app is about to terminate.
    /// Returning `.terminateCancel` blocks the quit entirely.
    /// Returning `.terminateNow` allows the quit to proceed.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let viewModel, viewModel.isSessionActive else {
            return .terminateNow
        }
        
        showQuitBlockedAlert()
        return .terminateCancel
    }
    
    /// Shows a native alert informing the user they cannot quit during a focus session.
    /// Offers "Cancel" to dismiss the alert, or "Minimize" to hide the app window.
    private func showQuitBlockedAlert() {
        let alert = NSAlert()
        alert.messageText = "You cannot quit FlowState while a focus session is active."
        alert.informativeText = "You can force quit FlowState using Activity Monitor if you haven't blocked it.\n\nActivity Monitor → FlowState → Stop button → Force Quit"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Minimize")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            NSApplication.shared.mainWindow?.miniaturize(nil)
        }
    }
}
