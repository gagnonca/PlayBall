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

    func loadTeams() {
        let url = teamsFileURL
        print(teamsFileURL)
        if !FileManager.default.fileExists(atPath: url.path) {
            copyInitialTeamsFromBundle()
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            print("Failed to load data from documents.")
            return
        }
        decodeTeams(from: data)
    }

    func saveTeamsToJson() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let teamsData = teams.map { TeamData(from: $0) }
            let data = try encoder.encode(teamsData)
            try data.write(to: teamsFileURL, options: [.atomic])
        } catch {
            print("Saving teams failed: \(error.localizedDescription)")
        }
    }

    private func copyInitialTeamsFromBundle() {
        guard let bundleURL = Bundle.main.url(forResource: "teams", withExtension: "json"),
              let data = try? Data(contentsOf: bundleURL) else {
            print("Failed to copy initial teams.")
            return
        }

        try? data.write(to: teamsFileURL, options: [.atomic])
        decodeTeams(from: data)
    }

    private func decodeTeams(from data: Data) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let teamsData = try decoder.decode([TeamData].self, from: data)
            teams = teamsData.map { $0.toTeam() }
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted: \(context.debugDescription)")
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found: \(context.debugDescription)")
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch: \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found: \(context.debugDescription)")
        } catch {
            print("Generic decoding error: \(error.localizedDescription)")
        }

    }
}

/// Preview Coach for UI Previews
extension Coach {
    static var previewCoach: Coach {
        let coach = Coach()
        coach.teams = loadTeamsFromBundle()
        return coach
    }

    static func loadTeamsFromBundle() -> [Team] {
        guard let url = Bundle.main.url(forResource: "teams", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let teams = try decoder.decode([TeamData].self, from: data)
            return teams.map { $0.toTeam() }
        } catch {
            print("❌ Failed to decode preview teams: \(error)")
            return []
        }
    }
}

/// Preview Coach for UI Previews
extension Coach {
    static var previewEmptyCoach: Coach {
        let coach = Coach()
        return coach
    }
}

/// For File sharing to Assistant Coaches
extension Coach {
    @discardableResult
    func export(team: Team) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("PlayBall_\(team.name).json")

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(TeamData(from: team))
            try data.write(to: url, options: [.atomic])
            return url
        } catch {
            print("Export failed:", error)
            return nil
        }
    }

    func importFrom(url: URL) {
        loadTeams(from: url)
        saveTeamsToJson()
    }

    /// Write to an arbitrary URL instead of the sandbox file.
    private func saveTeams(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(teams.map(TeamData.init))
        try data.write(to: url, options: [.atomic])
    }

    /// Load teams from an external file.
    private func loadTeams(from url: URL) {
        guard let data = try? Data(contentsOf: url) else { return }
        decodeTeams(from: data)
    }
}
