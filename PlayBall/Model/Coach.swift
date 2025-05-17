//
//  Coach.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import Foundation

@Observable
class Coach {
    static let shared = Coach()

    var teams: [Team] = []
    
    init() {
        loadTeams()
    }

    func saveTeam(_ team: Team) {
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            teams[index] = team
        } else {
            teams.append(team)
        }
        saveTeamsToJson()
    }

    func updateTeam(_ updatedTeam: Team) {
        guard let index = teams.firstIndex(where: { $0.id == updatedTeam.id }) else { return }
        teams[index] = updatedTeam
        saveTeamsToJson()
    }
        
    func deleteTeam(_ team: Team) {
        teams.removeAll { $0.id == team.id }
        saveTeamsToJson()
    }

    var games: [Game] {
        teams.flatMap { $0.games }
    }
}

extension Coach {

    private var teamsFileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("teams.json")
    }

    func saveTeamsToJson() {
        DataModel.shared.save(teams: teams)
    }

    func loadTeams() {
        let url = teamsFileURL
        if !FileManager.default.fileExists(atPath: url.path) {
            teams = DataModel.shared.loadTeamsFromBundle()
            DataModel.shared.save(teams: teams)
            return
        }

        teams = DataModel.shared.loadTeams()
    }

}

/// Preview Coach for UI Previews
extension Coach {
    static var previewCoach: Coach {
        let coach = Coach()
        coach.teams = DataModel.shared.loadTeamsFromBundle()
        return coach
    }
    static var previewEmptyCoach: Coach {
        let coach = Coach()
        return coach
    }
}

/// For File sharing to Assistant Coaches
extension Coach {
    @discardableResult
    func export(team: Team) -> URL? {
        return DataModel.shared.export(team: team)
    }

    func importFrom(url: URL) {
        guard let importedTeam = DataModel.shared.importTeam(from: url) else { return }
        saveTeam(importedTeam)
    }
}
