//
//  ContentView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/26/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(Coach.self) private var coach

    @AppStorage("lastSelectedTeamID") private var lastSelectedTeamID: String = ""
    
    @State private var selectedTeamID: UUID? = nil
    @State private var showingEditTeam = false
    @State private var showingTeamCreation = false

    var body: some View {
        @Bindable var coach = coach

        NavigationStack {
            ZStack {
                ColorGradient()

                if let id = selectedTeamID,
                   let idx = coach.teams.firstIndex(where: { $0.id == id }) {
                    // Bind directly into the array element to keep identity stable
                    SelectedTeamView(team: $coach.teams[idx])
                        // If you ever see lingering internal state when switching teams,
                        // uncomment the next line to force a clean remount:
                        //.id(id)
                } else {
                    EmptyTeamView(showingTeamCreation: $showingTeamCreation)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Menu {
                        Section("Teams") {
                            ForEach(coach.teams, id: \.id) { team in
                                Button {
                                    select(teamID: team.id)
                                } label: {
                                    Label(team.name, systemImage: team.id == selectedTeamID ? "checkmark" : "")
                                }
                            }
                        }

                        Divider()

                        // Add Team
                        Button {
                            showingTeamCreation = true
                        } label: {
                            Label("Add New Team", systemImage: "plus")
                        }

                        // Edit Team
                        Button("Edit Team", systemImage: "pencil") {
                            showingEditTeam = true
                        }
                        .disabled(selectedTeamID == nil)

                        // Delete Team
                        Button(role: .destructive) {
                            deleteSelectedTeam()
                        } label: {
                            Label("Delete Team", systemImage: "trash")
                        }
                        .disabled(selectedTeamID == nil)
                    } label: {
                        HStack(spacing: 6) {
                            Text(currentTeamName ?? "Select Team")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                            Image(systemName: "chevron.down")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white.opacity(0.7))
                                .offset(y: 1)
                        }
                    }
                }
            }
            .onAppear(perform: restoreSelection)
            .fullScreenCover(isPresented: $showingTeamCreation) {
                TeamAddView { newTeam in
                    coach.saveTeam(newTeam)
                    select(teamID: newTeam.id)
                }
            }
            .fullScreenCover(isPresented: $showingEditTeam) {
                if let id = selectedTeamID,
                   let idx = coach.teams.firstIndex(where: { $0.id == id }) {
                    TeamEditView(team: $coach.teams[idx])
                }
            }
        }
    }

    // MARK: - Derived

    private var currentTeamName: String? {
        guard let id = selectedTeamID,
              let team = coach.teams.first(where: { $0.id == id })
        else { return nil }
        return team.name
    }

    // MARK: - Actions

    private func restoreSelection() {
        // Try to restore saved team; else default to first if available
        if let saved = UUID(uuidString: lastSelectedTeamID),
           coach.teams.contains(where: { $0.id == saved }) {
            selectedTeamID = saved
        } else {
            selectedTeamID = coach.teams.first?.id
            lastSelectedTeamID = coach.teams.first?.id.uuidString ?? ""
        }
    }

    private func select(teamID: UUID) {
        selectedTeamID = teamID
        lastSelectedTeamID = teamID.uuidString
    }

    private func deleteSelectedTeam() {
        guard let id = selectedTeamID,
              let idx = coach.teams.firstIndex(where: { $0.id == id }) else { return }

        let wasLast = (coach.teams.count == 1)
        coach.deleteTeam(coach.teams[idx])

        if wasLast {
            selectedTeamID = nil
            lastSelectedTeamID = ""
        } else {
            selectedTeamID = coach.teams.first?.id
            lastSelectedTeamID = coach.teams.first?.id.uuidString ?? ""
        }
    }
}

#Preview {
    ContentView()
}


