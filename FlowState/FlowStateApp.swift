//
//  FlowStateApp.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import SwiftUI
import SwiftData
import AppKit

enum AppNavigationView {
    case home
    case edit
}

// MARK: - App Delegate

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
    func showQuitBlockedAlert() {
        let alert = NSAlert()
        alert.messageText = "You cannot quit FlowState while a focus session is active."
        alert.informativeText = "You can force quit FlowState using Activity Monitor if you haven't blocked it.\n\nActivity Monitor → FlowState → Stop button → Force Quit"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Minimize")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // Minimize: hide the app window into the Dock.
            NSApplication.shared.mainWindow?.miniaturize(nil)
        }
        // Cancel: do nothing, just dismiss the alert.
    }
}

// MARK: - App Entry Point

@main
struct FlowStateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var viewModel = ViewModel()
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, maxWidth: 600, minHeight: 640, maxHeight: 700)
                .preferredColorScheme(.light)
                .modelContainer(for: [BlockedWebsite.self, BlockedApp.self])
                .environment(viewModel)
                .onAppear {
                    appDelegate.viewModel = viewModel
                }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("Quit FlowState") {
                    if viewModel.isSessionActive {
                        appDelegate.showQuitBlockedAlert()
                    } else {
                        NSApplication.shared.terminate(nil)
                    }
                }
                .keyboardShortcut("q")
            }
        }
        
        MenuBarScene(showMenuBarExtra: $showMenuBarExtra)
            .environment(viewModel)
    }
}

struct ContentView: View {
    @Environment(ViewModel.self) var viewModel
    @Query var blockedWebsiteList: [BlockedWebsite]
    @Query var blockedAppList: [BlockedApp]
    
    var body: some View {
        Group {
            switch viewModel.appNavigationView {
            case .home:
                HomeView()
            case .edit:
                SettingView()
            }
        }
        .onReceive(viewModel.timerViewModel.timer) { _ in
            viewModel.blockedDomains = blockedWebsiteList.map { $0.domain }
            viewModel.blockedAppNames = blockedAppList.map { $0.name }
            viewModel.countTime()
        }
    }
}
