//
//  Game.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import Foundation

struct Game: Identifiable, Hashable {
    let id = UUID()
    var name: String        // name of the game (e.g. Game 1)
    var date: Date          // date of the game
    var availablePlayers: [Player]  // players who were available for the game
    
    var substitutionStyle: SubstitutionStyle = .long
    var playersOnField: Int = 4
    var periodLengthMinutes: Int = 10
    var numberOfPeriods: Int = 4
}
