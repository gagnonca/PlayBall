//
//  GameOverviewView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/29/25.
//

import SwiftUI

private struct QuarterSegment: Identifiable {
    let id = UUID()
    let quarter: Int
    let players: [Player]
    let startInQuarter: Int // seconds relative to quarter start
    let endInQuarter: Int   // seconds relative to quarter start
}

private extension SubstitutionPlan {
    /// Returns the total number of quarters/periods if available from context. Defaults to 4.
    var totalQuarters: Int { 4 }
}

private extension GameOverviewView {
    /// Build per-quarter segments by splitting plan segments at quarter boundaries
    func buildQuarterSegments() -> [Int: [QuarterSegment]] {
        var result: [Int: [QuarterSegment]] = [:]

        // Determine quarter length (in seconds)
        let inferredQuarterLength: Int = {
            // Try to read from the plan via reflection
            let m = Mirror(reflecting: plan)
            for c in m.children {
                if c.label == "periodLength" || c.label == "quarterLength" { if let v = c.value as? Int { return v } }
                if c.label == "periodLengthMinutes" { if let v = c.value as? Int { return v * 60 } }
            }
            // Fallback to 10 minutes per quarter if not present in plan
            return 10 * 60
        }()

        let subLen = max(1, Int(plan.subDuration))

        for (idx, seg) in plan.segments.enumerated() {
            let globalStart = idx * subLen
            let globalEnd = (idx + 1) * subLen
            guard globalEnd > globalStart else { continue }

            var cursor = globalStart
            while cursor < globalEnd {
                let quarterIndex = cursor / inferredQuarterLength // 0-based
                let qStart = quarterIndex * inferredQuarterLength
                let qEnd = qStart + inferredQuarterLength

                let sliceStartGlobal = cursor
                let sliceEndGlobal = min(globalEnd, qEnd)

                let startInQuarter = sliceStartGlobal - qStart
                let endInQuarter = sliceEndGlobal - qStart

                let q = quarterIndex + 1
                let piece = QuarterSegment(
                    quarter: q,
                    players: seg.players,
                    startInQuarter: startInQuarter,
                    endInQuarter: endInQuarter
                )
                result[q, default: []].append(piece)

                cursor = sliceEndGlobal
            }
        }

        // Sort segments within each quarter by start time
        for q in result.keys {
            result[q]?.sort { $0.startInQuarter < $1.startInQuarter }
        }

        return result
    }

    func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

struct GameOverviewView: View {
    let plan: SubstitutionPlan
    // Removed old segments property

    @Environment(\.teamTheme) private var theme

    var body: some View {
        let home = theme.end

        ScrollView {
            let quarterGroups = buildQuarterSegments()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Substitution Plan").bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                }
                .background(home.opacity(0.15))

                ForEach(Array(quarterGroups.keys).sorted(), id: \.self) { quarter in
                    // Quarter header
                    HStack {
                        Text("Q\(quarter)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                    }
                    .background(home.opacity(0.2))

                    // Segments within quarter, show quarter-relative time
                    ForEach(Array(quarterGroups[quarter]!.enumerated()), id: \.offset) { idx, seg in
                        HStack(spacing: 8) {
                            FlowLayout(items: seg.players, spacing: 8) { player in
                                PlayerPill(name: player.name, tint: player.tint)
                            }
                            Text("\(timeString(seg.startInQuarter))-\(timeString(seg.endInQuarter))")
                                .foregroundStyle(.secondary)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(
                            idx.isMultiple(of: 2)
                                ? home.opacity(0.25)
                                : home.opacity(0.30)
                        )
                    }
                }
            }
        }
    }
}

extension SubstitutionPlan {
    /// Converts a segment index to a readable timestamp string based on the subDuration.
    func timeString(forSegment index: Int) -> String {
        let totalSeconds = Int((Double(index) * subDuration).rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    let plan = Coach.previewCoach.games[1].buildSubstitutionPlan()
    GameOverviewView(plan:plan)
}
