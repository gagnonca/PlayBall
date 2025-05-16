//
//  Team.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import Foundation

@Observable
class Team: Identifiable, Codable {
    let id: UUID
    var name: String
    var players: [Player]
    var games: [Game]
    
    // League rules
    var gameFormat: GameFormat
    var periodLengthMinutes: Int

    init(
        id: UUID = UUID(),
        name: String,
        players: [Player] = [],
        games: [Game] = [],
        gameFormat: GameFormat = .quarters,
        periodLengthMinutes: Int = 10
    ) {
        self.id = id
        self.name = name
        self.players = players
        self.games = games
        self.gameFormat = gameFormat
        self.periodLengthMinutes = periodLengthMinutes
    }

    func addPlayer(_ player: Player) {
        players.append(player)
        Coach.shared.saveTeamsToJson()
    }

    func removePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
        Coach.shared.saveTeamsToJson()
    }

    func addGame(_ game: Game) {
        games.append(game)
        Coach.shared.saveTeamsToJson()
    }

    func removeGame(_ game: Game) {
        games.removeAll { $0.id == game.id }
        Coach.shared.saveTeamsToJson()
    }
}
