//
//  SubstitutionPlan.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/14/25.
//

import Foundation

struct SubSegment: Identifiable, Codable, Hashable {
    let id: UUID
    let players: [Player]

    init(id: UUID = UUID(), players: [Player]) {
        self.id = id
        self.players = players
    }
}

struct SubstitutionPlan: Codable, Hashable {
    let subDuration: TimeInterval
    let segments: [SubSegment]
    let availablePlayers: [Player]

    init(subDuration: TimeInterval, segments: [SubSegment], availablePlayers: [Player]) {
        self.subDuration = subDuration
        self.segments = segments
        self.availablePlayers = availablePlayers
    }
}
