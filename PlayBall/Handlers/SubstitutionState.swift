//
//  SubstitutionState.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/14/25.
//


import Foundation

/// Manages dynamic substitution state during a live game using a static SubstitutionPlan.
@MainActor
final class SubstitutionState: ObservableObject {
    @Published var currentIndex: Int = 0 {
        didSet { updateDerivedPlayers() }
    }

    @Published private(set) var currentPlayers: [Player] = []
    @Published private(set) var nextPlayers: [Player] = []
    @Published private(set) var benchPlayers: [Player] = []

    let plan: SubstitutionPlan

    init(plan: SubstitutionPlan) {
        self.plan = plan
        updateDerivedPlayers()
    }

    /// Advances to the next substitution segment if not already at the end.
    func advance() {
        if currentIndex + 1 < plan.segments.count {
            currentIndex += 1
        }
    }

    /// Returns true if the current segment is the final one in the plan.
    var isFinalSegment: Bool {
        currentIndex + 1 == plan.segments.count
    }

    /// Updates the published player groups based on the current index.
    private func updateDerivedPlayers() {
        currentPlayers = plan.segments[safe: currentIndex]?.players ?? []
        nextPlayers = plan.segments[safe: currentIndex + 1]?.players ?? []
        let active = Set(currentPlayers + nextPlayers)
        benchPlayers = plan.availablePlayers.filter { !active.contains($0) }
    }
}

// MARK: - Safe Array Access Extension
private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}