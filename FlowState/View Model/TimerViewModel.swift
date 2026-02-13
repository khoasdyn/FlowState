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
    
    // MARK: - Methods
    
    /// Called every second while the session is running.
    /// Counts down and stops at zero.
    func tick() {
        if remainingTime > 0 {
            remainingTime -= 1
        }
    }
    
    /// Resets the timer back to the default Pomodoro duration.
    func reset() {
        remainingTime = AppConfig.pomodoroTime
    }
    
    func addTime() {
        remainingTime += timeAmount
    }
    
    func subtractTime() {
        remainingTime = max(0, remainingTime - timeAmount)
    }
}
