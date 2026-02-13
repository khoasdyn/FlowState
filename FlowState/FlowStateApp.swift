//
//  FlowStateApp.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import SwiftUI
import SwiftData

enum AppNavigationView {
    case home
    case edit
}

@main
struct FlowStateApp: App {
    @State var viewModel = ViewModel()
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, maxWidth: 600, minHeight: 640, maxHeight: 700)
                .preferredColorScheme(.light)
                .modelContainer(for: BlockedItem.self)
                .environment(viewModel)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        
        MenuBarScene(showMenuBarExtra: $showMenuBarExtra)
            .environment(viewModel)
    }
}

struct ContentView: View {
    @Environment(ViewModel.self) var viewModel
    @Query var blockedList: [BlockedItem]
    
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
            viewModel.countTime()
            viewModel.blockedWebsites = blockedList
        }
    }
}
