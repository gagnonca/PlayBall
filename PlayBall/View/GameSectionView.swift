//
//  GameSectionView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//


import SwiftUI

struct GameSectionView: View {
    @Bindable var team: Team
    @Binding var editMode: EditMode
    @Binding var showingGameEditor: Bool

    var body: some View {
        Section("Games") {
            ForEach(team.games.indices, id: \.self) { idx in
                NavigationLink {
                    GameDayView(game: $team.games[idx], team: team)
                } label: {
                    GameRow(game: team.games[idx])
                }
            }
            .onDelete { team.games.remove(atOffsets: $0) }
            if(editMode == .inactive) {
                Button {
                    showingGameEditor = true
                } label: {
                    Label("Add Game", systemImage: "plus.circle")
                }
                .foregroundStyle(.blue)
            }
        }
    }
}


#Preview {
    struct GameSectionPreviewWrapper: View {
        @State private var editMode: EditMode = .inactive
        @State private var showingGameEditor = false

        var body: some View {
            let players = [
                Player(name: "Addy", tint: .red),
                Player(name: "Haley", tint: .orange),
                Player(name: "Amelia", tint: .yellow),
                Player(name: "Lucy", tint: .green),
                Player(name: "Brooke", tint: .blue),
                Player(name: "Alana", tint: .purple)
            ]

            let games = [
                Game(name: "Game 1", date: .now, availablePlayers: players),
                Game(name: "Game 2", date: .now.addingTimeInterval(86400), availablePlayers: players)
            ]

            let team = Team(name: "Preview Team", players: players, games: games)

            return NavigationStack {
                List {
                    GameSectionView(
                        team: team,
                        editMode: $editMode,
                        showingGameEditor: $showingGameEditor
                    )
                }
                .environment(\.editMode, $editMode)
            }
        }
    }

    return GameSectionPreviewWrapper()
}
