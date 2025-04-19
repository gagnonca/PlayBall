//
//  GameEditorForm.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/17/25.
//

import SwiftUI

struct GameEditorForm: View {
    @Binding var gameName: String
    @Binding var gameDate: Date
    @Binding var selectedPlayers: [Player]

    let team: Team
    let onSave: () -> Void
    let onCancel: () -> Void
    let title: String

    var body: some View {
        NavigationStack {
            Form {
                Section("Game Details") {
                    TextField("Game Name", text: $gameName)
                    DatePicker("Date", selection: $gameDate, displayedComponents: [.date])
                }

                Section("Available Players") {
                    if selectedPlayers.isEmpty {
                        Text("No players selected").foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(selectedPlayers.enumerated()), id: \.element.id) { index, player in
                            VStack(spacing: 0) {
                                HStack {
                                    Text("\(index + 1). \(player.name)")
                                        .foregroundStyle(player.tint)
                                    Spacer()
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { selectedPlayers.remove(atOffsets: $0) }
                        .onMove { selectedPlayers.move(fromOffsets: $0, toOffset: $1) }
                    }
                }

                if selectedPlayers.count < team.players.count {
                    Section("Team Roster") {
                        ForEach(team.players.filter { !selectedPlayers.contains($0) }) { player in
                            HStack {
                                Text(player.name)
                                Spacer()
                                Button {
                                    selectedPlayers.append(player)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(player.tint)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .disabled(gameName.trimmingCharacters(in: .whitespaces).isEmpty || selectedPlayers.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

