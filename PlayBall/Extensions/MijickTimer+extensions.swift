//
//  MijickTimer+extensions.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/13/25.
//


import Foundation
import MijickTimer

extension MTime {
    var totalSeconds: TimeInterval {
        return TimeInterval(hours * 3600 + minutes * 60 + seconds) + TimeInterval(milliseconds) / 1000.0
    }
}

extension TimeInterval {
    func timeRemaining(in cycle: TimeInterval) -> TimeInterval {
        let intoCycle = self.truncatingRemainder(dividingBy: cycle)
        return max(cycle - intoCycle, 0)
    }
}
