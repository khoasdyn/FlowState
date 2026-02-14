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
        .padding(.horizontal, 16)
        .padding(.top, 36)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)

    }

}
