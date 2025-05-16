//
//  GameEditView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/17/25.
//

import SwiftUI

struct GameEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var game: Game
    @Bindable var team: Team

    var body: some View {
        GameEditorForm(
            game: $game,
            team: team,
            title: "Edit Game",
            showDelete: true,
            onSave: {
                Coach.shared.updateTeam(team)
                dismiss()
            },
            onCancel: { dismiss() },
            onDelete: {
                team.removeGame(game)
            }
        )
    }
}

#Preview {
    @Previewable @State var game = Coach.previewCoach.teams.first!.games.first!
    GameEditView(game: $game, team: Coach.previewCoach.teams.first!)
}
