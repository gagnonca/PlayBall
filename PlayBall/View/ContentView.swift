//
//  ContentView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/26/25.
//

import SwiftUI

struct ContentView: View {
    // Shared model
    @State private var coach = Coach.shared

    // Carousel state
    @State private var currentIndex: Int = 0
    @State private var selectedTeamID: UUID? = nil

    // Sheets
    @State private var showingEditTeam = false
    @State private var showingTeamCreation = false
    @State private var showingOverview = false

    // Persist last selected team
    @AppStorage("lastSelectedTeamID") private var lastSelectedTeamID: String = ""

    private var currentTeam: Team? {
        guard coach.teams.indices.contains(currentIndex) else { return nil }
        return coach.teams[currentIndex]
    }

    private var currentTheme: TeamTheme {
        if let c = currentTeam?.colors {
            return TeamTheme(start: Color(hex: c.homeHex), end: Color(hex: c.awayHex))
        } else {
            return .default
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ColorGradient()
                
                if coach.teams.isEmpty {
                    // No teams yet
                    AddTeamPageView(showingTeamCreation: $showingTeamCreation)
                } else {
                    VStack(spacing: 0) {
                        TabView(selection: $selectedTeamID) {
                            ForEach($coach.teams) { $team in
                                SelectedTeamView(team: $team)
                                    .tag(team.id as UUID?)
                            }

                            // Tag the “Add Team” page with nil so you can still swipe to it
                            AddTeamPageView(showingTeamCreation: $showingTeamCreation)
                                .tag(nil as UUID?)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .onChange(of: selectedTeamID) { newID in
                            if let id = newID, let team = coach.teams.first(where: { $0.id == id }) {
                                lastSelectedTeamID = team.id.uuidString
                            }
                        }
                        .onAppear {
                            if let saved = UUID(uuidString: lastSelectedTeamID),
                               coach.teams.contains(where: { $0.id == saved }) {
                                selectedTeamID = saved
                            } else {
                                selectedTeamID = coach.teams.first?.id
                                lastSelectedTeamID = coach.teams.first?.id.uuidString ?? ""
                            }
                        }
                    }
                }
            }
            // Title = team name (no menu here)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Text(currentTeam?.name ?? (coach.teams.isEmpty ? "" : ""))
                        .font(.title.bold())
                        .foregroundStyle(.white)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingOverview = true
                    } label: {
                        Image(systemName: "rectangle.grid.2x2")
//                            .font(.title2)
                    }
                    .tint(.white)

                    Menu {
                        Button("Edit Team", systemImage: "pencil") { showingEditTeam = true }
                            .disabled(currentTeam == nil)
                        Button(role: .destructive) {
                            deleteCurrentTeam()
                        } label: {
                            Label("Delete Team", systemImage: "trash")
                        }
                        .disabled(currentTeam == nil)
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.white.opacity(0.9))
                            .accessibilityLabel("More actions")
                    }
                    .disabled(currentTeam == nil)
                }
            }
            // Add team
            .fullScreenCover(isPresented: $showingTeamCreation) {
                TeamAddView { newTeam in
                    coach.saveTeam(newTeam)
                    if let idx = coach.teams.firstIndex(where: { $0.id == newTeam.id }) {
                        currentIndex = idx
                    } else {
                        currentIndex = max(0, coach.teams.count - 1)
                    }
                    lastSelectedTeamID = coach.teams[currentIndex].id.uuidString
                }
            }
            // Edit team
            .fullScreenCover(isPresented: $showingEditTeam) {
                if let currentTeam = currentTeam,
                   let idx = coach.teams.firstIndex(where: { $0.id == currentTeam.id }) {
                    TeamEditView(team: $coach.teams[idx])
                }
            }
            // Overview grid of all team cards + plus card
            .fullScreenCover(isPresented: $showingOverview) {
                TeamsOverviewView(
                    coach: coach,
                    currentIndex: $currentIndex,
                    lastSelectedTeamID: $lastSelectedTeamID,
                    showingTeamCreation: $showingTeamCreation
                )
            }
        }
        .environment(\.teamTheme, currentTheme)
    }

    private func deleteCurrentTeam() {
        guard let currentTeam else { return }
        coach.deleteTeam(currentTeam)

        if let first = coach.teams.first {
            selectedTeamID = first.id
            lastSelectedTeamID = first.id.uuidString
        } else {
            // No teams left; select the Add page
            selectedTeamID = nil
            lastSelectedTeamID = ""
        }
    }
}

#Preview {
    ContentView()
}
