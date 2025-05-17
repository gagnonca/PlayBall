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
    @Published var timerCoordinator: GameTimerCoordinator
    
    let liveActivityHandler = GameLiveActivityHandler()

    init(game: Game, team: Team) {
        self.game = game
        self.team = team

        // Regenerate substitution plan every time the session is created
        let plan = game.buildSubstitutionPlan()

        self.substitutionState = SubstitutionState(plan: plan)
        self.timerCoordinator = GameTimerCoordinator(
            totalPeriods: game.numberOfPeriods.rawValue,
            periodLength: TimeInterval(game.periodLengthMinutes * 60),
            substitutionInterval: plan.subDuration,
            quarterTimerID: "\(game.id)-QuarterTimer",
            subTimerID: "\(game.id)-SubTimer"
        )

        self.timerCoordinator.onSubTimerFinish = { [weak self] in
            self?.substitutionState.advance()
        }
        
        self.timerCoordinator.onGameStart = { [weak self] in
            self?.startLiveActivityIfNeeded()
        }
        
        self.timerCoordinator.onSubTimerRestarted = { [weak self] in
            self?.updateLiveActivity()
        }

        self.timerCoordinator.onGameEnd = { [weak self] in
            self?.endLiveActivity()
        }
    }

    /// Total game time elapsed based on the timer.
    var totalElapsedTime: TimeInterval {
        timerCoordinator.quarterTimer.timerTime.totalSeconds
    }

    /// Convenience accessors to current rotation state.
    var currentPlayers: [Player] { substitutionState.currentPlayers }
    var nextPlayers: [Player] { substitutionState.nextPlayers }
    var benchPlayers: [Player] { substitutionState.benchPlayers }

    /// Advance substitution manually (e.g. for testing or debugging).
    func advanceSubstitution() {
        substitutionState.advance()
    }
}

extension GameSession {
    func cleanup() {
        timerCoordinator.currentQuarter = 0
        try? timerCoordinator.quarterTimer.skip()
        try? timerCoordinator.subTimer.skip()
    }
}

extension GameSession {
    func restartSubTimer() {
        let elapsed = totalElapsedTime
        let cycle = substitutionState.plan.subDuration
        let timeIntoCycle = elapsed.truncatingRemainder(dividingBy: cycle)
        let remaining = max(cycle - timeIntoCycle, 0)
        timerCoordinator.restartSubTimer(remaining: remaining)
    }
}


// MARK: - Live Activity Actions
extension GameSession {
    func startLiveActivityIfNeeded() {
        guard !liveActivityHandler.isActive else { return }
        liveActivityHandler.startLiveActivity(
            currentTime: totalElapsedTime,
            periodLength: timerCoordinator.periodLength,
            currentQuarter: timerCoordinator.currentQuarter,
            nextPlayers: nextPlayers,
            nextSubCountdown: timerCoordinator.subTimer.timerTime.totalSeconds
        )
    }

    func updateLiveActivity() {
        guard liveActivityHandler.isActive else { return }
        liveActivityHandler.updateLiveActivity(
            currentTime: totalElapsedTime,
            periodLength: timerCoordinator.periodLength,
            currentQuarter: timerCoordinator.currentQuarter,
            nextPlayers: nextPlayers,
            nextSubCountdown: timerCoordinator.subTimer.timerTime.totalSeconds
        )
    }

    func endLiveActivity() {
        liveActivityHandler.endLiveActivity(
            currentTime: totalElapsedTime,
            currentQuarter: timerCoordinator.currentQuarter
        )
    }
}
