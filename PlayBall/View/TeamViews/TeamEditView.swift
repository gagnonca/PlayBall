//
//  TeamEditView 2.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/28/25.
//

import SwiftUI

struct TeamEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coach = Coach.shared

    @Binding var team: Team

    var body: some View {
        TeamEditorForm(
            teamName: $team.name,
            players: $team.players,
            onSave: {
                coach.saveTeam(team)
                dismiss()
            },
            onCancel: {
                dismiss()
            },
            title: "Edit Team",
            showDelete: true,
            onDelete: {
                coach.deleteTeam(team)
                dismiss()
            }
        )
    }
}

#Preview("Edit Team") {
    @Previewable @State var mockTeam = Coach.previewCoach.teams.first!

    return TeamEditView(team: $mockTeam)
}
