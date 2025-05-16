//
//  Game.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import Foundation

struct Game: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String        // name of the game (e.g. Game 1)
    var date: Date          // date of the game
    var availablePlayers: [Player]  // players who were available for the game
    
    var substitutionStyle: SubstitutionStyle // .short or .long
    var playersOnField: Int                 // number of players on the field (e.g. 4 for 4v4)
    var periodLengthMinutes: Int            // length of each "period" of a game
    var numberOfPeriods: GameFormat    // .quarter = 4, .half = 2
    
    init(
        id: UUID = UUID(),
        name: String,
        date: Date,
        availablePlayers: [Player],
        substitutionStyle: SubstitutionStyle = .short,
        playersOnField: Int = 4,
        periodLengthMinutes: Int = 10,
        numberOfPeriods: GameFormat = .quarter,
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.availablePlayers = availablePlayers
        self.substitutionStyle = substitutionStyle
        self.playersOnField = playersOnField
        self.periodLengthMinutes = periodLengthMinutes
        self.numberOfPeriods = numberOfPeriods
    }
}
