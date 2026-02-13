//
//  TimerViewModel.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import SwiftUI
import Foundation

@Observable
class ViewModel: ObservableObject {
    // MARK: - Child Model
    var categoryEditViewModel: CategoryEditViewModel
    var blockedWebsitesViewModel: BlockedWebsitesViewModel
    var timerViewModel: TimerViewModel
    
    // MARK: – App Management
    var appNavigationView: AppNavigationView = .home
    var appState: TimerState = .idle
    var blockedWebsites: [BlockedItem] = []
    
    // MARK: – Properties
    var initialTime: Int = AppConfig.pomodoroTime
    
    var formattedTime: String {
        let minutes = initialTime / 60
        let seconds = initialTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init() {
        self.categoryEditViewModel = CategoryEditViewModel()
        self.blockedWebsitesViewModel = BlockedWebsitesViewModel()  // Assign it to the property
        self.timerViewModel = TimerViewModel()
        self.timerViewModel.viewModel = self  // Connect the reference
    }

    var checkOverTime: Bool {
        if timerViewModel.currentSessionTime == 0 && appState != .idle {
            return true
        } else {
            return false
        }
    }
    
    func handleTimer() {
        switch appState {
        case .idle:
            timerViewModel.start()
        case .paused:
            timerViewModel.resume()
        case .running:
            timerViewModel.pause()
        }
    }
    
    func monitoring() {
        guard appState == .running else { return }
        blockedWebsitesViewModel.checkChromeURL(list: blockedWebsites)
    }
}
