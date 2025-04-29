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
                ToolbarItem(placement: .topBarLeading) {
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
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Menu {
                        ForEach(coach.teams) { team in
                            Button(team.name) {
                                selectedTeam = team
                            }
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
                    Button {
                        showingTeamCreation = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
            }
            .onAppear {
                if selectedTeam == nil, !coach.teams.isEmpty {
                    selectedTeam = coach.teams.first
                }
            }
            .fullScreenCover(isPresented: $showingTeamCreation, onDismiss: {
                if selectedTeam == nil, !coach.teams.isEmpty {
                    selectedTeam = coach.teams.first
                }
            }) {
                TeamCreationView(
                    team: .constant(
                        Team(name: "", players: [])
                    )
                )
            }
            .fullScreenCover(isPresented: $showingEditTeam) {
                if let index = coach.teams.firstIndex(where: { $0.id == selectedTeam?.id }),
                   let selectedTeam = selectedTeam {
                    TeamCreationView(team: $coach.teams[index])
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


