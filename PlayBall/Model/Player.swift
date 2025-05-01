//
//  Player.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import SwiftUI

struct Player: Identifiable, Hashable {
    let id = UUID()
    var name: String    // name of the player
    var tint: Color     // tint color used for UI elements
}

struct PlayerPalette {
    static let colors: [Color] = [
        .rosewater,
//        .flamingo,
        .pink,
        .mauve,
        .red,
//        .maroon,
        .peach,
        .yellow,
        .green,
//        .teal,
        .sky,
//        .sapphire,
        .blue,
        .lavender
    ]

    static func color(for index: Int) -> Color {
        colors[index % colors.count]
    }
}

#Preview("PlayerBadge Palette Preview") {
    ScrollView(.horizontal, showsIndicators: false) {
        VStack(spacing: 12) {
            ForEach(PlayerPalette.colors.indices, id: \.self) { index in
                PlayerBadge(player:Player(
                    name: "Haley",
                    tint: PlayerPalette.color(for: index)
                ))
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

