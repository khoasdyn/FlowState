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
    case paused
}


@Observable
class TimerViewModel {
    
    // MARK: - Properties
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let timeAmount: Int = 300 // 300 seconds = 5 minutes
    var remainingTime: Int = AppConfig.pomodoroTime
    var totalSessionTime: Int = 0
    
    // MARK: - Methods
    
    /// Called once when a session begins. Captures the current remainingTime as the
    /// total session duration so the overtime logic knows the boundary.
    func start() {
        totalSessionTime = remainingTime
    }
    
    /// Called every second while the session is running.
    /// Counts down during normal time, counts up during overtime.
    func tick() {
        if totalSessionTime != 0 {
            remainingTime -= 1
        } else {
            remainingTime += 1
        }
        
        // Transition from countdown to overtime
        if remainingTime < 0 {
            remainingTime = totalSessionTime
            totalSessionTime = 0
        }
    }
    
    /// Resets all time values back to the default Pomodoro duration.
    func reset() {
        remainingTime = AppConfig.pomodoroTime
        totalSessionTime = 0
    }
    
    func addTime() {
        remainingTime += timeAmount
        totalSessionTime += timeAmount
    }
    
    func subtractTime() {
        remainingTime = max(0, remainingTime - timeAmount)
        totalSessionTime = max(0, totalSessionTime - timeAmount)
    }
}
