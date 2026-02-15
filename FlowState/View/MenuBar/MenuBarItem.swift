//
//  MenuBarItem.swift
//  FlowState
//

import SwiftUI

struct MenuBarItem: View {
    @Environment(ViewModel.self) var viewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("-5 min") {
                viewModel.subtractTime()
            }
            .disabled(viewModel.appState != .running || !viewModel.timerViewModel.canSubtractTime)

            Button("+5 min") {
                viewModel.addTime()
            }
            .disabled(viewModel.appState != .running || !viewModel.timerViewModel.canAddTime)
        }
        .padding(12)
        .frame(minWidth: 140)
    }
}

#Preview {
    MenuBarItem()
        .environment(ViewModel())
}
