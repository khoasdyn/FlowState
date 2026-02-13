import SwiftUI

struct MenuBarScene: Scene {
    @Binding var showMenuBarExtra: Bool
    @Environment(ViewModel.self) var viewModel
    
    var body: some Scene {
        MenuBarExtra(isInserted: $showMenuBarExtra) {
            MenuBarItem()
                .environment(viewModel)
        } label: {
            HStack(spacing: 24) {
                Image(systemName: "timer")
                
                if viewModel.checkOverTime {
                    Text("Session ended (\(viewModel.formattedTime))")
                        .monospacedDigit()
                } else {
                    Text(viewModel.formattedTime)
                        .monospacedDigit()
                }
            }
        }
    }
} 
