//
//  BenchSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/29/25.
//

import SwiftUI

struct BenchSection: View {
    let players: [Player]

    var body: some View {
        GlassCard(title: "Bench", sfSymbol: "chair.lounge") {
            VStack {
                if players.isEmpty {
                    Text("No players on bench")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    FlowLayout(items: players, spacing: 8) { player in
                        PlayerBadge(player: player)
                    }
                }
            }
        }
    }
}

#Preview {
    let players: [Player] = Array(Coach.previewCoach.teams.first!.players[0..<2])
    VStack {
        BenchSection(players: players)
        BenchSection(players: [])
    }
}
