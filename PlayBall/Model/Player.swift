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
    static let colors: [Color] = [.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .pink]

    static func color(for index: Int) -> Color {
        colors[index % colors.count]
    }
}
