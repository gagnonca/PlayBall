//
//  GameEditorForm.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//


import SwiftUI

struct GameEditorForm: View {
    @Binding var gameName: String
    @Binding var gameDate: Date
    @Binding var availablePlayers: [Player]
    @Binding var substitutionStyle: SubstitutionStyle
    @Binding var playersOnField: Int
    @Binding var periodLengthMinutes: Int
    @Binding var numberOfPeriods: PeriodStyle

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
                GameDetailsSection(gameName: $gameName, gameDate: $gameDate)

                GameSettingsSection(
                    substitutionStyle: $substitutionStyle,
                    playersOnField: $playersOnField,
                    periodLengthMinutes: $periodLengthMinutes,
                    numberOfPeriods: $numberOfPeriods
                )

                AvailablePlayersGameSection(availablePlayers: $availablePlayers, fullRoster: team.players)
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
        !gameName.trimmingCharacters(in: .whitespaces).isEmpty && !availablePlayers.isEmpty
    }
}


private struct GameDetailsSection: View {
    @Binding var gameName: String
    @Binding var gameDate: Date

    var body: some View {
        Section("Game Details") {
            TextField("Game Name", text: $gameName)
            DatePicker("Date", selection: $gameDate, displayedComponents: [.date])
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
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(index + 1). \(player.name)")
                                .foregroundStyle(player.tint)
                            Spacer()
                            Image(.reorder)
                                .foregroundStyle(.secondary)
                        }
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
    @Binding var substitutionStyle: SubstitutionStyle
    @Binding var playersOnField: Int
    @Binding var periodLengthMinutes: Int
    @Binding var numberOfPeriods: PeriodStyle

    var body: some View {
        Section {
            Picker("Substitution Style", selection: $substitutionStyle) {
                Text("Long").tag(SubstitutionStyle.long)
                Text("Short").tag(SubstitutionStyle.short)
            }
            Stepper("Players on Field: \(playersOnField)", value: $playersOnField, in: 1...11)
            Stepper("Minutes per Period: \(periodLengthMinutes)", value: $periodLengthMinutes, in: 1...60)
            Picker("Period Style", selection: $numberOfPeriods) {
                Text("4 Quarters").tag(PeriodStyle.quarter)
                Text("2 Halves").tag(PeriodStyle.half)
            }
        } header: {
            Text("Game Settings")
        }
    }
}


#Preview("Game Editor Form") {
    @Previewable @State var gameName = "Saturday Match"
    @Previewable @State var gameDate = Date()
    @Previewable @State var availablePlayers = Array(Coach.previewCoach.teams.first!.players.prefix(5))
    @Previewable @State var substitutionStyle = SubstitutionStyle.short
    @Previewable @State var playersOnField = 4
    @Previewable @State var periodLengthMinutes = 10
    @Previewable @State var numberOfPeriods = PeriodStyle.quarter

    return GameEditorForm(
        gameName: $gameName,
        gameDate: $gameDate,
        availablePlayers: $availablePlayers,
        substitutionStyle: $substitutionStyle,
        playersOnField: $playersOnField,
        periodLengthMinutes: $periodLengthMinutes,
        numberOfPeriods: $numberOfPeriods,
        team: Coach.previewCoach.teams.first!,
        title: "Edit Game",
        showDelete: true,
        onSave: { print("Saved!") },
        onCancel: { print("Canceled!") },
        onDelete: { print("Deleted!") }
    )
}
