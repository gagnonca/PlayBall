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
    let liveActivityHandler = GameLiveActivityHandler()

    @Published var substitutionState: SubstitutionState
    @Published var timerCoordinator: GameTimerCoordinator

    init(game: Game, team: Team) {
        self.game = game
        self.team = team

        // Regenerate substitution plan every time the session is created
        let plan = game.buildSubstitutionPlan()

        self.substitutionState = SubstitutionState(plan: plan)
        self.timerCoordinator = GameTimerCoordinator(
            totalPeriods: game.numberOfPeriods.rawValue,
            periodLength: TimeInterval(game.periodLengthMinutes * 60),
            substitutionInterval: plan.subDuration
        )

        self.timerCoordinator.onSubTimerFinish = { [weak self] in
            self?.substitutionState.advance()
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
        timerCoordinator.quarterTimer.cancel()
        timerCoordinator.subTimer.cancel()
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
