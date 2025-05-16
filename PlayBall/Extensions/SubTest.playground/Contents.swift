import Foundation
import SwiftUI

// Mock Game + Player setup for Playground testing
struct Player: Hashable, Identifiable {
    let id = UUID()
    let name: String
}

enum NumberOfPeriods: Int {
    case four = 4
}

enum SubstitutionStyle {
    case long, short
}

struct SubSegment {
    let players: [Player]
}

struct SubstitutionPlan {
    let subDuration: TimeInterval
    let segments: [SubSegment]
    let availablePlayers: [Player]

    func timeString(forSegment index: Int) -> String {
        let seconds = Double(index) * subDuration
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? "0:00"
    }

    func totalPlayTimePerPlayer() -> [Player: TimeInterval] {
        var playtime: [Player: TimeInterval] = [:]
        for segment in segments {
            for player in segment.players {
                playtime[player, default: 0] += subDuration
            }
        }
        return playtime
    }
}

func buildSubstitutionPlan() -> SubstitutionPlan {
    let numberOfPeriods = 4
    let periodLengthMinutes = 10
    let playersOnField = 4
    let substitutionStyle: SubstitutionStyle = .short

    let numberOfPlayers = 9
    let players = (1...numberOfPlayers).map { Player(name: "Player \($0)") }

    let totalGameSeconds = Double(numberOfPeriods * periodLengthMinutes * 60)

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

// MARK: - Playground Test
let players = (1...9).map { Player(name: "Player \($0)") }
//let game = Game(availablePlayers: players)
let plan = buildSubstitutionPlan()

print("Sub Duration: \(plan.subDuration) seconds")
print("Segment count: \(plan.segments.count)")
//print("Expected Game Length: \(Double(game.periodLengthMinutes * game.numberOfPeriods.rawValue)) min")
print("Actual Game Length: \((plan.subDuration * Double(plan.segments.count)) / 60) min")

for i in 0..<plan.segments.count {
    print("Segment \(i): \(plan.timeString(forSegment: i))")
}

print("\n--- Sub Plan ---")

for i in 0..<plan.segments.count {
    let segmentTime = plan.timeString(forSegment: i)
    let playersOnField = plan.segments[i].players.map { $0.name }.joined(separator: ", ")
    print("Segment \(i): \(segmentTime) — On Field: \(playersOnField)")
}


print("\n--- Player Playtime ---")
for (player, seconds) in plan.totalPlayTimePerPlayer().sorted(by: { $0.key.name < $1.key.name }) {
    let minutes = Int(seconds) / 60
    let remSeconds = Int(seconds) % 60
    print("\(player.name): \(String(format: "%d:%02d", minutes, remSeconds))")
}
