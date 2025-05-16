//
//  DataModel.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//


import Foundation

final class DataModel {
    static let shared = DataModel()

    private init() {}

    // MARK: - Save / Load Teams to local file system
    func save(teams: [Team]) {
        do {
            let url = teamsFileURL
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(teams)
            try data.write(to: url, options: .atomic)
        } catch {
            print("❌ Failed to save teams:", error)
        }
    }

    func loadTeams() -> [Team] {
        let url = teamsFileURL
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Team].self, from: data)
        } catch {
            print("❌ Failed to load teams:", error)
            return []
        }
    }

    // MARK: - File URL

    private var teamsFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("teams.json")
    }
}

/// File Sharing Helpers
extension DataModel {
    func export(team: Team) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("PlayBall_\(team.name).json")

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(team)
            try data.write(to: url, options: [.atomic])
            return url
        } catch {
            print("Export failed:", error)
            return nil
        }
    }

    func importTeam(from url: URL) -> Team? {
        guard let data = try? Data(contentsOf: url) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(Team.self, from: data)
        } catch {
            print("❌ Failed to import team:", error)
            return nil
        }
    }

}
