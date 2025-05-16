//
//  TimeInterval+Format.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/10/25.
//

import Foundation

extension TimeInterval {
    var timeFormatted: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

//extension TimeInterval {
//    func timeFormatted() -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second]
//        formatter.zeroFormattingBehavior = .pad
//        return formatter.string(from: self) ?? "--:--"
//    }
//}

