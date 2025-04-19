//
//  SubSegment.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import Foundation

struct SubSegment: Identifiable {
    let id = UUID()
    let on: TimeInterval
    let off: TimeInterval
    let players: [Player]
}

extension SubSegment {
    var onFormatted: String {
        on.timeFormatted
    }

    var offFormatted: String {
        off.timeFormatted
    }
}

extension TimeInterval {
    var timeFormatted: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
