//
//  TeamCreationView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//


import SwiftUI

struct TeamCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var teamName: String = ""
    @State private var playerName: String = ""
    @State private var players: [Player] = []


    var onCreate: (Team) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Team Name") {
                    HStack {
                        TextField("Enter team name", text: $teamName)
                            .textInputAutocapitalization(.words)
                    }
                }

                Section("Add Players") {
                    HStack {
                        TextField("Player name", text: $playerName)
                            .textInputAutocapitalization(.words)

                        Button {
                            addPlayer()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    if players.isEmpty {
                        Text("No players added yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(players) { player in
                            Text(player.name)
                                .foregroundStyle(player.tint)
                        }
                        .onDelete(perform: deletePlayer)
                    }
                }
            }
            .navigationTitle("New Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createTeam()
                    }
                    .disabled(teamName.trimmingCharacters(in: .whitespaces).isEmpty || players.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func addPlayer() {
        let tint = PlayerPalette.color(for: players.count)
        players.append(Player(name: playerName, tint: tint))
        playerName = ""
    }

    private func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }

    private func createTeam() {
        let sortedPlayers = players.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        let newTeam = Team(name: teamName, players: sortedPlayers)
        onCreate(newTeam)
        dismiss()
    }
}

struct PlayerPalette {
    static let colors: [Color] = [.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .pink]

    static func color(for index: Int) -> Color {
        colors[index % colors.count]
    }
}

#Preview {
    TeamCreationView { team in
        print("Created Team: \(team.name) with players: \(team.players.map(\.name))")
    }
}
