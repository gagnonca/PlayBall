//
//  PlayerBadge.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import SwiftUI

struct PlayerBadge: View {
    let player: Player
    
    var body: some View {
        Text(player.name)
            .font(.title3.bold())
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(player.tint.opacity(0.25), in: Capsule())
            .overlay(
                Capsule().stroke(player.tint, lineWidth: 1)
            )
    }
}

#Preview {
    PlayerBadge(player: Player(name: "Eliza", tint: .red))
    PlayerBadge(player: Player(name: "Alana", tint: .orange))
    PlayerBadge(player: Player(name: "Lucy", tint: .yellow))
    PlayerBadge(player: Player(name: "Elaina", tint: .green))
    PlayerBadge(player: Player(name: "Haley", tint: .purple))
}
