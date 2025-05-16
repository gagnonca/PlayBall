//
//  Enums.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/16/25.
//

import Foundation

enum MatchFormat: Int, CaseIterable, Identifiable, Codable {
    case fourVFour = 4
    case fiveVFive = 5
    case sevenVSeven = 7
    case elevenVEleven = 11

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .fourVFour: return "4v4"
        case .fiveVFive: return "5v5"
        case .sevenVSeven: return "7v7"
        case .elevenVEleven: return "11v11"
        }
    }

    var playersOnField: Int {
        rawValue
    }
}

enum GameFormat: Int, Codable, CaseIterable {
    case quarter = 4
    case half = 2
    
    var displayName: String {
        switch self {
        case .quarter: "Quarter"
        case .half: "Half"
        }
    }
}

enum SubstitutionStyle: String, Codable, CaseIterable {
    case long
    case short

    var displayName: String {
        switch self {
        case .long: "Long"
        case .short: "Short"
        }
    }
}
