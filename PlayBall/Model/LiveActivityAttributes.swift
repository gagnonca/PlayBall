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
        var quarter: Int
        var isRunning: Bool
        var nextPlayers: [LivePlayer]
        var nextSubCountdown: TimeInterval?
    }
    var gameName: String
}

struct LivePlayer: Codable, Hashable {
    let name: String
    let tintHex: String
}
