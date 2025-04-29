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
                Section("Game Details") {
                    TextField("Game Name", text: $gameName)
                    DatePicker("Date", selection: $gameDate, displayedComponents: [.date])
                }

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
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { availablePlayers.remove(atOffsets: $0) }
                        .onMove { availablePlayers.move(fromOffsets: $0, toOffset: $1) }
                    }
                }

                if availablePlayers.count < team.players.count {
                    Section("Team Roster") {
                        ForEach(team.players.filter { !availablePlayers.contains($0) }) { player in
                            HStack {
                                Text(player.name)
                                Spacer()
                                Button {
                                    availablePlayers.append(player)
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

#Preview("Game Editor Form") {
    @Previewable @State var gameName = "Saturday Match"
    @Previewable @State var gameDate = Date()
    @Previewable @State var availablePlayers = Array(Coach.previewCoach.teams.first!.players.prefix(5))
    
    GameEditorForm(
        gameName: $gameName,
        gameDate: $gameDate,
        availablePlayers: $availablePlayers,
        team: Coach.previewCoach.teams.first!,
        title: "Edit Game",
        showDelete: true,
        onSave: { print("Saved!") },
        onCancel: { print("Canceled!") },
        onDelete: { print("Deleted!") }
    )
}
