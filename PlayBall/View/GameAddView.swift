//
//  GameAddView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/17/25.
//

import SwiftUI

struct GameAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var team: Team

    @State private var gameName: String
    @State private var gameDate: Date = Date()
    @State private var selectedPlayers: [Player] = []

    init(team: Team) {
        self.team = team
        _gameName = State(initialValue: "Game \(team.games.count + 1)")
    }

    var body: some View {
        GameEditorForm(
            gameName: $gameName,
            gameDate: $gameDate,
            selectedPlayers: $selectedPlayers,
            team: team,
            onSave: {
                let newGame = Game(name: gameName, date: gameDate, availablePlayers: selectedPlayers)
                team.games.append(newGame)
                Coach.shared.saveTeams()
                dismiss()
            },
            onCancel: { dismiss() },
            title: "New Game"
        )
    }
}

#Preview {
    GameAddView(team: Coach.previewCoach.teams.first!)
}
