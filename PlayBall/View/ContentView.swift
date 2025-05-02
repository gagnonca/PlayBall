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
                        // List existing teams
                        ForEach(coach.teams) { team in
                            Button(team.name) {
                                selectedTeam = team
                            }
                        }

                        Divider()

                        // Add New Team
                        Button {
                            showingTeamCreation = true
                        } label: {
                            Label("Add New Team", systemImage: "plus")
                        }

                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedTeam?.name ?? "Select Team")
                                .font(.title.bold())
                                .foregroundStyle(.white)

                            Image(systemName: "chevron.down")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white.opacity(0.7))
                                .offset(y: 1)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedTeam != nil {
                        Menu {
                            Button {
                                showingEditTeam = true
                            } label: {
                                Label("Edit Team", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                deleteSelectedTeam()
                            } label: {
                                Label("Delete Team", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(.white)
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


