//
//  ContentView.swift
//  PlayBall
//

import SwiftUI

// MARK: - Robust selection type (no more nil-tags)
private enum TeamTabSelection: Hashable {
    case team(UUID)
    case add
}

struct ContentView: View {
    // Shared model
    @State private var coach = Coach.shared

    // Selection driven by stable IDs (via enum)
    @State private var selection: TeamTabSelection = .add

    // Sheets
    @State private var showingEditTeam = false
    @State private var showingTeamCreation = false
    @State private var showingOverview = false

    // Persist last selected team
    @AppStorage("lastSelectedTeamID") private var lastSelectedTeamID: String = ""

    // Current team derived from selection
    private var currentTeam: Team? {
        guard case let .team(id) = selection else { return nil }
        return coach.teams.first(where: { $0.id == id })
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
                    // No teams yet -> show Add page directly
                    AddTeamPageView(showingTeamCreation: $showingTeamCreation)
                } else {
                    VStack(spacing: 0) {
                        TabView(selection: $selection) {
                            ForEach($coach.teams) { $team in
                                SelectedTeamView(team: $team)
                                    .tag(TeamTabSelection.team(team.id))
                            }

                            // Last page = Add Team
                            AddTeamPageView(showingTeamCreation: $showingTeamCreation)
                                .tag(TeamTabSelection.add)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .onChange(of: selection) { newSel in
                            switch newSel {
                            case .team(let id):
                                lastSelectedTeamID = id.uuidString
                            case .add:
                                lastSelectedTeamID = ""
                            }
                        }
                        .onAppear {
                            // Restore last viewed team (if still exists) or default to first (or Add page if none)
                            if
                                let saved = UUID(uuidString: lastSelectedTeamID),
                                coach.teams.contains(where: { $0.id == saved })
                            {
                                selection = .team(saved)
                            } else if let first = coach.teams.first {
                                selection = .team(first.id)
                                lastSelectedTeamID = first.id.uuidString
                            } else {
                                selection = .add
                                lastSelectedTeamID = ""
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    if let team = currentTeam {
                        Menu {
                            Button("Edit Team", systemImage: "pencil") { showingEditTeam = true }
                            Button(role: .destructive) {
                                deleteCurrentTeam()
                            } label: {
                                Label("Delete Team", systemImage: "trash")
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(team.name)
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)

                                Image(systemName: "chevron.down")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.leading, 2)
                            }
                            .contentShape(Rectangle())
                        }
                        .accessibilityLabel("Team actions for \(team.name)")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingOverview = true
                    } label: {
                        Image(systemName: "rectangle.grid.2x2")
                    }
                    .tint(.white)
                }
            }
            // Add team
            .fullScreenCover(isPresented: $showingTeamCreation) {
                TeamAddView { newTeam in
                    coach.saveTeam(newTeam)
                    if coach.teams.contains(where: { $0.id == newTeam.id }) {
                        selection = .team(newTeam.id)
                        lastSelectedTeamID = newTeam.id.uuidString
                    } else if let first = coach.teams.first {
                        selection = .team(first.id)
                        lastSelectedTeamID = first.id.uuidString
                    } else {
                        selection = .add
                        lastSelectedTeamID = ""
                    }
                }
            }
            // Edit team
            .fullScreenCover(isPresented: $showingEditTeam) {
                if
                    case let .team(id) = selection,
                    let idx = coach.teams.firstIndex(where: { $0.id == id })
                {
                    TeamEditView(team: $coach.teams[idx])
                }
            }
            // Overview grid of all team cards + plus card
            .fullScreenCover(isPresented: $showingOverview) {
                TeamsOverviewView(
                    coach: coach,
                    currentIndex: indexSelectionBridge, // maps to enum selection
                    lastSelectedTeamID: $lastSelectedTeamID,
                    showingTeamCreation: $showingTeamCreation
                )
            }
        }
        .environment(\.teamTheme, currentTheme)
    }

    // MARK: - Delete

    private func deleteCurrentTeam() {
        guard let currentTeam else { return }
        coach.deleteTeam(currentTeam)

        if coach.teams.isEmpty {
            selection = .add
            lastSelectedTeamID = ""
        } else if let first = coach.teams.first {
            selection = .team(first.id)
            lastSelectedTeamID = first.id.uuidString
        }
    }

    // MARK: - Index <-> Selection Bridge (for components still expecting an index)

    private var indexSelectionBridge: Binding<Int> {
        Binding(
            get: { selectedIndexFromSelection() },
            set: { newIndex in
                if coach.teams.indices.contains(newIndex) {
                    let id = coach.teams[newIndex].id
                    selection = .team(id)
                    lastSelectedTeamID = id.uuidString
                } else {
                    selection = .add
                    lastSelectedTeamID = ""
                }
            }
        )
    }

    private func selectedIndexFromSelection() -> Int {
        switch selection {
        case .team(let id):
            return coach.teams.firstIndex(where: { $0.id == id }) ?? coach.teams.count
        case .add:
            return coach.teams.count
        }
    }
}

#Preview {
    ContentView()
}
