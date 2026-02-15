//
//  FlowStateApp.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import SwiftUI
import SwiftData

@main
struct FlowStateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var viewModel = ViewModel()
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
        
        MenuBarScene(showMenuBarExtra: $showMenuBarExtra)
            .environment(viewModel)
    }
}
