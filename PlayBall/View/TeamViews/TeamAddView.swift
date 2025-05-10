//
//  TeamAddView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/28/25.
//

import SwiftUI

struct TeamAddView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coach = Coach.shared

    @State private var teamName = ""
    @State private var players: [Player] = []
    
    @State var gameFormat: GameFormat = .quarters
    @State var periodLengthMinutes: Int = 10
    
    let onSave: (Team) -> Void

    var body: some View {
        TeamEditorForm(
            teamName: $teamName,
            players: $players,
            gameFormat: $gameFormat,
            periodLengthMinutes: $periodLengthMinutes,
            title: "Create Team",
            showDelete: false,
            onSave: {
                let newTeam = Team(name: teamName, players: players)
                coach.saveTeam(newTeam)
                onSave(newTeam)
                dismiss()
            },
            onCancel: {
                dismiss()
            },
            onDelete: nil
        )
    }
}

#Preview("Add Team") {
    TeamAddView { _ in print("Saved!") }
}
