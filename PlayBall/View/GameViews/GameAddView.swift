//
//  GameAddView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/28/25.
//

import SwiftUI

struct GameAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var team: Team
    @State private var game: Game

    init(team: Team) {
        self.team = team
        _game = State(initialValue: Game(
            name: "Game \(team.games.count + 1)",
            date: Date(),
            availablePlayers: [],
        ))
    }

    var body: some View {
        GameEditorForm(
            game: $game,
            team: team,
            title: "New Game",
            showDelete: false,
            onSave: {
                team.addGame(game)
                dismiss()
            },
            onCancel: { dismiss() },
            onDelete: nil
        )
    }
}

#Preview {
    GameAddView(team: Coach.previewCoach.teams.first!)
}
