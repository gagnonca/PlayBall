//
//  GameLiveActivityHandler.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/5/25.
//


//
//  GameLiveActivityHandler.swift
//  PlayBall
//

import ActivityKit
import SwiftUI

@MainActor
final class GameLiveActivityHandler {
    private var liveActivity: Activity<PlayBallWidgetLiveActivityAttributes>?
    
    var isActive: Bool {
        liveActivity != nil
    }

    func startLiveActivity(currentTime: TimeInterval, currentQuarter: Int, isRunning: Bool, nextPlayers: [Player], nextSubCountdown: TimeInterval?) {
        let attributes = PlayBallWidgetLiveActivityAttributes()

        let livePlayers = nextPlayers.enumerated().map { (index, player) in
            LivePlayer(
                name: player.name,
                tintHex: PlayerPalette.hexCode(for: index)
            )
        }

        let state = PlayBallWidgetLiveActivityAttributes.ContentState(
            currentTime: currentTime,
            quarter: currentQuarter,
            isRunning: isRunning,
            nextPlayers: livePlayers,
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

    func updateLiveActivity(currentTime: TimeInterval, currentQuarter: Int, isRunning: Bool, nextPlayers: [Player], nextSubCountdown: TimeInterval?) {
        let livePlayers = nextPlayers.enumerated().map { (index, player) in
            LivePlayer(
                name: player.name,
                tintHex: PlayerPalette.hexCode(for: index)
            )
        }

        Task {
            let state = PlayBallWidgetLiveActivityAttributes.ContentState(
                currentTime: currentTime,
                quarter: currentQuarter,
                isRunning: isRunning,
                nextPlayers: livePlayers,
                nextSubCountdown: nextSubCountdown
            )

            let content = ActivityContent(state: state, staleDate: nil)
            await liveActivity?.update(content)
        }
    }


    func endLiveActivity(currentTime: TimeInterval, currentQuarter: Int) {
        let state = PlayBallWidgetLiveActivityAttributes.ContentState(
            currentTime: currentTime,
            quarter: currentQuarter,
            isRunning: false,
            nextPlayers: []
        )
        let content = ActivityContent(state: state, staleDate: nil)

        Task {
            await liveActivity?.end(content, dismissalPolicy: .immediate)
            liveActivity = nil
        }
    }
}
