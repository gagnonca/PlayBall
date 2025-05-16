//
//  GameEditorForm.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//


import SwiftUI

struct GameEditorForm: View {
    @Binding var game: Game
    @Environment(\.dismiss) private var dismiss

    let team: Team
    let title: String
    let showDelete: Bool
    let onSave: () -> Void
    let onCancel: () -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                GameDetailsSection(game: $game)
                GameSettingsSection(game: $game)
                AvailablePlayersGameSection(availablePlayers: $game.availablePlayers, fullRoster: team.players)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DismissButton {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    SaveButton(isEnabled: isSaveEnabled) {
                        onSave()
                    }
                }
            }

            if showDelete, let onDelete = onDelete {
                DeleteButton(title: "Delete Game") {
                    onDelete()
                    dismiss()
                }
            }
        }
    }

    private var isSaveEnabled: Bool {
        !game.name.trimmingCharacters(in: .whitespaces).isEmpty && !game.availablePlayers.isEmpty
    }
}

private struct GameDetailsSection: View {
    @Binding var game: Game

    var body: some View {
        Section {
            TextField("Game Name", text: $game.name)
            DatePicker("Date", selection: $game.date, displayedComponents: [.date])
        } header: {
            Text("Game Details")
        }
    }
}

private struct AvailablePlayersGameSection: View {
    @Binding var availablePlayers: [Player]
    let fullRoster: [Player]

    var body: some View {
        Section("Available Players") {
            if availablePlayers.isEmpty {
                Text("No players selected").foregroundStyle(.secondary)
            } else {
                ForEach(Array(availablePlayers.enumerated()), id: \.element.id) { index, player in
                    HStack {
                        Text("\(index + 1). \(player.name)")
                            .foregroundStyle(player.tint)
                        Spacer()
                        Image(.reorder)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { availablePlayers.remove(atOffsets: $0) }
                .onMove { availablePlayers.move(fromOffsets: $0, toOffset: $1) }
            }
        }

        if availablePlayers.count < fullRoster.count {
            Section("Team Roster") {
                ForEach(fullRoster.filter { !availablePlayers.contains($0) }) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Button {
                            availablePlayers.append(player)
                        } label: {
                            Image(.add)
                                .foregroundStyle(player.tint)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
    }
}


private struct GameSettingsSection: View {
    @Binding var game: Game

    var body: some View {
        DisclosureGroup("Advanced Settings") {
            Picker("Period Style", selection: $game.numberOfPeriods) {
                Text("4 Quarters").tag(PeriodStyle.quarter)
                Text("2 Halves").tag(PeriodStyle.half)
            }
            .pickerStyle(.segmented)
            VStack(alignment: .leading) {
                Text("Minutes per \(game.numberOfPeriods.displayName): \(game.periodLengthMinutes)")
                Slider(value: Binding(get: {
                    Double(game.periodLengthMinutes)
                }, set: {
                    game.periodLengthMinutes = Int($0)
                }), in: 1...60, step: 1)
            }
            Picker("Substitution Frequency", selection: $game.substitutionStyle) {
                Text("Long").tag(SubstitutionStyle.long)
                Text("Short").tag(SubstitutionStyle.short)
            }
        }
    }
}

#Preview("Game Editor Form") {
    @Previewable @State var game = Coach.shared.teams.first!.games.first!

    GameEditorForm(
        game: $game,
        team: Coach.previewCoach.teams.first!,
        title: "Edit Game",
        showDelete: true,
        onSave: { print("Saved!") },
        onCancel: { print("Canceled!") },
        onDelete: { print("Deleted!") }
    )
}
