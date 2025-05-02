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

#Preview("PlayerBadge Palette Preview") {
    ScrollView(.horizontal, showsIndicators: false) {
        VStack(spacing: 12) {
            ForEach(PlayerPalette.colors.indices, id: \.self) { index in
                PlayerBadge(player:Player(
                    name: "Haley",
                    tint: PlayerPalette.color(for: index))
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
