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

        let numberOfPeriods = self.numberOfPeriods.rawValue
        let totalGameMinutes = Double(periodLengthMinutes * numberOfPeriods)
        let totalPlayerMinutes = totalGameMinutes * Double(playersOnField)
        let minutesPerPlayer = totalPlayerMinutes / Double(players.count)

        let baseSegmentLength = minutesPerPlayer / Double(numberOfPeriods)
        let segmentLength = substitutionStyle == .short ? baseSegmentLength / 1.5 : baseSegmentLength
        let segmentLengthSeconds = segmentLength * 60

        let totalSegments = Int(round(totalGameMinutes * 60 / segmentLengthSeconds))

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
