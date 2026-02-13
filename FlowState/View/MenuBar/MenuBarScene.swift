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
                
                Text(viewModel.formattedTime)
                    .monospacedDigit()
            }
        }
    }
} 
