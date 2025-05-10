//
//  TeamEditView 2.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/28/25.
//

import SwiftUI

struct TeamEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var team: Team

    @State private var teamName: String
    @State private var players: [Player]
    
    @State var gameFormat: GameFormat
    @State var periodLengthMinutes: Int

    init(team: Binding<Team>) {
        _team = team
        _teamName = State(initialValue: team.wrappedValue.name)
        _players = State(initialValue: team.wrappedValue.players)
         _gameFormat = State(initialValue: team.wrappedValue.gameFormat)
        _periodLengthMinutes = State(initialValue: Int(team.wrappedValue.periodLength / 60))
    }

    var body: some View {
        TeamEditorForm(
            teamName: $teamName,
            players: $players,
            gameFormat: $gameFormat,
            periodLengthMinutes: $periodLengthMinutes,
            title: "Edit Team",
            showDelete: true,
            onSave: {
                team.name = teamName
                team.players = players
                team.sortPlayers()
                Coach.shared.updateTeam(team)
                dismiss()
            },
            onCancel: { dismiss() },
            onDelete: {
                Coach.shared.deleteTeam(team)
                dismiss()
            }
        )
    }
}

#Preview("Edit Team") {
    @Previewable @State var mockTeam = Coach.previewCoach.teams.first!

    return TeamEditView(team: $mockTeam)
}
