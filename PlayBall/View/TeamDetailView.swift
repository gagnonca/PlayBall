//
//  TeamDetailView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import SwiftUI

struct TeamDetailView: View {
    @Binding var selectedTeam: Team?
    @Binding var editMode: EditMode
    @State private var selectedGameID: UUID?
    @State private var showingGameEditor = false
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var team: Team? { selectedTeam }

    var body: some View {
        if let team {
            List {
                GameSectionView(
                    team: team,
                    editMode: $editMode,
                    showingGameEditor: $showingGameEditor
                )
                
                PlayerSectionView(
                    team: team,
                    editMode: $editMode
                )
                
                if editMode == .active {
                    Section {
                        Button {
                            showingDeleteAlert = true
                        } label: {
                            Text("Delete Team")
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .sheet(isPresented: $showingGameEditor) {
                GameAddView(team: team)
            }
            .onChange(of: editMode) {
                if editMode == .inactive {
                    Coach.shared.saveTeams()
                }
            }
            .alert("Delete Team?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    Coach.shared.deleteTeam(team)
                    selectedTeam = Coach.shared.teams.first
                    editMode = .inactive
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will remove the team including all games and players. This cannot be undone.")
            }
        } else {
            Text("Team no longer available.")
                .foregroundStyle(.secondary)
                .padding()
        }
    }
}

#Preview {
    struct TeamDetailPreviewWrapper: View {
        @State private var team: Team? = Coach.previewCoach.teams.first
        @State private var editMode: EditMode = .inactive

        var body: some View {
            NavigationStack {
                if team != nil {
                    TeamDetailView(selectedTeam: $team, editMode: $editMode)
                } else {
                    Text("No team available")
                }
            }
        }
    }

    return TeamDetailPreviewWrapper()
}
