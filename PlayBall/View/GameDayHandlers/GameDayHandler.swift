//
//  GameDayHandler.swift
//  PlayBall
//

import SwiftUI

@MainActor
final class GameDayHandler: ObservableObject {
    @Published var timeHandler = GameTimeHandler()
    @Published var segmentsHandler = GameSegmentsHandler()
    let liveActivityHandler = GameLiveActivityHandler()
    
    let team: Team
    let game: Game
    
    init(game: Game, team: Team) {
        self.game = game
        self.team = team
        
        timeHandler.onTick = { [weak self] in
            guard let self = self else { return }
            if self.timeHandler.clockState == .running {
                self.updateLiveActivity()
            }
        }

        configure()
    }
    
    private func configure() {
        segmentsHandler.configure(
            gameName: game.name,
            availablePlayers: game.availablePlayers
        )
        segmentsHandler.updateSegments(game.buildSegments())
    }
    
    func refreshSegments() {
        segmentsHandler.updateSegments(game.buildSegments())
    }
    
    var totalElapsedTime: TimeInterval {
        (Double(timeHandler.currentQuarter - 1) * 600) + timeHandler.elapsedTime
    }
}

// MARK: - Live Activity Actions
extension GameDayHandler {
    func startLiveActivityIfNeeded() {
        guard !liveActivityHandler.isActive else { return }
        liveActivityHandler.startLiveActivity(
            currentTime: timeHandler.elapsedTime,
            currentQuarter: timeHandler.currentQuarter,
            isRunning: timeHandler.clockState == .running,
            nextPlayers: segmentsHandler.nextPlayers(totalElapsedTime: totalElapsedTime),
            nextSubCountdown: segmentsHandler.nextSubCountdown(totalElapsedTime: totalElapsedTime)
        )
    }

    func updateLiveActivity() {
        guard liveActivityHandler.isActive else { return }
        liveActivityHandler.updateLiveActivity(
            currentTime: timeHandler.elapsedTime,
            currentQuarter: timeHandler.currentQuarter,
            isRunning: timeHandler.clockState == .running,
            nextPlayers: segmentsHandler.nextPlayers(totalElapsedTime: totalElapsedTime),
            nextSubCountdown: segmentsHandler.nextSubCountdown(totalElapsedTime: totalElapsedTime)
        )
    }

    func endLiveActivity() {
        liveActivityHandler.endLiveActivity(
            currentTime: timeHandler.elapsedTime,
            currentQuarter: timeHandler.currentQuarter
        )
    }
}
