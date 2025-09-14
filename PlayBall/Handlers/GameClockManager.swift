//
//  GameClockManager.swift
//  PlayBall
//
//  Created by Corey Gagnon on 8/25/25.
//


import Foundation
import Combine

@MainActor
final class GameClockManager: ObservableObject {
    // MARK: - Published UI state
    @Published private(set) var elapsedSeconds: Int = 0        // 0...periodLength
    @Published private(set) var subRemainingSeconds: Int = 0   // substitution countdown
    @Published private(set) var currentQuarter: Int = 0
    @Published private(set) var isRunning: Bool = false
    
    // MARK: - Config
    let totalPeriods: Int            // 2 for halves, 4 for quarters
    let periodLength: Int            // seconds
    
    // MARK: - Callbacks
    var onGameStart: (() -> Void)?
    var onGameEnd: (() -> Void)?
    var onSubTimerFinish: (() -> Void)?
    var onSubTimerRestarted: (() -> Void)?
    
    // MARK: - Internal clock state
    private(set) var substitutionInterval: Int    // seconds
    private var ticker: DispatchSourceTimer?
    private var periodStartAnchor: Date?   // when current period started/resumed
    private var pausedAccumulated: Int = 0 // seconds elapsed before last pause
    private var lastSubBoundaryAt: Int = 0 // elapsedSeconds when last sub fired
    private var carryOverSubRemaining: Int? = nil // time remaining for sub at the end of a quarter
    
    init(totalPeriods: Int, periodLength: TimeInterval, substitutionInterval: TimeInterval) {
        self.totalPeriods = totalPeriods
        self.periodLength = Int(periodLength)
        self.substitutionInterval = Int(substitutionInterval)
        self.subRemainingSeconds = self.substitutionInterval
    }
    
    // MARK: - Public controls
    var isGameOver: Bool { currentQuarter >= totalPeriods }
    
    func togglePlayPause() {
        guard !isGameOver else {
            onGameEnd?()
            return
        }
        if isRunning {
            pause()
        } else {
            startOrResume()
        }
    }
    
    func startNextQuarterManually() {
        guard currentQuarter < totalPeriods else { return }
        beginNewPeriod()
    }
    
    /// Optional: Force a sub early or restart countdown from custom remaining
    func restartSubTimer(remaining: TimeInterval) {
        let remainingInt = max(Int(remaining), 0)
        let cyclePosition = substitutionInterval - remainingInt
        lastSubBoundaryAt = clampedElapsed() - cyclePosition
        subRemainingSeconds = remainingInt
        onSubTimerRestarted?()
    }
        
    /// Update the substitution interval without resetting the game clock.
    /// Realigns the sub-countdown to the current elapsed time.
    func updateSubstitutionInterval(_ newInterval: Int) {
        guard newInterval > 0 else { return }
        substitutionInterval = newInterval
        let elapsed = clampedElapsed()
        let timeIntoCycle = elapsed % newInterval
        let remaining = max(newInterval - timeIntoCycle, 0)
        // place last boundary so "sinceLastSub" equals timeIntoCycle
        lastSubBoundaryAt = elapsed - timeIntoCycle
        if subRemainingSeconds != remaining {
            subRemainingSeconds = remaining
            onSubTimerRestarted?()
        }
    }

    
    // MARK: - Private
    private func startOrResume() {
        if currentQuarter == 0 || elapsedSeconds >= periodLength {
            beginNewPeriod()
            return
        }
        isRunning = true
        periodStartAnchor = Date()
        startTickerIfNeeded()
    }
    
    private func pause() {
        // freeze elapsed into pausedAccumulated
        pausedAccumulated = clampedElapsed()
        periodStartAnchor = nil
        isRunning = false
        stopTicker()
    }
    
    private func beginNewPeriod() {
        currentQuarter += 1
        periodStartAnchor = Date()
        pausedAccumulated = 0
        elapsedSeconds = 0
        isRunning = true

        if let carry = carryOverSubRemaining, carry > 0, carry <= substitutionInterval {
            // Set boundary "in the past" so remaining at elapsed=0 is the carried value.
            // sinceLastSub = 0 - lastSubBoundaryAt = substitutionInterval - carry
            // ⇒ remaining = carry
            lastSubBoundaryAt = -(substitutionInterval - carry)
            subRemainingSeconds = carry
        } else {
            // No carry or edge cases; start a fresh cycle
            lastSubBoundaryAt = 0
            subRemainingSeconds = substitutionInterval
        }
        carryOverSubRemaining = nil

        onGameStart?()
        startTickerIfNeeded()
    }

    
    private func clampedElapsed() -> Int {
        let base = pausedAccumulated + (periodStartAnchor.map { Int(Date().timeIntervalSince($0)) } ?? 0)
        return min(max(base, 0), periodLength)
    }
    
    private func startTickerIfNeeded() {
        guard ticker == nil else { return }
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now(), repeating: 1.0, leeway: .milliseconds(100))
        t.setEventHandler { [weak self] in self?.tick() }
        t.resume()
        ticker = t
    }
    
    private func stopTicker() {
        ticker?.cancel()
        ticker = nil
    }
    
    private func tick() {
        guard periodStartAnchor != nil else { return }

        let rawElapsed = clampedElapsed()
        if rawElapsed != elapsedSeconds { elapsedSeconds = rawElapsed }

        let cap = min(rawElapsed, periodLength)

        if substitutionInterval > 0 {
            var advancedCount = 0
            var boundaryCursor = lastSubBoundaryAt

            // Advance through all crossed intervals
            while boundaryCursor + substitutionInterval <= cap {
                boundaryCursor += substitutionInterval
                advancedCount += 1
            }

            // 1) Commit boundary first (if any)
            if advancedCount > 0 {
                lastSubBoundaryAt = boundaryCursor
            }

            // 2) Compute/publish remaining AFTER boundary is updated
            let sinceLastSub = cap - lastSubBoundaryAt
            let newRemaining = max(substitutionInterval - sinceLastSub, 0)
            if newRemaining != subRemainingSeconds {
                subRemainingSeconds = newRemaining
            }

            // 3) NOW fire callbacks, so Live Activity sees the fresh value
            if advancedCount > 0 {
                for _ in 0..<advancedCount { onSubTimerFinish?() }
                onSubTimerRestarted?()
            }
        } else {
            if subRemainingSeconds != 0 { subRemainingSeconds = 0 }
        }

        // Period end after sub handling
        if rawElapsed >= periodLength {
            // Save remaining sub time to carry into the next period
            carryOverSubRemaining = subRemainingSeconds

            elapsedSeconds = periodLength
            periodStartAnchor = nil
            isRunning = false
            stopTicker()
            onGameEnd?()
        }
    }
}
