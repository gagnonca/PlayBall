//
//  GameOverviewView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/29/25.
//

import SwiftUI

struct GameOverviewView: View {
    let plan: SubstitutionPlan
    private var segments: [SubSegment] { plan.segments }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Substitution Plan").bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                }
                .background(Color.green.opacity(0.25))

                // Each segment row
                ForEach(Array(segments.enumerated()), id: \..offset) { index, segment in
                    HStack(spacing: 8) {
                        FlowLayout(items: segment.players, spacing: 8) { player in
                            PlayerPill(name: player.name, tint: player.tint)
                        }
                        
                        Text(plan.timeString(forSegment: index + 1))
                            .foregroundStyle(.secondary)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.15))
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
