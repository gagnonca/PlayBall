//
//  TeamEditorForm.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/28/25.
//


import SwiftUI

struct TeamEditorForm: View {
    @Binding var teamName: String
    @Binding var players: [Player]
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
                            TeamNameSection(teamName: $teamName)

                            AddPlayerSection(
                                newPlayerName: $newPlayerName,
                                players: $players,
                                addPlayer: addPlayer
                            )

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
        !teamName.trimmingCharacters(in: .whitespaces).isEmpty && !players.isEmpty
    }

    private func addPlayer() {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let tint = PlayerPalette.color(for: players.count)
        players.append(Player(name: trimmed, tint: tint))
        newPlayerName = ""
    }
}

#Preview("Team Editor Form") {
    @Previewable @State var teamName = "Mock Team"
    @Previewable @State var players = Array(Coach.previewCoach.teams.first!.players.prefix(3))

    return TeamEditorForm(
        teamName: $teamName,
        players: $players,
        title: "Create/Edit Team",
        showDelete: true,
        onSave: { print("Saved!") },
        onCancel: { print("Canceled!") },
        onDelete: { print("Deleted!") }
    )
}
