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

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GamesSection(
                    games: team.games,
                    addNewGame: {
                        showingGameCreation = true
                    },
                    destination: { game in
                        AnyView(
                            GameDayView(
                                game: bindingForGame(game),
                                team: team
                            )
                        )
                    }
                )
                RosterSection(players: team.players)
            }
        }
        .fullScreenCover(isPresented: $showingGameCreation) {
            GameAddView(team: team)
        }
    }
    
    private func bindingForGame(_ game: Game) -> Binding<Game> {
        guard let index = team.games.firstIndex(where: { $0.id == game.id }) else {
            fatalError("Game not found!")
        }
        return $team.games[index]
    }
}

struct GamesSection: View {
    var games: [Game]
    var addNewGame: () -> Void
    var destination: (Game) -> AnyView

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
                } else {
                    ForEach(games) { game in
                        NavigationLink {
                            destination(game)
                        } label: {
                            GameRow(game: game)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
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
                } else {
                    FlowLayout(items: players.sortedByName, spacing: 8) { player in
                        PlayerBadge(player: player)
                    }
                }
            }
        }
    }
}

#Preview ("GameSection") {
    GamesSection(
        games: [
            Game(name: "Game 1", date: Date(), availablePlayers: []),
            Game(name: "Game 2", date: Date(), availablePlayers: [])
        ],
        addNewGame: {},
        destination: { _ in AnyView(EmptyView()) }
    )
    
    GamesSection(
        games: [],
        addNewGame: {},
        destination: { _ in AnyView(EmptyView()) }
    )
}

#Preview ("RosterSection") {
    RosterSection(players: Coach.previewCoach.teams.first!.players)
    RosterSection(players:[])
}

#Preview ("SelectedTeamView") {
    @Previewable @State var mockTeam = Coach.previewCoach.teams.first!

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
