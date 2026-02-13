//
//  Home-Components.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 29/6/25.
//

import SwiftUI

extension HomeView {
    var header: some View {
        VStack(spacing: 0) {
            Text("🧘‍♂️")
                .font(.system(size: 64, weight: .semibold))
            
            Text("Session Ended!")
                .opacity(viewModel.checkOverTime ? 1 : 0)
        }
        .frame(maxWidth: 300)
    }
    
    var mainGroupButtons: some View {
        VStack(spacing: 6) {
            timerButton
            
            HStack(spacing: 6) {
                stopButton
                settingButton
            }
            .frame(maxWidth: 300)
            
            Text("Start the timer to block sites on your list.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppConfig.ColorTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
    }
    
    var stopButton: some View {
        Button(action: {
            viewModel.resetSession()
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20, weight: .semibold))
                .frame(height: 48)
                .padding(.horizontal, 24)
                .foregroundStyle(.error500)
                .background(.error100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
    
    var settingButton: some View {
        Button(action: {
            viewModel.appNavigationView = .edit
        }) {
            HStack {
                Image(systemName: viewModel.appState == .running ? "shield.fill" : "shield.slash.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
                    .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 2.0)))
                Text(viewModel.appState == .running ? "Blocking" : "Stopped")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .padding(.horizontal, 24)
            .foregroundStyle(.grayWarm700)
            .background(.grayWarm200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
    
    var timerButton: some View {
        Button(action: {
            viewModel.handleTimer()
        }) {
            HStack(spacing: 0) {
                Image(systemName: viewModel.appState == .running ? "pause.circle.fill" : "play.circle.fill")
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
                    .font(.system(size: 32, weight: .semibold))
                Text(viewModel.formattedTime)
                    .font(.system(size: 24, weight: .semibold))
                    .monospacedDigit()
                    .frame(width: 80)
            }
            .frame(width: 300)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 24)
            .foregroundStyle(.white)
            .background(.blue600)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
