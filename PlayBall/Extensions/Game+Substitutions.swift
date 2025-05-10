//
//  Game+Substitutions.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/10/25.
//

import Foundation

enum SubstitutionStyle {
    case long
    case short
}

extension Game {
    func buildSegments(style: SubstitutionStyle = .short, onField: Int = 4, periodLengthMinutes: Int = 10, numberOfPeriods: Int = 4) -> [SubSegment] {
        let players = availablePlayers
        guard !players.isEmpty else { return [] }

        let totalGameMinutes = Double(periodLengthMinutes * numberOfPeriods)
        let totalPlayerMinutes = totalGameMinutes * Double(onField)
        let minutesPerPlayer = totalPlayerMinutes / Double(players.count)

        let baseSegmentLength = minutesPerPlayer / Double(numberOfPeriods)
        let segmentLength = style == .short ? baseSegmentLength / 1.5 : baseSegmentLength
        let totalSegments = Int(round(totalGameMinutes / segmentLength))

        var segments: [SubSegment] = []
        var time: TimeInterval = 0
        var index = 0

        for _ in 0..<totalSegments {
            let group = (0..<onField).map { offset in
                players[(index + offset) % players.count]
            }

            let endTime = time + segmentLength * 60
            segments.append(SubSegment(on: time, off: endTime, players: group))

            time = endTime
            index = (index + onField) % players.count
        }

        return segments
    }
}

