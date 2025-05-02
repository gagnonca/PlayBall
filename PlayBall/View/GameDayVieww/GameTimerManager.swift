//
//  GameTimerManager.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/1/25.
//

import Foundation
import ActivityKit

class GameTimerManager: ObservableObject {
    @Published var currentTime: TimeInterval = 0
    @Published var currentQuarter: Int = 1
    @Published var timerRunning = false

    private var timer: Timer?
    let quarterLength: TimeInterval
    let totalQuarters: Int
    let timerInterval: TimeInterval

    var segments: [SubSegment] = []
    
    private let liveActivityManager = LiveActivityManager()
    var gameName: String = ""
    var availablePlayers: [Player] = []

    init(quarterLength: TimeInterval = 600, totalQuarters: Int = 4, timerInterval: TimeInterval = 1) {
        self.quarterLength = quarterLength
        self.totalQuarters = totalQuarters
        self.timerInterval = timerInterval
    }

    var totalElapsedTime: TimeInterval {
        (Double(currentQuarter - 1) * quarterLength) + currentTime
    }

    func configure(gameName: String, availablePlayers: [Player]) {
        self.gameName = gameName
        self.availablePlayers = availablePlayers
    }

    func toggleTimer() {
        timerRunning.toggle()
        if timerRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.currentTime < self.quarterLength {
                self.currentTime += 1
                self.updateLiveActivity()
            } else {
                self.stopTimer()
                self.timerRunning = false
                self.updateLiveActivity()

                if self.currentQuarter < self.totalQuarters {
                    self.currentQuarter += 1
                    self.currentTime = 0
                } else {
                    self.endLiveActivity()
                }
            }
        }
        startLiveActivity()
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateSegments(_ newSegments: [SubSegment]) {
        self.segments = newSegments
    }

    // MARK: - Live Activity Controls

    private func startLiveActivity() {
        liveActivityManager.startLiveActivity(
            gameName: gameName,
            currentTime: currentTime,
            currentQuarter: currentQuarter,
            isRunning: timerRunning,
            nextPlayers: nextPlayers,
            nextSubCountdown: nextSubCountdown
        )
    }

    private func updateLiveActivity() {
        liveActivityManager.updateLiveActivity(
            currentTime: currentTime,
            currentQuarter: currentQuarter,
            isRunning: timerRunning,
            nextPlayers: nextPlayers,
            nextSubCountdown: nextSubCountdown
        )
    }

    private func endLiveActivity() {
        liveActivityManager.endLiveActivity(
            currentTime: currentTime,
            currentQuarter: currentQuarter
        )
    }

    // MARK: - Helpers for Live Activity

    private var nextPlayers: [Player] {
        if let next = segments.first(where: { $0.on > totalElapsedTime }) {
            return next.players
        } else {
            return []
        }
    }

    private var nextSubCountdown: TimeInterval? {
        if let next = segments.first(where: { $0.on > totalElapsedTime }) {
            return next.on - totalElapsedTime
        }
        return nil
    }
}
