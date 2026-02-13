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
    // MARK: - Child Model
    var categoryEditViewModel: CategoryEditViewModel
    var blockedWebsitesViewModel: BlockedWebsitesViewModel
    var timerViewModel: TimerViewModel
    
    // MARK: – App Management
    var appNavigationView: AppNavigationView = .home
    var appState: TimerState = .idle
    var blockedWebsites: [BlockedItem] = []
    
    // MARK: – Computed Properties
    
    var formattedTime: String {
        let minutes = timerViewModel.remainingTime / 60
        let seconds = timerViewModel.remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var checkOverTime: Bool {
        timerViewModel.totalSessionTime == 0 && appState != .idle
    }
    
    // MARK: – Init
    
    init() {
        self.categoryEditViewModel = CategoryEditViewModel()
        self.blockedWebsitesViewModel = BlockedWebsitesViewModel()
        self.timerViewModel = TimerViewModel()
    }
    
    // MARK: – Session Control
    
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
        timerViewModel.start()
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
    
    func addTime() {
        timerViewModel.addTime()
    }
    
    func subtractTime() {
        timerViewModel.subtractTime()
    }
    
    // MARK: – Timer Tick (called every second from ContentView's .onReceive)
    
    func countTime() {
        guard appState == .running else { return }
        monitoring()
        timerViewModel.tick()
    }
    
    // MARK: – Website Monitoring
    
    func monitoring() {
        guard appState == .running else { return }
        blockedWebsitesViewModel.checkChromeURL(list: blockedWebsites)
    }
}
