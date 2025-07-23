//
//  ContentView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var coach = Coach.shared
    @State private var selectedTeam: Team?
    @State private var showingEditTeam = false
    @State private var showingTeamCreation = false

    var body: some View {
        NavigationStack {
            ZStack {
                ColorGradient()
                if let _ = selectedTeam {
                    SelectedTeamView(team: Binding<Team>(
                        get: { selectedTeam! },
                        set: { selectedTeam = $0 }
                    ))
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
                                    selectedTeam = team
                                } label: {
                                    Label(team.name, systemImage: team.id == selectedTeam?.id ? "checkmark" : "")
                                }
                            }
                        }

                        Divider()

                        // Add New Team
                        Button {
                            showingTeamCreation = true
                        } label: {
                            Label("Add New Team", systemImage: "plus")
                        }
                        
                        // Edit selected Team
                        Button("Edit Team", systemImage: "pencil") {
                            showingEditTeam = true
                        }
                        .disabled(selectedTeam == nil)
                        
                        // Delete Team
                        Button(role: .destructive) {
                            deleteSelectedTeam()
                        } label: {
                            Label("Delete Team", systemImage: "trash")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedTeam?.name ?? "Select Team")
                                .font(.title.bold())
                                .foregroundStyle(.white)

                            Image(.menu)
                                .font(.subheadline.bold())
                                .foregroundStyle(.white.opacity(0.7))
                                .offset(y: 1)
                        }
                    }
                }
            }
            .onAppear {
                if selectedTeam == nil, !coach.teams.isEmpty {
                    selectedTeam = coach.teams.first
                }
            }
            .fullScreenCover(isPresented: $showingTeamCreation) {
                TeamAddView { newTeam in
                    coach.saveTeam(newTeam)
                    selectedTeam = newTeam
                }
            }
            .fullScreenCover(isPresented: $showingEditTeam) {
                if let selectedTeam = selectedTeam,
                   let index = coach.teams.firstIndex(where: { $0.id == selectedTeam.id }) {
                    TeamEditView(team: $coach.teams[index])
                }
            }
        }
    }
    
    private func deleteSelectedTeam() {
        if let selectedTeam {
            coach.deleteTeam(selectedTeam)
            self.selectedTeam = coach.teams.first
        }
    }
}

#Preview {
    ContentView()
}


