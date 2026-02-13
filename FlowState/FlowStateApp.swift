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
    @StateObject var viewModel = ViewModel()
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 450, maxWidth: 600, minHeight: 550, maxHeight: 640)
                .preferredColorScheme(.light)
                .modelContainer(for: BlockedItem.self)
                .environmentObject(viewModel)
        }
        .windowResizability(.contentSize)
        
        MenuBarScene(showMenuBarExtra: $showMenuBarExtra)
            .environmentObject(viewModel)
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
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
            viewModel.timerViewModel.countTime()
            viewModel.blockedWebsites = blockedList
        }
    }
}
