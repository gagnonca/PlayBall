//
//  TeamEditorForm.swift
//  PlayBall
//

import SwiftUI

struct TeamEditorForm: View {
    @Binding var teamName: String
    @Binding var players: [Player]
    @State private var newPlayerName: String = ""

    let onSave: () -> Void
    let onCancel: () -> Void
    let title: String
    let showDelete: Bool
    let onDelete: (() -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                ColorGradient()
                    .opacity(0.3)
                    .ignoresSafeArea()

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
                                deleteButton(onDelete: onDelete)
                            }
                        }
                        .padding(.top, 32)
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DismissButton(action: onCancel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SaveButton(isEnabled: isSaveEnabled, action: onSave)
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

    private func deleteButton(onDelete: @escaping () -> Void) -> some View {
        Button(role: .destructive) {
            onDelete()
        } label: {
            Label("Delete Team", systemImage: "trash")
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

#Preview("Team Editor Form") {
    @Previewable @State var teamName = "Mock Team"
    @Previewable @State var players = Array(Coach.previewCoach.teams.first!.players.prefix(3))

    return TeamEditorForm(
        teamName: $teamName,
        players: $players,
        onSave: { print("Saved!") },
        onCancel: { print("Canceled!") },
        title: "Create/Edit Team",
        showDelete: true,
        onDelete: { print("Deleted!") }
    )
}
