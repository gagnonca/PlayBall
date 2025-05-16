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
    
//    @Published var substitutionState: SubstitutionState
    @Published var substitutionPlan: SubstitutionPlan
    @Published var timerCoordinator: GameTimerCoordinator
//    @Published var lastSubIndex: Int = 0
    @Published var currentSubIndex: Int = 0
    @Published var currentElapsedTime: TimeInterval = 0

    
    init(game: Game, team: Team) {
        self.game = game
        self.team = team
        
        // Regenerate substitution plan every time the session is created
//        self.gameStartDate = Date()
        self.substitutionPlan = game.buildSubstitutionPlan()
//        self.substitutionState = SubstitutionState(plan: plan, gameStartDate: gameStartDate)
        
        self.timerCoordinator = GameTimerCoordinator(
            totalPeriods: game.numberOfPeriods.rawValue,
            periodLength: TimeInterval(game.periodLengthMinutes * 60),
            quarterTimerID: "\(game.id)-QuarterTimer",
//            subTimerID: "\(game.id)-SubTimer"
        )
        
        //        self.timerCoordinator.onSubTimerFinish = { [weak self] in
        //            self?.substitutionState.advance()
        //        }
    }
}

extension GameSession {
    /// Total game time elapsed based on the timer.
//    var totalElapsedTime: TimeInterval {
//        timerCoordinator.elapsedTime
//    }
    var totalElapsedTime: TimeInterval {
        currentElapsedTime
    }

//    var nextSubstitutionCountdown: TimeInterval? {
//        guard let segment = currentSegment else { return nil }
//        return max(segment.offTime - totalElapsedTime, 0)
//    }
    var nextSubstitutionCountdown: TimeInterval? {
        guard let off = currentSegment?.offTime else { return nil }
        return max(off - timerCoordinator.elapsedTime, 0)
    }

    static var nowElapsed: TimeInterval {
        Date().timeIntervalSinceReferenceDate
    }
}

extension GameSession {
    func updateSubstitutionState(elapsed: TimeInterval) {
        if let index = substitutionPlan.segments.firstIndex(where: { elapsed >= $0.onTime && elapsed < $0.offTime }),
           index != currentSubIndex {
            currentSubIndex = index
        }
    }
}

extension GameSession {
    var currentSegment: SubSegment? {
        substitutionPlan.segment(at: totalElapsedTime)
    }

    var currentPlayers: [Player] {
        currentSegment?.players ?? []
    }

    var nextPlayers: [Player] {
        guard let current = currentSegment,
              let i = substitutionPlan.segments.firstIndex(of: current),
              i + 1 < substitutionPlan.segments.count
        else { return [] }

        return substitutionPlan.segments[i + 1].players
    }

    var benchPlayers: [Player] {
        let active = Set(currentPlayers + nextPlayers)
        return substitutionPlan.availablePlayers.filter { !active.contains($0) }
    }
}

extension GameSession {
    func cleanup() {
        timerCoordinator.currentQuarter = 0
        try? timerCoordinator.quarterTimer.skip()
    }
}

extension GameSession {
    func update(from game: Game) {
        self.substitutionPlan = game.buildSubstitutionPlan()
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
            nextSubCountdown: nextSubstitutionCountdown
        )
    }

    func updateLiveActivity() {
        guard liveActivityHandler.isActive else { return }
        liveActivityHandler.updateLiveActivity(
            currentTime: totalElapsedTime,
            periodLength: timerCoordinator.periodLength,
            currentQuarter: timerCoordinator.currentQuarter,
            nextPlayers: nextPlayers,
            nextSubCountdown: nextSubstitutionCountdown
        )
    }

    func endLiveActivity() {
        liveActivityHandler.endLiveActivity(
            currentTime: totalElapsedTime,
            currentQuarter: timerCoordinator.currentQuarter
        )
    }
}
