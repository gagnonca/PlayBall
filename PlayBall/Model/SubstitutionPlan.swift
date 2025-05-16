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
    let onTime: TimeInterval
    let offTime: TimeInterval

    init(id: UUID = UUID(), players: [Player], onTime: TimeInterval, offTime: TimeInterval) {
        self.id = id
        self.players = players
        self.onTime = onTime
        self.offTime = offTime
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

extension SubstitutionPlan {
    /// Returns the segment that should be active at a given time (in seconds since game start).
    func segment(at time: TimeInterval) -> SubSegment? {
        segments.first { time >= $0.onTime && time < $0.offTime }
    }

    /// Optionally returns the next segment after the one active at `time`.
    func nextSegment(after time: TimeInterval) -> SubSegment? {
        guard let current = segment(at: time),
              let currentIndex = segments.firstIndex(of: current),
              currentIndex + 1 < segments.count else {
            return nil
        }
        return segments[currentIndex + 1]
    }
}
