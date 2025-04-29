//
//  TeamEditView.swift
//  PlayBall
//

import SwiftUI

struct TeamEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var team: Team

    var body: some View {
        TeamForm(
            teamName: $team.name,
            players: $team.players,
            onSave: {
                Coach.shared.saveTeam(team)
                dismiss()
            },
            onCancel: {
                dismiss()
            },
            title: "Edit Team"
        )
    }
}

#Preview("Edit Team") {
    @Previewable @State var mockTeam = Coach.previewCoach.teams.first!

    return TeamEditView(team: $mockTeam)
}
