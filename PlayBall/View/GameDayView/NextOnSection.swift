//
//  NextOnSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//


import SwiftUI

struct NextOnSection: View {
    var nextPlayers: [Player]
    var nextSubRelativeFormatted: String

    var body: some View {
        GlassCard(title: "Next On", sfSymbol: "arrow.right.circle") {
            VStack(alignment: .leading, spacing: 8) {
                if nextPlayers.isEmpty {
                    Text("No more substitutions")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Next Sub In: \(nextSubRelativeFormatted)")
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)

                    FlowLayout(items: nextPlayers, spacing: 8) { player in
                        PlayerBadge(player: player)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 64/255, green: 160/255, blue: 43/255),
                Color(red: 136/255, green: 57/255, blue: 239/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 32) {
                NextOnSection(
                    nextPlayers: [
                        Player(name: "Addy", tint: .red),
                        Player(name: "Haley", tint: .orange),
                        Player(name: "Eliza", tint: .yellow),
                        Player(name: "Brooke", tint: .green),
                    ],
                    nextSubRelativeFormatted: "8:30"
                )

                NextOnSection(
                    nextPlayers: [],
                    nextSubRelativeFormatted: "End"
                )
            }
            .padding(.top, 40)
        }
    }
}
