//
//  TeamAddView.swift
//  PlayBall
//

import SwiftUI

struct TeamAddView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coach = Coach.shared

    @State private var teamName = ""
    @State private var players: [Player] = []

    var body: some View {
        TeamEditorForm(
            teamName: $teamName,
            players: $players,
            onSave: {
                let newTeam = Team(name: teamName, players: players)
                coach.saveTeam(newTeam)
                dismiss()
            },
            onCancel: {
                dismiss()
            },
            title: "Create Team",
            showDelete: false,
            onDelete: nil
        )
    }
}

#Preview("Add Team") {
    TeamAddView()
}
