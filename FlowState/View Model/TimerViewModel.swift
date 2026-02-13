//
//  TimerViewModel_New.swift
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
    var viewModel: ViewModel?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let timeAmount: Int = 5 // 300 seconds = 5 minutes
    var currentSessionTime: Int = 0
    
    // MARK: - Methods
    func start() {
        viewModel?.appState = .running
        currentSessionTime = viewModel?.initialTime ?? 0
    }
    
    func countTime() {
        guard viewModel?.appState == .running else { return }
        viewModel?.monitoring()
        
        if currentSessionTime != 0 {
            viewModel?.initialTime -= 1
        } else {
            viewModel?.initialTime += 1
        }
        
        if viewModel?.initialTime ?? 0 < 0 { // Over time
            viewModel?.initialTime = currentSessionTime
            currentSessionTime = 0 // reset
        }
    }
    
    func pause() {
        viewModel?.appState = .paused
    }
    
    func resume() {
        viewModel?.appState = .running
    }
    
    func reset() {
        viewModel?.appState = .idle
        viewModel?.initialTime = AppConfig.pomodoroTime
    }
    
    func addTime() {
        viewModel?.initialTime += timeAmount
        currentSessionTime += timeAmount // update total time
    }
    
    func subtractTime() {
        viewModel?.initialTime = max(0, (viewModel?.initialTime ?? 0) - timeAmount)
        currentSessionTime = max(0, currentSessionTime - timeAmount) // update total time
    }
}
