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
    @State private var showStopConfirmation = false
    @State private var stopCountdown = 5
    @State private var countdownTimer: Timer?
    
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
        .overlay {
            if showStopConfirmation {
                stopConfirmationModal
            }
        }
    }
    
    private var stopConfirmationModal: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Stop this session?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.grayWarm950)
                    
                    Text("You are in the middle of a focus session. Are you sure you want to stop?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.grayWarm400)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 8) {
                    Button(action: {
                        dismissStopConfirmation()
                    }) {
                        Text("Keep Focusing")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(.grayWarm900)
                            .background(.grayWarm200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        dismissStopConfirmation()
                        viewModel.resetSession()
                    }) {
                        Text(stopCountdown > 0 ? "Stop Session (\(stopCountdown)s)" : "Stop Session")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(stopCountdown > 0 ? .grayWarm400 : .error500)
                            .background(stopCountdown > 0 ? .grayWarm200 : .error100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(stopCountdown > 0)
                }
            }
            .padding(24)
            .frame(width: 320)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        }
    }
    
    func showStopConfirmationModal() {
        stopCountdown = 5
        showStopConfirmation = true
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if stopCountdown > 0 {
                stopCountdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func dismissStopConfirmation() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        showStopConfirmation = false
    }
}
