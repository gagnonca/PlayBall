//
//  AvailablePlayersSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//


import SwiftUI

struct AvailablePlayersSection: View {
    @Binding var availablePlayers: [Player]
    var removePlayer: (Player) -> Void

    var body: some View {
        GlassCard(
            title: "Available Players",
            sfSymbol: "person.crop.circle.badge.checkmark"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                if availablePlayers.isEmpty {
                    Text("No players selected yet.")
                        .foregroundStyle(.white.opacity(0.7))
                } else {
                    ForEach(Array(availablePlayers.enumerated()), id: \.element.id) { index, player in
                        HStack {
                            Text("\(index + 1). \(player.name)")
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                removePlayer(player)
                            } label: {
                                Image(.remove)
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
    }
}

#Preview("Available Players Section") {
    @Previewable @State var availablePlayers = Array(Coach.previewCoach.teams.first!.players.prefix(5))

    return AvailablePlayersSection(
        availablePlayers: $availablePlayers,
        removePlayer: { _ in }
    )
}
