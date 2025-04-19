//
//  TeamData.swift
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
        let players = self.players.map { $0.toPlayer() }
        let games = self.games.map { $0.toGame(withPlayers: players) }
        return Team(name: name, players: players, games: games)
    }
}

struct PlayerData: Codable {
    let name: String
    let tint: String

    init(from player: Player) {
        self.name = player.name
        self.tint = player.tint.description // Adjust if needed
    }

    func toPlayer() -> Player {
        Player(name: name, tint: color)
    }

    var color: Color {
        switch tint.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "cyan": return .cyan
        case "teal": return .teal
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink": return .pink
        default: return .gray
        }
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

