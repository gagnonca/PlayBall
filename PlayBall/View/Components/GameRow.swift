//
//  GameRow.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/18/25.
//

import SwiftUI

struct GameRow: View {
    let game: Game

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(game.name)
                    .font(.subheadline)
                Text(game.date, format: .dateTime.month().day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))

        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GameRow(game: Coach.previewCoach.teams.first!.games.first!)
}
