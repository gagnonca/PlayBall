//
//  ThemeEnvironment.swift
//  PlayBall
//
//  Created by Corey Gagnon on 9/14/25.
//

import SwiftUI

struct TeamTheme: Equatable {
    var start: Color
    var end: Color
}

extension TeamTheme {
    static let `default` = TeamTheme(
        start: .green,
        end: .pink
    )
}

private struct TeamThemeKey: EnvironmentKey {
    static let defaultValue: TeamTheme = .default
}

extension EnvironmentValues {
    var teamTheme: TeamTheme {
        get { self[TeamThemeKey.self] }
        set { self[TeamThemeKey.self] = newValue }
    }
}
