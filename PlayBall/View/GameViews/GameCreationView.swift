//
//  GameCreationView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

struct GameCreationView: View {
    @State private var coach = Coach.shared

    @Environment(\.dismiss) private var dismiss
    @Binding var team: Team

    @State private var gameName: String = ""
    @State private var gameDate: Date = Date()
    @State private var availablePlayers: [Player] = []

    var body: some View {
        NavigationStack {
            ZStack {
                ColorGradient()
                    .opacity(0.3)
                    .ignoresSafeArea()

                VStack {
                    ScrollView {
                        VStack(spacing: 12) {
                            GameInfoSection(gameName: $gameName, gameDate: $gameDate)
                            AvailablePlayersSection(availablePlayers: $availablePlayers, removePlayer: removePlayer)
                            RosterSelectionSection(team: team, availablePlayers: $availablePlayers, addPlayer: addPlayer)
                        }
                        .padding(.top, 32)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DismissButton {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    SaveButton(isEnabled: isSaveEnabled) {
                        saveGame()
                    }
                }
            }
        }
    }
    
    private var isSaveEnabled: Bool {
        !gameName.trimmingCharacters(in: .whitespaces).isEmpty && !availablePlayers.isEmpty
    }

    private func addPlayer(_ player: Player) {
        availablePlayers.append(player)
    }

    private func removePlayer(_ player: Player) {
        availablePlayers.removeAll { $0.id == player.id }
    }

    private func saveGame() {
        let newGame = Game(
            name: gameName,
            date: gameDate,
            availablePlayers: availablePlayers
        )
        team.games.append(newGame)
        dismiss()
    }
}

#Preview("Create New Game") {
    NavigationStack {
        GameCreationView(
            team: .constant(
                Coach.previewCoach.teams.first!
            )
        )
    }
}
