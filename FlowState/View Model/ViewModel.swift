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
    var blockedDomains: [String] = []
    var blockedAppNames: [String] = []
    
    // MARK: - Computed Properties
    
    var formattedTime: String {
        let minutes = timerViewModel.remainingTime / 60
        let seconds = timerViewModel.remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Returns true when the user is in an active focus session,
    /// meaning the timer is either counting down or temporarily paused.
    /// This is used by the AppDelegate to decide whether to block quitting.
    var isSessionActive: Bool {
        appState == .running || appState == .paused
    }
    
    // MARK: - Init
    
    init() {
        self.websiteBlocker = WebsiteBlocker()
        self.appBlocker = AppBlocker()
        self.timerViewModel = TimerViewModel()
    }
    
    // MARK: - Session Control
    
    func handleTimer() {
        switch appState {
        case .idle:
            startSession()
        case .paused:
            resumeSession()
        case .running:
            pauseSession()
        }
    }
    
    func startSession() {
        appState = .running
    }
    
    func pauseSession() {
        appState = .paused
    }
    
    func resumeSession() {
        appState = .running
    }
    
    func resetSession() {
        appState = .idle
        timerViewModel.reset()
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
    
    // MARK: - Timer Tick (called every second from ContentView's .onReceive)
    
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
}
