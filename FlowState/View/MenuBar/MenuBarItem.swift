import Foundation
import SwiftUI
import AppKit

struct MenuBarItem: View {
    @Environment(ViewModel.self) var viewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Button("Show App") {
                NSApp.activate(ignoringOtherApps: true)
            }
            
            Divider()
            
            Button("Start Session") {
                viewModel.startSession()
            }
            .disabled(viewModel.appState != .idle)
            
            Divider()
            
            Button("-5 min") {
                viewModel.subtractTime()
            }
            .disabled(viewModel.appState == .idle || !viewModel.timerViewModel.canSubtractTime)

            Button("+5 min") {
                viewModel.addTime()
            }
            .disabled(viewModel.appState == .idle || !viewModel.timerViewModel.canAddTime)
            
            Divider()
            
            Button("Settings") {
                if let window = NSApp.windows.first(where: { $0.canBecomeMain }) {
                    window.makeKeyAndOrderFront(nil)
                }
                NSApp.activate()
                viewModel.appNavigationView = .edit
            }
            
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        .padding(12)
        .frame(minWidth: 140)
    }
}

#Preview {
    MenuBarItem()
} 
