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

    @State private var gameName: String
    @State private var gameDate: Date
    @State private var availablePlayers: [Player]

    init(game: Binding<Game>, team: Team) {
        _game = game
        _gameName = State(initialValue: game.wrappedValue.name)
        _gameDate = State(initialValue: game.wrappedValue.date)
        _availablePlayers = State(initialValue: game.wrappedValue.availablePlayers)
        self.team = team
    }

    var body: some View {
        GameEditorForm(
            gameName: $gameName,
            gameDate: $gameDate,
            availablePlayers: $availablePlayers,
            team: team,
            onSave: {
                game.name = gameName
                game.date = gameDate
                game.availablePlayers = availablePlayers
//                Coach.shared.saveTeamsToJson()
                Coach.shared.updateTeam(team)
                dismiss()
            },
            onCancel: { dismiss() },
            title: "Edit Game"
        )
    }
}

#Preview {
    @Previewable @State var game = Coach.previewCoach.teams.first!.games.first!
    GameEditView(game: $game, team: Coach.previewCoach.teams.first!)
}
