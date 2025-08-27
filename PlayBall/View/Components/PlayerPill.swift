//
//  PlayerPill.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import SwiftUI

struct PlayerPill: View {
    let name: String
    let tint: Color

    var body: some View {
        Text(name)
            .font(.subheadline)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(tint.opacity(0.25), in: Capsule())
            .overlay(
                Capsule().stroke(tint, lineWidth: 2)
            )
    }
}

#Preview("PlayerPill Palette Preview") {
    ScrollView(.horizontal, showsIndicators: false) {
        VStack(spacing: 12) {
            ForEach(PlayerPalette.colors.indices, id: \.self) { index in
                let player = Player(
                    name: "Haley",
                    tintHex: PlayerPalette.hexCode(for: index)
                )
                PlayerPill(name:player.name, tint: player.tint)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
