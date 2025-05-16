//
//  Game+Substitutions.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/10/25.
//

import Foundation

enum PeriodStyle: Int, Codable, CaseIterable {
    case quarter = 4
    case half = 2
    
    var displayName: String {
        switch self {
        case .quarter: "Quarter"
        case .half: "Half"
        }
    }
}

enum SubstitutionStyle: String, Codable, CaseIterable {
    case long
    case short

    var displayName: String {
        switch self {
        case .long: "Long"
        case .short: "Short"
        }
    }
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
