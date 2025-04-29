//
//  SelectedTeamView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

struct SelectedTeamView: View {
    @Binding var team: Team
    @State private var showingGameCreation = false
    @State private var selectedGame: Game?
    @State private var showingGameDay = false


    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GamesSection(
                    games: team.games,
                    addNewGame: {
                        showingGameCreation = true
                    },
                    gameTapped: { game in
                        selectedGame = game
                        showingGameDay = true
                    }
                )
                RosterSection(players: team.players)
            }
        }
        .fullScreenCover(isPresented: $showingGameCreation) {
            GameCreationView(team: $team)
        }
        .fullScreenCover(isPresented: $showingGameDay) {
            if let selectedGame {
                GameDayView(game: selectedGame)
            }
        }
    }
}

struct GamesSection: View {
    var games: [Game]
    var addNewGame: () -> Void
    var gameTapped: (Game) -> Void

    var body: some View {
        GlassCard(
            title: "Games",
            sfSymbol: "calendar",
            buttonSymbol: "plus.circle.fill",
            onButtonTap: addNewGame
        ) {
            VStack(alignment: .leading, spacing: 8) {
                if games.isEmpty {
                    Text("No games yet.")
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(games) { game in
                        Button {
                            gameTapped(game)
                        } label: {
                            GameRow(game: game)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct RosterSection: View {
    var players: [Player]

    var body: some View {
        GlassCard(
            title: "Roster",
            sfSymbol: "person.3.fill"
        ) {
            VStack(alignment: .leading, spacing: 8) {     
                if players.isEmpty {
                    Text("No players yet.")
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.vertical, 8)
                } else {
                    ForEach(players) { player in
                        PlayerBadge(player: player)
                    }
                }
            }
        }
    }
}


#Preview ("Game Section") {
    GamesSection(
        games: [
            Game(name: "Game 1", date: Date(), availablePlayers: []),
            Game(name: "Game 2", date: Date(), availablePlayers: [])
        ],
        addNewGame: {},
        gameTapped: { _ in }
    )
}

#Preview {
    @Previewable @State var mockTeam = Team(
        name: "Mock Team",
        players: [
            Player(name: "Alice", tint: .red),
            Player(name: "Bob", tint: .blue),
            Player(name: "Charlie", tint: .green),
            Player(name: "Dana", tint: .orange),
            Player(name: "Eve", tint: .yellow),
            Player(name: "Frank", tint: .green)
        ],
        games: [
            Game(name: "Game 1", date: Date(), availablePlayers: []),
            Game(name: "Game 2", date: Date(), availablePlayers: [])
        ],
    )

    return ZStack {
        LinearGradient(
            colors: [
                Color(red: 64/255, green: 160/255, blue: 43/255),
                Color(red: 136/255, green: 57/255, blue: 239/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        SelectedTeamView(team: $mockTeam)
    }
}
