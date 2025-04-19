//
//  Game.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import Foundation

struct Game: Identifiable, Hashable {
    let id = UUID()
    var name: String        // name of the game (e.g. Game 1)
    var date: Date          // date of the game
    var availablePlayers: [Player]  // players who were available for the game
}

extension Game {
    func buildSegments(gameLength: TimeInterval = 40 * 60, onField: Int = 4) -> [SubSegment] {
        let players = availablePlayers
        guard !players.isEmpty else { return [] }

        let segmentLength = gameLength / Double(players.count)
        var segments: [SubSegment] = []
        var start: TimeInterval = 0
        var rotationIndex = 0

        while start < gameLength - 0.5 {
            let end = min(start + segmentLength, gameLength)
            let group = (0..<onField).map {
                players[(rotationIndex + $0) % players.count]
            }
            segments.append(SubSegment(on: start, off: end, players: group))
            start = end
            rotationIndex = (rotationIndex + onField) % players.count
        }

        return segments
    }
}

