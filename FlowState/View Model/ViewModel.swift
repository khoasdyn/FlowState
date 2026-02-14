//
//  ViewModel.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import SwiftUI
import Foundation

@Observable
class ViewModel {
    // MARK: - Child Services
    var websiteBlocker: WebsiteBlocker
    var appBlocker: AppBlocker
    var timerViewModel: TimerViewModel
    
    // MARK: - App Management
    var appNavigationView: AppNavigationView = .home
    var appState: TimerState = .idle
    var showSessionComplete: Bool = false
    var blockedDomains: [String] = []
    var blockedAppNames: [String] = []
    
    /// The internal timer that fires every second, owned by the ViewModel
    /// so it keeps running even when the window is closed.
    private var tickTimer: Timer?
    
    // MARK: - Computed Properties
    
    var formattedTime: String {
        let minutes = timerViewModel.remainingTime / 60
        let seconds = timerViewModel.remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Returns true when the user is in an active focus session.
    /// This is used by the AppDelegate to decide whether to block quitting.
    var isSessionActive: Bool {
        appState == .running
    }
    
    // MARK: - Init
    
    init() {
        self.websiteBlocker = WebsiteBlocker()
        self.appBlocker = AppBlocker()
        self.timerViewModel = TimerViewModel()
    }
    
    // MARK: - Session Control
    
    func startSession() {
        guard appState == .idle else { return }
        appState = .running
        timerViewModel.sessionStartDate = Date.now
        startTickTimer()
    }
    
    func resetSession() {
        let wasRunning = appState == .running
        appState = .idle
        timerViewModel.sessionStartDate = nil
        timerViewModel.reset()
        stopTickTimer()
        
        if wasRunning {
            showSessionComplete = true
        }
    }
    
    func selectDuration(_ minutes: Int) {
        timerViewModel.selectDuration(minutes)
    }
    
    func addTime() {
        timerViewModel.addTime()
    }
    
    func subtractTime() {
        timerViewModel.subtractTime()
    }
    
    // MARK: - Timer Tick (called every second by the internal tickTimer)
    
    func countTime() {
        guard appState == .running else { return }
        monitoring()
        timerViewModel.tick()
        
        if timerViewModel.remainingTime <= 0 {
            resetSession()
        }
    }
    
    // MARK: - Blocking
    
    func monitoring() {
        guard appState == .running else { return }
        websiteBlocker.check(against: blockedDomains)
        appBlocker.check(against: blockedAppNames)
    }
    
    // MARK: - Internal Timer
    
    private func startTickTimer() {
        stopTickTimer()
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.countTime()
            }
        }
    }
    
    private func stopTickTimer() {
        tickTimer?.invalidate()
        tickTimer = nil
    }
}
