//
//  ContentView.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import SwiftUI
import Foundation

struct HomeView: View {
    @Environment(ViewModel.self) var viewModel

    var body: some View {
        VStack(spacing: 32) {
            durationPicker
            focusImage
            mainGroupButtons
        }
        .pageBackground()
    }
}
