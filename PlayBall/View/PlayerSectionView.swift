//
//  PlayerSectionView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//


import SwiftUI

struct PlayerSectionView: View {
    @Bindable var team: Team
    @Binding var editMode: EditMode

    var body: some View {
        Section("Players") {
            ForEach($team.players) { $player in
                let field = TextField("Player Name", text: $player.name)
                    .foregroundStyle(player.tint)
                    .disabled(!editMode.isEditing)

                if editMode == .active {
                    field.textFieldStyle(.roundedBorder)
                } else {
                    field.textFieldStyle(.plain)
                }
            }
            .onDelete { offsets in
                team.players.remove(atOffsets: offsets)
            }

            if editMode == .active {
                Button {
                    let tint = PlayerPalette.color(for: team.players.count)
                    team.players.append(Player(name: "", tint: tint))
                } label: {
                    Label("Add Player", systemImage: "plus.circle")
                }
            }
        }
    }
}

#Preview {
    struct PlayerSectionPreviewWrapper: View {
        @State private var editMode: EditMode = .inactive

        var body: some View {
            let players = [
                Player(name: "Brooke", tint: .green),
                Player(name: "Alana", tint: .orange),
                Player(name: "Addy", tint: .red),
                Player(name: "Haley", tint: .pink),
                Player(name: "Eliza", tint: .purple),
                Player(name: "Elaina", tint: .cyan)            ]

            let team = Team(name: "Preview Team", players: players)

            return List {
                PlayerSectionView(team: team, editMode: $editMode)
            }
            .environment(\.editMode, $editMode)
        }
    }

    return PlayerSectionPreviewWrapper()
}
