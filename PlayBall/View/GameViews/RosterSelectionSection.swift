//
//  RosterSelectionSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

struct RosterSelectionSection: View {
    var team: Team
    @Binding var availablePlayers: [Player]
    var addPlayer: (Player) -> Void

    var body: some View {
        GlassCard(
            title: "Roster",
            sfSymbol: "person.3.fill"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                let rosterPlayers = team.players.filter { player in
                    !availablePlayers.contains(where: { $0.id == player.id })
                }

                if rosterPlayers.isEmpty {
                    Text("All players are selected.")
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(rosterPlayers) { player in
                        HStack {
                            Text(player.name)
                                .foregroundStyle(.white)

                            Spacer()

                            Button {
                                addPlayer(player)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(player.tint)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview("Roster Section") {
    @Previewable @State var availablePlayers: [Player] = []

    return RosterSelectionSection(
        team: Coach.previewCoach.teams.first!,
        availablePlayers: $availablePlayers,
        addPlayer: { _ in }
    )
}
