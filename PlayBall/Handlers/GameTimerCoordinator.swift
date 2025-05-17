//
//  GameTimerCoordinator.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/13/25.
//


import SwiftUI
import MijickTimer

@MainActor class GameTimerCoordinator: ObservableObject {
    @Published var quarterTimer: MTimer
    @Published var subTimer: MTimer
    let quarterTimerID: String
    let subTimerID: String
    
    @Published var currentQuarter = 0
    let totalPeriods: Int
    let periodLength: TimeInterval
    let substitutionInterval: TimeInterval
    
    var onGameStart: (() -> Void)?
    var onGameEnd: (() -> Void)?
    var onSubTimerRestarted: (() -> Void)?
    var onSubTimerFinish: (() -> Void)?

    var isGameOver: Bool {
        currentQuarter >= totalPeriods
    }
    
    init(totalPeriods: Int, periodLength: TimeInterval, substitutionInterval: TimeInterval, quarterTimerID: String, subTimerID: String) {
        self.totalPeriods = totalPeriods
        self.periodLength = periodLength
        self.substitutionInterval = substitutionInterval
        self.quarterTimerID = quarterTimerID
        self.subTimerID = subTimerID

        self.quarterTimer = MTimer(MTimerID(rawValue: quarterTimerID))
        self.subTimer = MTimer(MTimerID(rawValue: subTimerID))
    }
}

extension GameTimerCoordinator {
    func togglePlayPause() {
        guard !isGameOver else {
            // callback that the game ended to kill live activity
            onGameEnd?()
            return
        }

        switch quarterTimer.timerStatus {
        case .notStarted, .finished:
            startQuarter()
            toggleSubTimer()
        case .running:
            quarterTimer.pause()
            subTimer.pause()
        case .paused:
            try? quarterTimer.resume()
            try? subTimer.resume()
        }
    }
    func toggleSubTimer() {
        switch subTimer.timerStatus {
        case .paused:
            try? subTimer.resume()
        case .notStarted, .finished:
            startSubstitution()
        default :
            subTimer.pause()
        }
    }
    func startQuarter() {
        currentQuarter += 1
        try? quarterTimer
            .publish(every: 1)
            .onTimerStatusChange { [weak self] in self?.onQuarterChange($0) }
            .start(from: 0, to: periodLength)
        
        // callback that the game started to start live activity
        onGameStart?()
    }
    func startSubstitution() {
        try? subTimer
            .publish(every: 1)
            .onTimerStatusChange { [weak self] in self?.onSubstitutionChange($0) }
            .start(from: substitutionInterval, to: 0)
        
        // callback that the sub restarted to update live activity
        onSubTimerRestarted?()
    }
    func restartSubTimer(remaining: TimeInterval) {
        if subTimer.timerStatus != .notStarted { return }
        subTimer.cancel()
        try? subTimer
            .publish(every: 1)
            .onTimerStatusChange { [weak self] in self?.onSubstitutionChange($0) }
            .start(from: remaining, to: 0)
    }
}

extension GameTimerCoordinator {
    func onQuarterChange(_ status: MTimerStatus) {
        switch status {
        case .notStarted, .finished:
            subTimer.pause()
        default: break
        }
    }
    
    func onSubstitutionChange(_ status: MTimerStatus) {
        switch status {
        case .notStarted, .finished:
            onSubTimerFinish?()
            if (quarterTimer.timerStatus == .running) {
                startSubstitution()
            }
        default: break
        }
    }
}
