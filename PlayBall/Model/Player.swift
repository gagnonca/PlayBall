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
