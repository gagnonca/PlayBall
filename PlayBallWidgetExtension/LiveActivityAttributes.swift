//
//  LiveActivityAttributes.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/30/25.
//

import ActivityKit
import Foundation

struct PlayBallWidgetLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentTime: TimeInterval
        var periodLength: TimeInterval
        var quarter: Int
        var nextPlayers: [Player]
        var nextSubCountdown: TimeInterval?
    }
}

extension PlayBallWidgetLiveActivityAttributes {
    static var preview: PlayBallWidgetLiveActivityAttributes {
        PlayBallWidgetLiveActivityAttributes()
    }
}
