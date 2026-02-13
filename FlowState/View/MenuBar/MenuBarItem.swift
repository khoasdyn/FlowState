import Foundation
import SwiftUI

struct MenuBarItem: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Button("Show App") {
                NSApp.activate(ignoringOtherApps: true)
            }
            
            Divider()
            
            Button("Start Session") {
                viewModel.timerViewModel.start()
            }
            .disabled(viewModel.appState != .idle)
            
            Divider()
            
            Button(viewModel.appState == .paused ? "Unpause Session" : "Pause Session") {
                if viewModel.appState == .paused {
                    viewModel.timerViewModel.resume()
                } else {
                    viewModel.timerViewModel.pause()
                }
            }
            .disabled(viewModel.appState == .idle)
            
            Divider()
            
            Button("-5") {
                viewModel.timerViewModel.subtractTime()
            }
            .disabled(viewModel.appState == .idle || viewModel.checkOverTime)
            
            Button("+5") {
                viewModel.timerViewModel.addTime()
            }
            .disabled(viewModel.appState == .idle || viewModel.checkOverTime)

            Divider()
            
            Button("Finish Session") {
                viewModel.timerViewModel.reset()
            }
            .disabled(viewModel.appState == .idle)
            
            Divider()
            
            Button("Settings") {
                NSApp.activate(ignoringOtherApps: true)
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
