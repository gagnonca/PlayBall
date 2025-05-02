//
//  Player.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import SwiftUI

struct Player: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var tint: Color = .rosewater
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


