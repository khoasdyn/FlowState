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
    
    /// Total seconds the focus session lasted, captured at the moment of completion.
    var completedSessionDuration: Int = 0
    
    /// Counts how many ticks have passed since the last monitoring check.
    /// Monitoring (AppleScript calls) runs every `monitoringInterval` ticks
    /// instead of every tick, reducing expensive inter-process communication.
    private var monitoringTickCounter: Int = 0
    
    /// How many seconds between each monitoring check.
    /// The countdown display still updates every second, but the AppleScript
    /// calls to check blocked apps and websites only happen at this interval.
    /// 2 seconds is fast enough that a user cannot meaningfully interact
    /// with a blocked app or website before it gets caught.
    private let monitoringInterval: Int = 2
    
    // MARK: - Computed Properties
    
    var formattedTime: String {
        let minutes = timerViewModel.remainingTime / 60
        let seconds = timerViewModel.remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedCompletedDuration: String {
        let minutes = completedSessionDuration / 60
        let seconds = completedSessionDuration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Returns true when the user is in an active focus session or completed but not yet dismissed.
    /// This is used by the AppDelegate to decide whether to block quitting.
    var isSessionActive: Bool {
        appState != .idle
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
        monitoringTickCounter = 0
        startTickTimer()
    }
    
    /// Called when the timer reaches zero. Keeps blocking active and shows the completion sheet.
    func completeSession() {
        guard appState == .running, let startDate = timerViewModel.sessionStartDate else { return }
        completedSessionDuration = Int(Date.now.timeIntervalSince(startDate))
        appState = .completed
        showSessionComplete = true
    }
    
    /// Called when the user clicks "Take a Break". Fully resets the app to idle.
    func resetSession() {
        appState = .idle
        timerViewModel.sessionStartDate = nil
        timerViewModel.reset()
        completedSessionDuration = 0
        monitoringTickCounter = 0
        stopTickTimer()
        showSessionComplete = false
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
        guard appState != .idle else { return }
        
        // Run blocking checks only at the monitoring interval, not every tick.
        // This cuts AppleScript overhead in half while still catching blocked
        // apps and websites within 2 seconds.
        monitoringTickCounter += 1
        if monitoringTickCounter >= monitoringInterval {
            monitoringTickCounter = 0
            monitoring()
        }
        
        guard appState == .running else { return }
        timerViewModel.tick()
        
        if timerViewModel.remainingTime <= 0 {
            completeSession()
        }
    }
    
    // MARK: - Blocking
    
    func monitoring() {
        guard appState != .idle else { return }
        websiteBlocker.check(against: blockedDomains)
        appBlocker.check(against: blockedAppNames)
    }
    
    // MARK: - Internal Timer
    
    /// Creates the timer manually and adds it to the RunLoop in .common mode.
    /// .common mode means the timer keeps firing even during UI interactions
    /// like window dragging or resizing, where the default mode would pause it.
    private func startTickTimer() {
        stopTickTimer()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.countTime()
        }
        RunLoop.main.add(timer, forMode: .common)
        tickTimer = timer
    }
    
    private func stopTickTimer() {
        tickTimer?.invalidate()
        tickTimer = nil
    }
}
