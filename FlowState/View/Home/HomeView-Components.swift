//
//  Home-Components.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 29/6/25.
//

import SwiftUI

extension HomeView {
    var durationPicker: some View {
        HStack(spacing: 6) {
            ForEach(AppConfig.durationPresets, id: \.self) { minutes in
                Button(action: {
                    viewModel.selectDuration(minutes)
                }) {
                    Text("\(minutes)m")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .foregroundStyle(
                            viewModel.timerViewModel.selectedMinutes == minutes
                            ? .white
                            : AppConfig.ColorTheme.secondaryText
                        )
                        .background(
                            viewModel.timerViewModel.selectedMinutes == minutes
                            ? Color.grayWarm900
                            : Color.grayWarm200
                        )
                        .clipShape(RoundedRectangle(cornerRadius: .infinity))
                }
                .buttonStyle(.plain)
            }
        }
        .disabled(viewModel.appState != .idle)
        .opacity(viewModel.appState != .idle ? 0.4 : 1)
    }
    
    var focusImage: some View {
        Image(viewModel.appState == .running ? .campfire : .marshmallow)
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 300)
    }
    
    var mainGroupButtons: some View {
        VStack(spacing: 6) {
            timerButton
            
            settingButton
                .frame(maxWidth: 300)
            
            Text(viewModel.appState == .idle
                 ? "Start the timer to block sites and apps from your block list. You can edit in Settings."
                 : "You cannot pause the timer or quit the app during an active session.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppConfig.ColorTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
    }
    
    var settingButton: some View {
        Button(action: {
            viewModel.appNavigationView = .edit
        }) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
                    .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 2.0)))
                Text("Settings")
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
            viewModel.startSession()
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
//        .disabled(viewModel.isSessionActive)
    }
}
