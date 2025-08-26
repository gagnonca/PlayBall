//
//  GameSession.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/14/25.
//

import Foundation
import SwiftUI

/// A live representation of an in-progress game, used to drive GameDayView.
/// Combines game rules, substitution state, and clock control.
@MainActor
final class GameSession: ObservableObject, Identifiable {
    let id = UUID()

    let game: Game
    let team: Team

    @Published var substitutionState: SubstitutionState
    @Published var clockManager: GameClockManager

    let liveActivityHandler = GameLiveActivityHandler()

    init(game: Game, team: Team) {
        self.game = game
        self.team = team

        let plan = game.buildSubstitutionPlan()
        self.substitutionState = SubstitutionState(plan: plan)

        self.clockManager = GameClockManager(
            totalPeriods: game.numberOfPeriods.rawValue,
            periodLength: TimeInterval(game.periodLengthMinutes * 60),
            substitutionInterval: plan.subDuration
        )

        // Wire callbacks
        clockManager.onGameStart = { [weak self] in
            self?.startLiveActivityIfNeeded()
            self?.updateLiveActivity() // push initial state for the period
        }
        clockManager.onSubTimerFinish = { [weak self] in
            self?.substitutionState.advance()
            self?.updateLiveActivity()
        }
        clockManager.onSubTimerRestarted = { [weak self] in
            self?.updateLiveActivity()
        }
        clockManager.onGameEnd = { [weak self] in
            // End of current period – do not auto-start next period
            self?.updateLiveActivity() // final state for the period
        }
    }

    // MARK: - Convenience

    var totalElapsedTime: TimeInterval { TimeInterval(clockManager.elapsedSeconds) }
    var periodLength: TimeInterval { TimeInterval(clockManager.periodLength) }
    var currentQuarter: Int { clockManager.currentQuarter }
    var nextSubCountdown: TimeInterval { TimeInterval(clockManager.subRemainingSeconds) }

    /// Convenience accessors to current rotation state.
    var currentPlayers: [Player] { substitutionState.currentPlayers }
    var nextPlayers: [Player] { substitutionState.nextPlayers }
    var benchPlayers: [Player] { substitutionState.benchPlayers }

    /// Advance substitution manually (e.g. for testing or debugging).
    func advanceSubstitution() {
        substitutionState.advance()
        updateLiveActivity()
    }

    // MARK: - Controls

    func togglePlayPause() {
        clockManager.togglePlayPause()
        updateLiveActivity()
    }

    func startNextQuarter() {
        clockManager.startNextQuarterManually()
        updateLiveActivity()
    }

    /// Restart the sub-countdown based on current elapsed time (forces a fresh cycle).
    func restartSubTimer() {
        let elapsed = totalElapsedTime
        let cycle = substitutionState.plan.subDuration
        let timeIntoCycle = elapsed.truncatingRemainder(dividingBy: cycle)
        let remaining = max(cycle - timeIntoCycle, 0)
        clockManager.restartSubTimer(remaining: remaining)
        updateLiveActivity()
    }

    /// Reset everything for a brand-new game session (same teams/game rules).
    func cleanup() {
        // Recreate plan to reset derived state
        let newPlan = game.buildSubstitutionPlan()
        substitutionState = SubstitutionState(plan: newPlan)

        // Recreate clock so all anchors/tickers are brand new
        clockManager = GameClockManager(
            totalPeriods: game.numberOfPeriods.rawValue,
            periodLength: TimeInterval(game.periodLengthMinutes * 60),
            substitutionInterval: newPlan.subDuration
        )
        clockManager.onGameStart = { [weak self] in self?.startLiveActivityIfNeeded(); self?.updateLiveActivity() }
        clockManager.onSubTimerFinish = { [weak self] in self?.substitutionState.advance(); self?.updateLiveActivity() }
        clockManager.onSubTimerRestarted = { [weak self] in self?.updateLiveActivity() }
        clockManager.onGameEnd = { [weak self] in self?.updateLiveActivity() }

        endLiveActivity()
    }
}

// MARK: - Live Activity plumbing
extension GameSession {
    func startLiveActivityIfNeeded() {
        guard !liveActivityHandler.isActive else { return }
        liveActivityHandler.startLiveActivity(
            currentTime: totalElapsedTime,
            periodLength: periodLength,
            currentQuarter: currentQuarter,
            nextPlayers: nextPlayers,
            nextSubCountdown: nextSubCountdown
        )
    }

    func updateLiveActivity() {
        guard liveActivityHandler.isActive else { return }
        liveActivityHandler.updateLiveActivity(
            currentTime: totalElapsedTime,
            periodLength: periodLength,
            currentQuarter: currentQuarter,
            nextPlayers: nextPlayers,
            nextSubCountdown: nextSubCountdown
        )
    }

    func endLiveActivity() {
        liveActivityHandler.endLiveActivity(
            currentTime: totalElapsedTime,
            currentQuarter: currentQuarter
        )
    }
}
