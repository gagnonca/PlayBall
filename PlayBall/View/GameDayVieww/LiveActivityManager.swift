//
//  LiveActivityManager.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/1/25.
//

import Foundation
import ActivityKit

class LiveActivityManager {
    private var liveActivity: Activity<PlayBallWidgetLiveActivityAttributes>?

    func startLiveActivity(gameName: String, currentTime: TimeInterval, currentQuarter: Int, isRunning: Bool, nextPlayers: [Player], nextSubCountdown: TimeInterval?) {
        let attributes = PlayBallWidgetLiveActivityAttributes(gameName: gameName)

        let state = PlayBallWidgetLiveActivityAttributes.ContentState(
            currentTime: currentTime,
            quarter: currentQuarter,
            isRunning: isRunning,
            nextPlayers: nextPlayers.map { LivePlayer(name: $0.name, tintHex: "8839ef") },
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
        let state = PlayBallWidgetLiveActivityAttributes.ContentState(
            currentTime: currentTime,
            quarter: currentQuarter,
            isRunning: isRunning,
            nextPlayers: nextPlayers.map { LivePlayer(name: $0.name, tintHex: "8839ef") },
            nextSubCountdown: nextSubCountdown
        )

        Task {
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
