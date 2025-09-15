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
    var matchFormat: MatchFormat
    var gameFormat: GameFormat
    var periodLengthMinutes: Int
    
    // Team colors
    var colors: TeamColors? = nil
    
    // Optional emoji mascot
    var mascotEmoji: String? = nil

    init(
        id: UUID = UUID(),
        name: String,
        players: [Player] = [],
        games: [Game] = [],
        matchFormat: MatchFormat = .fourVFour,
        gameFormat: GameFormat = .quarter,
        periodLengthMinutes: Int = 10,
        colors: TeamColors? = nil,
        mascotEmoji: String? = nil
    ) {
        self.id = id
        self.name = name
        self.players = players
        self.games = games
        self.matchFormat = matchFormat
        self.gameFormat = gameFormat
        self.periodLengthMinutes = periodLengthMinutes
        self.colors = colors
        self.mascotEmoji = mascotEmoji
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

extension Team {
    struct TeamColors: Codable, Hashable {
        var homeHex: String
        var awayHex: String
    }
}
