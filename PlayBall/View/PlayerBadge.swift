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
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(player.tint.opacity(0.25), in: Capsule())
            .overlay(
                Capsule().stroke(player.tint, lineWidth: 1)
            )
    }
}
