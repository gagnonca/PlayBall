//
//  Game+Substitutions.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/10/25.
//

import Foundation

enum PeriodStyle: Int, Codable, Hashable {
    case quarter = 4
    case half = 2
}

enum SubstitutionStyle: String, Codable {
    case long
    case short
}

extension Game {
    func buildSubstitutionPlan() -> SubstitutionPlan {
        let players = availablePlayers
        guard !players.isEmpty else {
            return SubstitutionPlan(subDuration: 0, segments: [], availablePlayers: [])
        }
        
        if players.count <= playersOnField {
            return SubstitutionPlan(
                subDuration: Double(periodLengthMinutes * numberOfPeriods.rawValue * 60),
                segments: [SubSegment(players: players)],
                availablePlayers: players
            )
        }
        
        let totalGameSeconds = Double(self.numberOfPeriods.rawValue * periodLengthMinutes * 60)
        
        // Calculate total segments as a multiple of player count to preserve fairness
        let rotationsPerPlayer = substitutionStyle == .short ? 2 : 1
        let totalSegments = players.count * rotationsPerPlayer
        let segmentLengthSeconds = totalGameSeconds / Double(totalSegments)
        
        var segments: [SubSegment] = []
        var index = 0
        
        for _ in 0..<totalSegments {
            let group = (0..<playersOnField).map { offset in
                players[(index + offset) % players.count]
            }
            segments.append(SubSegment(players: group))
            index = (index + playersOnField) % players.count
        }
        
        return SubstitutionPlan(subDuration: segmentLengthSeconds, segments: segments, availablePlayers: players)
    }
}
