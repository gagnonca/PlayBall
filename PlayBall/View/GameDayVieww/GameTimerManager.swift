//
//  GameTimerManager.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/1/25.
//

import Foundation
import ActivityKit

class GameTimerManager: ObservableObject {
    @Published var currentQuarter: Int = 1
    @Published var timerRunning = false
    @Published var startTime: Date?
    @Published var pausedElapsedTime: TimeInterval = 0
    
    let quarterLength: TimeInterval
    let totalQuarters: Int
    
    private let liveActivityManager = LiveActivityManager()
    
    var segments: [SubSegment] = []
    var gameName: String = ""
    var availablePlayers: [Player] = []
    
    init(quarterLength: TimeInterval = 600, totalQuarters: Int = 4) {
        self.quarterLength = quarterLength
        self.totalQuarters = totalQuarters
    }
    
    var elapsedTime: TimeInterval {
        if let start = startTime {
            return pausedElapsedTime + Date().timeIntervalSince(start)
        } else {
            return pausedElapsedTime
        }
    }
    
    var isQuarterOver: Bool {
        elapsedTime >= quarterLength
    }
    
    var totalElapsedTime: TimeInterval {
        (Double(currentQuarter - 1) * quarterLength) + elapsedTime
    }
    
    func configure(gameName: String, availablePlayers: [Player]) {
        self.gameName = gameName
        self.availablePlayers = availablePlayers
    }
    
    func updateSegments(_ newSegments: [SubSegment]) {
        self.segments = newSegments
    }
    
    func toggleTimer() {
        timerRunning.toggle()

        if timerRunning {
            // Start running again from pausedElapsedTime
            startTime = Date()
            if !liveActivityManager.isActive {
                startLiveActivity()
            }
        } else {
            // Pause: record where we are
            pausedElapsedTime = elapsedTime
            startTime = nil
        }
    }
    
    func adjustStartTime(by seconds: TimeInterval) {
        guard let start = startTime else { return }
        let newElapsed = elapsedTime + seconds
        let clampedElapsed = min(max(newElapsed, 0), quarterLength)
        let shift = clampedElapsed - elapsedTime
        startTime = start.addingTimeInterval(-shift)
    }
    
    func jumpToLastSub() {
        guard let lastSub = segments.last(where: { $0.on < totalElapsedTime }),
              let start = startTime else { return }
        let quarterOffset = Double(currentQuarter - 1) * quarterLength
        let target = max(0, lastSub.on - quarterOffset)
        let shift = target - elapsedTime
        startTime = start.addingTimeInterval(-shift)
    }
    
    func jumpToNextSub() {
        guard let nextSub = segments.first(where: { $0.on > totalElapsedTime }),
              let start = startTime else { return }
        let quarterOffset = Double(currentQuarter - 1) * quarterLength
        let target = min(quarterLength, nextSub.on - quarterOffset)
        let shift = target - elapsedTime
        startTime = start.addingTimeInterval(-shift)
    }
}
    
// MARK: - Live Activity Helpers
extension GameTimerManager {
    private func startLiveActivity() {
        liveActivityManager.startLiveActivity(
            gameName: gameName,
            currentTime: elapsedTime,
            currentQuarter: currentQuarter,
            isRunning: timerRunning,
            nextPlayers: nextPlayers,
            nextSubCountdown: nextSubCountdown
        )
    }
    
    func updateLiveActivity() {
        liveActivityManager.updateLiveActivity(
            currentTime: elapsedTime,
            currentQuarter: currentQuarter,
            isRunning: timerRunning,
            nextPlayers: nextPlayers,
            nextSubCountdown: nextSubCountdown
        )
    }
    
    private func endLiveActivity() {
        liveActivityManager.endLiveActivity(
            currentTime: elapsedTime,
            currentQuarter: currentQuarter
        )
    }
    
    private var nextPlayers: [Player] {
        if let next = segments.first(where: { $0.on > totalElapsedTime }) {
            return next.players
        }
        return []
    }
    
    private var nextSubCountdown: TimeInterval? {
        if let next = segments.first(where: { $0.on > totalElapsedTime }) {
            return next.on - totalElapsedTime
        }
        return nil
    }
}
