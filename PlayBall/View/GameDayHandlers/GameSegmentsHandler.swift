//
//  GameSegmentsHandler.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/5/25.
//


//
//  GameSegmentsHandler.swift
//  PlayBall
//

import SwiftUI

@MainActor
final class GameSegmentsHandler: ObservableObject {
    @Published var segments: [SubSegment] = []
    private var availablePlayers: [Player] = []
    private var gameName: String = ""

    func configure(gameName: String, availablePlayers: [Player]) {
        self.gameName = gameName
        self.availablePlayers = availablePlayers
    }

    func updateSegments(_ newSegments: [SubSegment]) {
        self.segments = newSegments
    }

    func currentPlayers(totalElapsedTime: TimeInterval) -> [Player] {
        segments.last(where: { totalElapsedTime >= $0.on && totalElapsedTime < $0.off })?.players ?? []
    }

    func nextPlayers(totalElapsedTime: TimeInterval) -> [Player] {
        segments.first(where: { $0.on > totalElapsedTime })?.players ?? []
    }

    func benchPlayers(current: [Player], next: [Player]) -> [Player] {
        availablePlayers.filter { !current.contains($0) && !next.contains($0) }
    }

    func nextSubTime(totalElapsedTime: TimeInterval) -> TimeInterval? {
        segments.first(where: { $0.on > totalElapsedTime })?.on
    }
    
    func nextSubCountdown(totalElapsedTime: TimeInterval) -> TimeInterval? {
        guard let nextOn = segments.first(where: { $0.on > totalElapsedTime })?.on else { return nil }
        return nextOn - totalElapsedTime
    }

    func lastSubTime(totalElapsedTime: TimeInterval) -> TimeInterval? {
        segments.last(where: { $0.on < totalElapsedTime })?.on
    }
}
