//
//  SubstitutionState.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/14/25.
//


import Foundation

@MainActor
final class SubstitutionState: ObservableObject {
    @Published var currentIndex: Int = 0
    let plan: SubstitutionPlan
    let gameStartDate: Date
    
    init(plan: SubstitutionPlan, gameStartDate: Date) {
        self.plan = plan
        self.gameStartDate = gameStartDate
    }
}

// MARK: - Segment Access
extension SubstitutionState {
    var currentSegment: SubSegment? {
        plan.segments[safe: currentIndex]
    }
    
    var nextSegment: SubSegment? {
        guard currentIndex + 1 < plan.segments.count else { return nil }
        return plan.segments[currentIndex + 1]
    }
}

// MARK: - Player Access
extension SubstitutionState {
    var currentPlayers: [Player] {
        currentSegment?.players ?? []
    }
    
    var nextPlayers: [Player] {
        nextSegment?.players ?? []
    }
    
    var benchPlayers: [Player] {
        let active = Set(currentPlayers + nextPlayers)
        return plan.availablePlayers.filter { !active.contains($0) }
    }
}

// MARK: - Countdown Support
extension SubstitutionState {
    var currentSegmentEndDate: Date? {
        guard let segment = currentSegment else { return nil }
        return gameStartDate.addingTimeInterval(segment.offTime)
    }
}
 
// MARK: - Time Sync
extension SubstitutionState {
    func update(to time: TimeInterval) {
        if let index = plan.segments.firstIndex(where: { time >= $0.onTime && time < $0.offTime }),
           index != currentIndex {
            currentIndex = index
        }
    }
}

// MARK: - Safe Array Access
private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
