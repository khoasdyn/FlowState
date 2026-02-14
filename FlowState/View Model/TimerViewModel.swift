//
//  TimerViewModel.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 29/6/25.
//

import Foundation
import SwiftUI

enum TimerState {
    case idle
    case running
}

@Observable
class TimerViewModel {
    
    // MARK: - Properties
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let timeAmount: Int = 300 // 300 seconds = 5 minutes
    var selectedMinutes: Int = AppConfig.defaultDuration
    var remainingTime: Int = AppConfig.defaultDuration * 60
    
    // MARK: - Methods
    
    /// Updates the selected duration and resets the countdown to match.
    func selectDuration(_ minutes: Int) {
        selectedMinutes = minutes
        remainingTime = minutes * 60
    }
    
    /// Called every second while the session is running.
    /// Counts down and stops at zero.
    func tick() {
        if remainingTime > 0 {
            remainingTime -= 1
        }
    }
    
    /// Resets the timer back to the currently selected duration.
    func reset() {
        remainingTime = selectedMinutes * 60
    }
    
    func addTime() {
        remainingTime += timeAmount
    }
    
    func subtractTime() {
        remainingTime = max(0, remainingTime - timeAmount)
    }
}
