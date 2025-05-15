//
//  GameTimerCoordinator.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/13/25.
//


import SwiftUI
import MijickTimer

@MainActor class GameTimerCoordinator: ObservableObject {
    @Published var quarterTimer = MTimer(.game)
    @Published var subTimer = MTimer(.sub)
    @Published var currentQuarter = 0

    let totalPeriods: Int
    let periodLength: TimeInterval
    let substitutionInterval: TimeInterval
    
    var onSubTimerFinish: (() -> Void)?

    var isGameOver: Bool {
        currentQuarter >= totalPeriods
    }
    
    init(totalPeriods: Int = 4, periodLength: TimeInterval = 600, substitutionInterval: TimeInterval = 240) {
        // cancel any subTimer that might exist
        self.totalPeriods = totalPeriods
        self.periodLength = periodLength
        self.substitutionInterval = substitutionInterval
    }
}

extension GameTimerCoordinator {
    func togglePlayPause() {
        guard !isGameOver else { return }

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
    }
    func startSubstitution() {
        try? subTimer
            .publish(every: 1)
            .onTimerStatusChange { [weak self] in self?.onSubstitutionChange($0) }
            .start(from: substitutionInterval, to: 0)
    }
    func restartSubTimer(remaining: TimeInterval) {
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

private extension MTimerID {
    static let game = MTimerID(rawValue: "Quarter Timer")
    static let sub = MTimerID(rawValue: "Substitution Timer")
}
