//
//  GameLiveActivityHandler.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/5/25.
//


import ActivityKit
import SwiftUI

@MainActor
final class GameLiveActivityHandler {
    private var liveActivity: Activity<PlayBallWidgetLiveActivityAttributes>?
    
    var isActive: Bool {
        liveActivity != nil
    }

    func startLiveActivity(currentTime: TimeInterval, periodLength: TimeInterval, currentQuarter: Int, nextPlayers: [Player], nextSubCountdown: TimeInterval?) {
        let attributes = PlayBallWidgetLiveActivityAttributes()

        let players = nextPlayers.enumerated().map { (index, player) in
            Player(
                name: player.name,
                tintHex: PlayerPalette.hexCode(for: index)
            )
        }

        let state = PlayBallWidgetLiveActivityAttributes.ContentState(
            currentTime: currentTime,
            periodLength: periodLength,
            quarter: currentQuarter,
            nextPlayers: players,
            nextSubCountdown: nextSubCountdown
        )

        let content = ActivityContent(state: state, staleDate: nil)

        do {
            liveActivity = try Activity<PlayBallWidgetLiveActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
        }
    }

    func updateLiveActivity(currentTime: TimeInterval, periodLength: TimeInterval, currentQuarter: Int, nextPlayers: [Player], nextSubCountdown: TimeInterval?) {
        let players = nextPlayers.enumerated().map { (index, player) in
            Player(
                name: player.name,
                tintHex: PlayerPalette.hexCode(for: index)
            )
        }

        Task {
            let state = PlayBallWidgetLiveActivityAttributes.ContentState(
                currentTime: currentTime,
                periodLength: periodLength,
                quarter: currentQuarter,
                nextPlayers: players,
                nextSubCountdown: nextSubCountdown
            )

            let content = ActivityContent(state: state, staleDate: nil)
            await liveActivity?.update(content)
        }
    }


    func endLiveActivity(currentTime: TimeInterval, currentQuarter: Int) {
        let state = PlayBallWidgetLiveActivityAttributes.ContentState(
            currentTime: currentTime,
            periodLength: currentTime,
            quarter: currentQuarter,
            nextPlayers: []
        )
        let content = ActivityContent(state: state, staleDate: nil)

        Task {
            await liveActivity?.end(content, dismissalPolicy: .immediate)
            liveActivity = nil
        }
    }
}
