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
            .font(.subheadline)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(player.tint.opacity(0.25), in: Capsule())
            .overlay(
                Capsule().stroke(player.tint, lineWidth: 2)
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
