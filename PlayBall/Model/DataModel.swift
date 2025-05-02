//
//  DataModel.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//


import SwiftUI

struct TeamData: Codable {
    let name: String
    let players: [PlayerData]
    let games: [GameData]

    init(from team: Team) {
        self.name = team.name
        self.players = team.players.map { PlayerData(from: $0) }
        self.games = team.games.map { GameData(from: $0) }
    }

    func toTeam() -> Team {
        var players = self.players.map { $0.toPlayer() }
        for (index, _) in players.enumerated() {
            players[index].tint = PlayerPalette.color(for: index)
        }
        let games = self.games.map { $0.toGame(withPlayers: players) }
        return Team(name: name, players: players, games: games)
    }
}

struct PlayerData: Codable {
    let name: String

    init(from player: Player) {
        self.name = player.name
    }

    func toPlayer() -> Player {
        Player(name: name)
    }
}

struct GameData: Codable {
    let name: String
    let date: Date
    let availablePlayers: [String]

    init(from game: Game) {
        self.name = game.name
        self.date = game.date
        self.availablePlayers = game.availablePlayers.map(\.name)
    }

    func toGame(withPlayers allPlayers: [Player]) -> Game {
        let matchedPlayers = allPlayers.filter { availablePlayers.contains($0.name) }
        return Game(name: name, date: date, availablePlayers: matchedPlayers)
    }
}

