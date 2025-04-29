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

    @State private var gameName: String
    @State private var gameDate: Date = Date()
    @State private var availablePlayers: [Player] = []

    init(team: Team) {
        self.team = team
        _gameName = State(initialValue: "Game \(team.games.count + 1)")
    }

    var body: some View {
        GameEditorForm(
            gameName: $gameName,
            gameDate: $gameDate,
            availablePlayers: $availablePlayers,
            team: team,
            title: "New Game",
            showDelete: false,
            onSave: {
                let newGame = Game(name: gameName, date: gameDate, availablePlayers: availablePlayers)
                team.addGame(newGame)
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
