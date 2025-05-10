import Foundation

struct Player: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

enum SubstitutionStyle {
    case long
    case short
}

class SlidingWindowSubstitutionPlanner {
    let players: [Player]
    let playersOnField: Int
    let periodLengthMinutes: Int
    let numberOfPeriods: Int
    let subGroupSize: Int
    let style: SubstitutionStyle

    init(players: [Player], playersOnField: Int, periodLengthMinutes: Int, numberOfPeriods: Int, subGroupSize: Int, style: SubstitutionStyle) {
        self.players = players
        self.playersOnField = playersOnField
        self.periodLengthMinutes = periodLengthMinutes
        self.numberOfPeriods = numberOfPeriods
        self.subGroupSize = subGroupSize
        self.style = style
    }

    func buildSchedule() -> [(time: String, onField: [Player])] {
        let totalGameMinutes = Double(periodLengthMinutes * numberOfPeriods)
        let totalPlayerMinutes = totalGameMinutes * Double(playersOnField)
        let minutesPerPlayer = totalPlayerMinutes / Double(players.count)

        let segmentDuration: Double = style == .long
            ? minutesPerPlayer / Double(numberOfPeriods)
            : minutesPerPlayer / (Double(numberOfPeriods) * 1.5)

        let totalSegments = Int(round(totalGameMinutes / segmentDuration))

        var results: [(String, [Player])] = []
        var playerIndex = 0

        for segment in 0..<totalSegments {
            var group: [Player] = []
            for i in 0..<playersOnField {
                let index = (playerIndex + i) % players.count
                group.append(players[index])
            }

            let time = segmentDuration * Double(segment)
            let formattedTime = String(format: "%02d:%02d", Int(time), Int((time - floor(time)) * 60))
            results.append((formattedTime, group))

            playerIndex = (playerIndex + subGroupSize) % players.count
        }

        // Optional: print summary of minutes per player
        var playerMinutes: [UUID: Double] = [:]
        players.forEach { playerMinutes[$0.id] = 0 }

        for (_, group) in results {
            for player in group {
                playerMinutes[player.id, default: 0] += segmentDuration
            }
        }

        print("\n=== Total Minutes Per Player ===")
        for player in players {
            let minutes = playerMinutes[player.id] ?? 0
            print("\(player.name): \(String(format: "%.1f", minutes)) min")
        }

        return results
    }
}

// --- Run Example ---
let players = (1...6).map { Player(name: "Player \($0)") }

let planner = SlidingWindowSubstitutionPlanner(
    players: players,
    playersOnField: 4,
    periodLengthMinutes: 10,
    numberOfPeriods: 4,
    subGroupSize: 4,
    style: .long // or .short
)

let schedule = planner.buildSchedule()

for (time, group) in schedule {
    print("⏰ \(time) — On field: \(group.map { $0.name }.joined(separator: ", "))")
}
