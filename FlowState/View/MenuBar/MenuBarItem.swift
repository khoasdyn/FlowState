import Foundation
import SwiftUI
import AppKit

struct MenuBarItem: View {
    @Environment(ViewModel.self) var viewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("-5 min") {
                viewModel.subtractTime()
            }
            .disabled(viewModel.appState == .idle || !viewModel.timerViewModel.canSubtractTime)

            Button("+5 min") {
                viewModel.addTime()
            }
            .disabled(viewModel.appState == .idle || !viewModel.timerViewModel.canAddTime)
        }
        .padding(12)
        .frame(minWidth: 140)
    }
}

#Preview {
    MenuBarItem()
}
