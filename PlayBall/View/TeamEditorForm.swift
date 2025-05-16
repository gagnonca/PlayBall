//
//  TeamEditorForm.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/28/25.
//


import SwiftUI

struct TeamAddView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coach = Coach.shared
    @State private var team: Team = Team(name: "", players: [])
    
    let onSave: (Team) -> Void

    var body: some View {
        TeamEditorForm(
            team: $team,
            title: "Create Team",
            showDelete: false,
            onSave: {
                coach.saveTeam(team)
                onSave(team)
                dismiss()
            },
            onCancel: {
                dismiss()
            },
            onDelete: nil
        )
    }
}

struct TeamEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var team: Team

    var body: some View {
        TeamEditorForm(
            team: $team,
            title: "Edit Team",
            showDelete: true,
            onSave: {
                Coach.shared.updateTeam(team)
                dismiss()
            },
            onCancel: { dismiss() },
            onDelete: {
                Coach.shared.deleteTeam(team)
                dismiss()
            }
        )
    }
}

struct TeamEditorForm: View {
    @Binding var team: Team
    @State private var newPlayerName: String = ""
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let showDelete: Bool
    let onSave: () -> Void
    let onCancel: () -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                ColorGradient()
                    .opacity(0.3)

                VStack {
                    ScrollView {
                        VStack(spacing: 12) {
                            TeamNameSection(teamName: $team.name)
                            AddPlayerSection(
                                newPlayerName: $newPlayerName,
                                players: $team.players,
                                addPlayer: addPlayer
                            )
                            LeagueRulesSection(team: $team)

                            if showDelete, let onDelete {
                                DeleteButton(title: "Delete Team") {
                                    onDelete()
                                }
                            }
                        }
                        .padding(.top, 32)
                    }
                }
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
        }
    }

    private var isSaveEnabled: Bool {
        !team.name.trimmingCharacters(in: .whitespaces).isEmpty && !team.players.isEmpty
    }

    private func addPlayer() {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let tint = PlayerPalette.hexCode(for: team.players.count)
        team.players.append(Player(name: trimmed, tintHex: tint))
        newPlayerName = ""
    }
}

struct TeamNameSection: View {
    @Binding var teamName: String
    @FocusState private var isFocused: Bool

    var body: some View {
        GlassCard(title: "Team Name", sfSymbol: "figure.run") {
            TextField("Enter Team Name", text: $teamName)
                .textInputAutocapitalization(.words)
                .foregroundStyle(.primary)
                .textInputAutocapitalization(.words)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
        }
    }
}

struct AddPlayerSection: View {
    @Binding var newPlayerName: String
    @Binding var players: [Player]
    var addPlayer: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var isAddEnabled: Bool {
        !newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        GlassCard(title: "Add Player", sfSymbol: "person.fill.badge.plus") {
            VStack(spacing: 8) {
                HStack {
                    TextField("Enter Player Name", text: $newPlayerName)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            isTextFieldFocused = true
                            addPlayer()
                        }
                    Spacer()
                    Button(action: {
                        addPlayer()
                    }) {
                        Image(.add)
                            .foregroundStyle(isAddEnabled ? .green : .secondary)
                    }
                    .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.vertical, 4)

                ForEach($players) { $player in
                    HStack {
                        TextField("Player Name", text: $player.name)
                            .textInputAutocapitalization(.words)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Button {
                            if let index = players.firstIndex(where: { $0.id == player.id }) {
                                players.remove(at: index)
                            }
                        } label: {
                            Image(.remove)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct LeagueRulesSection: View {
    @Binding var team: Team

    var body: some View {
        GlassCard(title: "League Rules", sfSymbol: "list.bullet.rectangle") {
            VStack(alignment: .leading, spacing: 12) {

                HStack {
                    Text("Match Format")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Picker("", selection: $team.matchFormat) {
                        ForEach(MatchFormat.allCases) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(true)
                }


                Picker("Format", selection: $team.gameFormat) {
                    Text("Quarters").tag(GameFormat.quarter)
                    Text("Halves").tag(GameFormat.half)
                }
                .pickerStyle(.segmented)

                Text("Minutes per \(team.gameFormat.displayName): \(team.periodLengthMinutes)")
                
                Slider(
                    value: Binding(get: {
                        Double(team.periodLengthMinutes)
                    }, set: {
                        team.periodLengthMinutes = Int($0)
                    }),
                    in: 1...60,
                    step: 1
                )
            }
        }
    }
}

#Preview("Add Team") {
    TeamAddView { _ in print("Saved!") }
}

#Preview("Edit Team") {
    @Previewable @State var mockTeam = Coach.previewCoach.teams.first!

    return TeamEditView(team: $mockTeam)
}

#Preview("Team Editor Form") {
    @Previewable @State var team = Coach.previewCoach.teams.first!

    TeamEditorForm(
        team: $team,
        title: "Create/Edit Team",
        showDelete: true,
        onSave: { print("Saved!") },
        onCancel: { print("Canceled!") },
        onDelete: { print("Deleted!") }
    )
}
