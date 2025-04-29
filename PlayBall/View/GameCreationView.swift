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
                        VStack(spacing: 24) {
                            gameInfoSection
                            availablePlayersSection
                            rosterSection
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

    private var gameInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Game Info", systemImage: "calendar.badge.plus")
                .font(.title3.bold())
                .foregroundStyle(.white.opacity(0.9))
                .padding(.bottom, 4)

            TextField("Enter Game Name", text: $gameName)
                .textInputAutocapitalization(.words)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .foregroundStyle(.white)

            DatePicker("Game Date", selection: $gameDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .foregroundStyle(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    private var availablePlayersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Available Players", systemImage: "person.crop.circle.badge.checkmark")
                .font(.title3.bold())
                .foregroundStyle(.white.opacity(0.9))
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity, alignment: .leading)

            if availablePlayers.isEmpty {
                Text("No players selected yet.")
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.vertical, 8)
            } else {
                ForEach(availablePlayers) { player in
                    HStack {
                        Text(player.name)
                            .foregroundStyle(.white)

                        Spacer()

                        Button {
                            removePlayer(player)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    private var rosterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Roster", systemImage: "person.3.fill")
                .font(.title3.bold())
                .foregroundStyle(.white.opacity(0.9))
                .padding(.bottom, 4)

            let rosterPlayers = team.players.filter { player in
                !availablePlayers.contains(where: { $0.id == player.id })
            }

            if rosterPlayers.isEmpty {
                Text("All players are selected.")
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.vertical, 8)
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
                                .foregroundStyle(.white)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal)
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
                Team(
                    name: "Mock Team",
                    players: [
                        Player(name: "Alice", tint: .red),
                        Player(name: "Bob", tint: .blue),
                        Player(name: "Charlie", tint: .green)
                    ],
                    games: []
                )
            )
        )
    }
}
