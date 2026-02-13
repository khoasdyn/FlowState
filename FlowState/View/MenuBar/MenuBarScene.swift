import SwiftUI

struct MenuBarScene: Scene {
    @Binding var showMenuBarExtra: Bool
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some Scene {
        MenuBarExtra(isInserted: $showMenuBarExtra) {
            MenuBarItem()
                .environmentObject(viewModel)
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
