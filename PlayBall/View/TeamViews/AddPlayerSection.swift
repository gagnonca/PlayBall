//
//  AddPlayerSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

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
                        Image(systemName: "plus.circle.fill")
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
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

#Preview {
    AddPlayerSectionPreviewWrapper()
}

private struct AddPlayerSectionPreviewWrapper: View {
    @State private var newPlayerName = ""
    @State private var players: [Player] = Coach.previewCoach.teams.first!.players

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 64/255, green: 160/255, blue: 43/255),
                    Color(red: 136/255, green: 57/255, blue: 239/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.3)
            .ignoresSafeArea()

            ScrollView {
                AddPlayerSection(
                    newPlayerName: $newPlayerName,
                    players: $players,
                    addPlayer: {
                        let trimmed = newPlayerName.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        players.append(Player(name: trimmed, tint: .blue))
                        newPlayerName = ""
                    }
                )
                .padding(.top, 32)
            }
        }
    }
}
