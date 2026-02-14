//
//  Home-Components.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 29/6/25.
//

import SwiftUI

extension HomeView {
    
    // MARK: - Duration picker (idle state)
    
    var durationPicker: some View {
        Group {
            if viewModel.appState == .idle {
                idleDurationPicker
            } else {
                activeDurationAdjuster
            }
        }
    }
    
    private var idleDurationPicker: some View {
        HStack(spacing: 6) {
            ForEach(AppConfig.durationPresets, id: \.self) { minutes in
                Button(action: {
                    viewModel.selectDuration(minutes)
                }) {
                    Text("\(minutes)m")
                        .font(.system(size: 12, weight: .semibold))
                        .pillChip()
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
    }
    
    // MARK: - Duration adjuster (active session)
    
    private var activeDurationAdjuster: some View {
        HStack(spacing: 12) {
            adjustButton(
                label: "-5 min",
                enabled: viewModel.timerViewModel.canSubtractTime,
                action: { viewModel.subtractTime() }
            )
            
            sessionTimeRange
            
            adjustButton(
                label: "+5 min",
                enabled: viewModel.timerViewModel.canAddTime,
                action: { viewModel.addTime() }
            )
        }
    }
    
    private var sessionTimeRange: some View {
        HStack(spacing: 6) {
            if let startDate = viewModel.timerViewModel.sessionStartDate {
                Text(startDate, format: .dateTime.hour().minute())
                Image(systemName: "arrow.right")
                    .font(.system(size: 10, weight: .semibold))
                Text(viewModel.timerViewModel.sessionEndDate, format: .dateTime.hour().minute())
            }
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(AppConfig.ColorTheme.primaryText)
    }
    
    private func adjustButton(label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .pillChip()
                .foregroundStyle(enabled ? AppConfig.ColorTheme.primaryText : AppConfig.ColorTheme.secondaryText)
                .background(Color.grayWarm200)
                .clipShape(RoundedRectangle(cornerRadius: .infinity))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
    }
    
    var focusImage: some View {
        Image(viewModel.appState == .idle ? .marshmallow : .campfire)
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
    }
}
