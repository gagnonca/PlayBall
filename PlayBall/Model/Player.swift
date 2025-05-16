//
//  Player.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import SwiftUI

struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var tintHex: String
    
    var tint: Color {
        Color(hex: tintHex)
    }

    init(id: UUID = UUID(), name: String, tintHex: String = "#f5e0dc") {
        self.id = id
        self.name = name
        self.tintHex = tintHex
    }
}

extension Array where Element == Player {
    var sortedByName: [Player] {
        self.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
