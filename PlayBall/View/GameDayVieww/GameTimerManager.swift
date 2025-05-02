//
//  GameTimerManager.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/1/25.
//

import Foundation
import ActivityKit
import SwiftUI

class GameTimerManager: ObservableObject {
    @Published var currentQuarter: Int = 1
    @Published var timerRunning = false
    @Published var elapsedTime: TimeInterval = 0

    let quarterLength: TimeInterval
    let totalQuarters: Int

    private var timer: Timer?
    private let liveActivityManager = LiveActivityManager()
    private var startDate: Date?

    var segments: [SubSegment] = []
    var gameName: String = ""
    var availablePlayers: [Player] = []

    init(quarterLength: TimeInterval = 600, totalQuarters: Int = 4) {
        self.quarterLength = quarterLength
        self.totalQuarters = totalQuarters
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
            startDate = Date()
            startTimer()
            if !liveActivityManager.isActive {
                startLiveActivity()
            }
        } else {
            pauseTimer()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.tick()
        }
    }

    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard let start = startDate else { return }

        let now = Date()
        elapsedTime += now.timeIntervalSince(start)
        startDate = now // reset start time for next tick

        updateLiveActivity()

        if elapsedTime >= quarterLength {
            handleQuarterEnd()
        }

        objectWillChange.send()
    }

    private func handleQuarterEnd() {
        pauseTimer()
        timerRunning = false

        if currentQuarter < totalQuarters {
            currentQuarter += 1
            elapsedTime = 0
        } else {
            endLiveActivity()
        }
    }

    func endLiveActivity() {
        liveActivityManager.endLiveActivity(
            currentTime: elapsedTime,
            currentQuarter: currentQuarter
        )
    }

    // MARK: Jumping

    func adjustStartTime(by seconds: TimeInterval) {
        elapsedTime = min(max(elapsedTime + seconds, 0), quarterLength)
    }

    func jumpToLastSub() {
        guard let lastSub = segments.last(where: { $0.on < totalElapsedTime }) else { return }
        let quarterOffset = Double(currentQuarter - 1) * quarterLength
        let target = max(0, lastSub.on - quarterOffset)
        elapsedTime = target
    }

    func jumpToNextSub() {
        guard let nextSub = segments.first(where: { $0.on > totalElapsedTime }) else { return }
        let quarterOffset = Double(currentQuarter - 1) * quarterLength
        let target = min(quarterLength, nextSub.on - quarterOffset)
        elapsedTime = target
    }

    // MARK: Live Activity Helpers

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

    private func updateLiveActivity() {
        liveActivityManager.updateLiveActivity(
            currentTime: elapsedTime,
            currentQuarter: currentQuarter,
            isRunning: timerRunning,
            nextPlayers: nextPlayers,
            nextSubCountdown: nextSubCountdown
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

