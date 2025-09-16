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
//        ScrollView {
            VStack(spacing: 16) {
                GamesSection(
                    games: team.games,
                    addNewGame: {
                        showingGameCreation = true
                    },
                    destination: { game in
                        AnyView(
                            GameDayViewWrapper(gameID: game.id, team: $team)
                        )
                    }
                )
                RosterSection(players: team.players)
            }
            .padding(.top, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        
//        }
//        .padding(.top, 32)
        .fullScreenCover(isPresented: $showingGameCreation) {
            GameAddView(team: team)
        }
    }
}

struct GamesSection: View {
    var games: [Game]
    var addNewGame: () -> Void
    var destination: (Game) -> AnyView

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // Measure a single row height; provide a sensible default fallback
    @State private var rowHeight: CGFloat = 44

    // Derive the target max visible rows from available screen height and dynamic type.
    // We aim to use roughly 40% of the screen height for the games list, then convert to rows.
    private var maxVisibleRows: CGFloat {
        // Base target: 40% of screen height for the list area
        let screenHeight = UIScreen.main.bounds.height
        var targetHeight = screenHeight * 0.40

        // Adjust for Dynamic Type: larger text -> fewer rows
        switch dynamicTypeSize {
        case .xSmall, .small, .medium: break
        case .large: targetHeight *= 0.95
        case .xLarge: targetHeight *= 0.9
        case .xxLarge: targetHeight *= 0.85
        case .xxxLarge: targetHeight *= 0.8
        case .accessibility1: targetHeight *= 0.75
        case .accessibility2: targetHeight *= 0.7
        case .accessibility3: targetHeight *= 0.65
        case .accessibility4: targetHeight *= 0.6
        case .accessibility5: targetHeight *= 0.55
        @unknown default: break
        }

        // Convert to rows using the measured row height; add 0.5 to hint scrollability
        let rows = max(targetHeight / max(rowHeight, 1), 1)
        return rows + 0.5
    }

    private var computedMaxHeight: CGFloat? {
        if games.isEmpty { return rowHeight } // compact empty state
        let visibleRows = min(CGFloat(games.count), maxVisibleRows)
        return visibleRows * rowHeight
    }

    var body: some View {
        GlassCard(
            title: "Games",
            sfSymbol: "calendar",
            buttonSymbol: "plus.circle.fill",
            onButtonTap: addNewGame
        ) {
            ScrollView {
                VStack(spacing: 0) {
                    if games.isEmpty {
                        Text("No games yet.")
                            .padding(.vertical, 8)
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: computedMaxHeight)
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
            VStack() {     
                if players.isEmpty {
                    Text("No players yet.")
                        .foregroundStyle(.white.opacity(0.7))
                } else {
                    FlowLayout(items: players.sortedByName, spacing: 8) { player in
                        PlayerPill(name: player.name, tint: player.tint)
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

