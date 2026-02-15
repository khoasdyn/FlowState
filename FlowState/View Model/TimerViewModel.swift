//
//  TimerViewModel.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 29/6/25.
//

import Foundation

@Observable
class TimerViewModel {
    
    // MARK: - Properties
    let timeAmount: Int = 300 // 300 seconds = 5 minutes
    let minRemainingTime: Int = 300
    let maxRemainingTime: Int = 7200 // 120 minutes in seconds
    var selectedMinutes: Int = AppConfig.defaultDuration
    var remainingTime: Int = AppConfig.defaultDuration * 60
    var sessionStartDate: Date?
    
    // MARK: - Computed Properties
    
    /// The clock time when the session ends, based on remaining seconds from now.
    var sessionEndDate: Date {
        Date.now.addingTimeInterval(TimeInterval(remainingTime))
    }
    
    var canSubtractTime: Bool {
        remainingTime > minRemainingTime
    }
    
    var canAddTime: Bool {
        remainingTime + timeAmount <= maxRemainingTime
    }
    
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
        guard canAddTime else { return }
        remainingTime += timeAmount
    }
    
    func subtractTime() {
        guard canSubtractTime else { return }
        remainingTime = max(minRemainingTime, remainingTime - timeAmount)
    }
}
