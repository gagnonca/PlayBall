//
//  Team.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import Foundation

@Observable
class Team: Identifiable {
    let id = UUID()
    var name: String
    var players: [Player]
    var games: [Game]

    init(name: String, players: [Player] = [], games: [Game] = []) {
        self.name = name
        self.players = players
        self.games = games
    }

    func addPlayer(_ player: Player) {
        players.append(player)
    }

    func removePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
    }

    func addGame(_ game: Game) {
        games.append(game)
    }

    func removeGame(_ game: Game) {
        games.removeAll { $0.id == game.id }
    }
}
