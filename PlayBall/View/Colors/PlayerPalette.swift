//
//  PlayerPalette.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/1/25.
//

import SwiftUI

struct PlayerPalette {
    static let colors: [Color] = [
        .rosewater,
        .pink,
        .mauve,
        .red,
        .peach,
        .yellow,
        .green,
        .sky,
        .blue,
        .lavender,
        .flamingo,
        .maroon,
        .teal,
        .sapphire,
    ]

    static func color(for index: Int) -> Color {
        colors[index % colors.count]
    }
}

extension PlayerPalette {
    static func hexCode(for index: Int) -> String {
        switch index % colors.count {
        case 0: return "#dc8a78" // rosewater
        case 1: return "#ea76cb" // pink
        case 2: return "#8839ef" // mauve
        case 3: return "#d20f39" // red
        case 4: return "#fe640b" // peach
        case 5: return "#df8e1d" // yellow
        case 6: return "#40a02b" // green
        case 7: return "#04a5e5" // sky
        case 8: return "#1e66f5" // blue
        case 9: return "#7287fd" // lavender
        default: return "#999999"
        }
    }
}
