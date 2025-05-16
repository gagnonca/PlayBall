//
//  GameEditorForm.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//


import SwiftUI

// MARK: - Opening GameEditorForm in Add mode
struct GameAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var team: Team
    @State private var game: Game

    init(team: Team) {
        self.team = team
        _game = State(initialValue: Game(
            name: "Game \(team.games.count + 1)",
            date: Date(),
            availablePlayers: [],
        ))
    }

    var body: some View {
        GameEditorForm(
            game: $game,
            team: team,
            title: "New Game",
            showDelete: false,
            onSave: {
                team.addGame(game)
                dismiss()
            },
            onCancel: { dismiss() },
            onDelete: nil
        )
    }
}

// MARK: - Opening GameEditorForm in Edit mode
struct GameEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var game: Game
    @Bindable var team: Team

    var body: some View {
        GameEditorForm(
            game: $game,
            team: team,
            title: "Edit Game",
            showDelete: true,
            onSave: {
                Coach.shared.updateTeam(team)
                dismiss()
            },
            onCancel: { dismiss() },
            onDelete: {
                team.removeGame(game)
            }
        )
    }
}

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
                AvailablePlayersGameSection(availablePlayers: $game.availablePlayers, fullRoster: team.players)
                GameSettingsSection(game: $game)
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
                ForEach(fullRoster.sortedByName.filter { !availablePlayers.contains($0) }) { player in
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

struct GameInfoSection: View {
    @Binding var gameName: String
    @Binding var gameDate: Date

    var body: some View {
        GlassCard(
            title: "Game Info",
            sfSymbol: "calendar.badge.plus"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Enter Game Name", text: $gameName)
                    .textInputAutocapitalization(.words)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .foregroundStyle(.primary)

                DatePicker("Game Date", selection: $gameDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .foregroundStyle(.primary)
            }
        }
    }
}

struct AvailablePlayersSection: View {
    @Binding var availablePlayers: [Player]
    var removePlayer: (Player) -> Void

    var body: some View {
        GlassCard(
            title: "Available Players",
            sfSymbol: "person.crop.circle.badge.checkmark"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                if availablePlayers.isEmpty {
                    Text("No players selected yet.")
                        .foregroundStyle(.white.opacity(0.7))
                } else {
                    ForEach(Array(availablePlayers.enumerated()), id: \.element.id) { index, player in
                        HStack {
                            Text("\(index + 1). \(player.name)")
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                removePlayer(player)
                            } label: {
                                Image(.remove)
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
    }
}

struct RosterSelectionSection: View {
    var team: Team
    @Binding var availablePlayers: [Player]
    var addPlayer: (Player) -> Void

    var body: some View {
        GlassCard(
            title: "Roster",
            sfSymbol: "person.3.fill"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                let rosterPlayers = team.players.filter { player in
                    !availablePlayers.contains(where: { $0.id == player.id })
                }

                if rosterPlayers.isEmpty {
                    Text("All players are selected.")
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(rosterPlayers) { player in
                        HStack {
                            Text(player.name)
                                .foregroundStyle(.primary)

                            Spacer()

                            Button {
                                addPlayer(player)
                            } label: {
                                Image(.add)
                                    .foregroundStyle(player.tint)
                            }
                        }
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
                Text("Quarters").tag(GameFormat.quarter)
                Text("Halves").tag(GameFormat.half)
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
            VStack(alignment: .leading, spacing: 8) {
                Picker("Substitution Frequency", selection: $game.substitutionStyle) {
                    Text("Long").tag(SubstitutionStyle.long)
                    Text("Short").tag(SubstitutionStyle.short)
                }

                Text(game.substitutionStyle == .long
                     ? "Players rotate fewer times, with longer shifts."
                     : "Players rotate more frequently, with shorter shifts.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("Game Editor Form - Add Mode") {
    GameAddView(team: Coach.previewCoach.teams.first!)
}

#Preview("Game Editor Form - Edit Mode") {
    @Previewable @State var game = Coach.previewCoach.teams.first!.games.first!
    GameEditView(game: $game, team: Coach.previewCoach.teams.first!)
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
