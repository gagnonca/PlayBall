//
//  GameRow.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/18/25.
//


//
//  GameRow.swift
//  PlayBall
//

import SwiftUI

struct GameRow: View {
    let game: Game

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(game.name)
                    .font(.body)
                Text(game.date, format: .dateTime.month().day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GameRow(game: Coach.previewCoach.teams.first!.games.first!)
        .previewLayout(.sizeThatFits)
}
