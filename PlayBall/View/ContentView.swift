//
//  ContentView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var coach = Coach.shared
    @State private var selectedTeam: Team?
    @State private var showingTeamCreation = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            Group {
                if selectedTeam != nil {
                    TeamDetailView(selectedTeam: $selectedTeam, editMode: $editMode)
                } else {
                    emptyView
                }
            }
            .navigationTitle(selectedTeam?.name ?? "Select Team")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        ForEach(coach.teams) { team in
                            Button(team.name) {
                                selectedTeam = team
                                saveSelectedTeam(team)
                            }
                        }
                        Divider()
                        Button {
                            showingTeamCreation = true
                        } label: {
                            Label("Add Team", systemImage: "plus")
                        }
                    } label: {
                        Label("Teams", systemImage: "list.bullet")
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    if let url = Coach.shared.exportToTempFile() {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }

                    Button(editMode == .active ? "Save" : "Edit") {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    }
                }
            }
            .sheet(isPresented: $showingTeamCreation) {
                TeamCreationView { newTeam in
                    coach.addTeam(newTeam)
                    selectedTeam = newTeam
                    showingTeamCreation = false
                }
            }
            .onAppear {
                loadLastSelectedTeam()
            }
        }
    }
    
    private func saveSelectedTeam(_ team: Team) {
        UserDefaults.standard.set(team.id.uuidString, forKey: "selectedTeamID")
    }
    
    private func loadLastSelectedTeam() {
        guard let savedID = UserDefaults.standard.string(forKey: "selectedTeamID"),
              let uuid = UUID(uuidString: savedID),
              let matchedTeam = coach.teams.first(where: { $0.id == uuid })
        else {
            selectedTeam = coach.teams.first
            return
        }
        selectedTeam = matchedTeam
    }
    
    // View when no team is selected or no teams exist
    private var emptyView: some View {
        VStack(spacing: 16) {
            Text("No Team Selected")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Button("Add Your First Team") {
                showingTeamCreation = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ContentView()
}
