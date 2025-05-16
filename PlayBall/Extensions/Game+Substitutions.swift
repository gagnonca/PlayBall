//
//  Game+Substitutions.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/10/25.
//

import Foundation

extension Game {
    func buildSubstitutionPlan() -> SubstitutionPlan {
        let players = availablePlayers
        guard !players.isEmpty else {
            return SubstitutionPlan(subDuration: 0, segments: [], availablePlayers: [])
        }
        
        if players.count <= playersOnField {
            let fullGameDuration = Double(periodLengthMinutes * numberOfPeriods.rawValue * 60)
            let segment = SubSegment(
                players: players,
                onTime: 0,
                offTime: fullGameDuration
            )
            return SubstitutionPlan(subDuration: fullGameDuration, segments: [segment], availablePlayers: players)
        }
        
        let totalGameSeconds = Double(self.numberOfPeriods.rawValue * periodLengthMinutes * 60)
        
        // Calculate total segments as a multiple of player count to preserve fairness
        let rotationsPerPlayer = substitutionStyle == .short ? 2 : 1
        let totalSegments = players.count * rotationsPerPlayer
        let segmentLengthSeconds = totalGameSeconds / Double(totalSegments)
        
        var segments: [SubSegment] = []
        var index = 0
        
        for i in 0..<totalSegments {
            let group = (0..<playersOnField).map { offset in
                players[(index + offset) % players.count]
            }
            
            let onTime = Double(i) * segmentLengthSeconds
            let offTime = onTime + segmentLengthSeconds

            segments.append(SubSegment(players: group, onTime: onTime, offTime: offTime))
            index = (index + playersOnField) % players.count
        }
        
        return SubstitutionPlan(subDuration: segmentLengthSeconds, segments: segments, availablePlayers: players)
    }
}
