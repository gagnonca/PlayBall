//
//  LeagueRulesSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/7/25.
//


import SwiftUI

struct LeagueRulesSection: View {
    @Binding var gameFormat: GameFormat
    @Binding var periodLengthMinutes: Int

    var body: some View {
        GlassCard(title: "League Rules", sfSymbol: "list.bullet.rectangle") {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Format", selection: $gameFormat) {
                    ForEach(GameFormat.allCases, id: \.self) { format in
                        Text(format == .quarters ? "Quarters" : "Halves")
                    }
                }
                .pickerStyle(.segmented)

                Stepper("\(periodLengthMinutes) minutes", value: $periodLengthMinutes, in: 5...45, step: 1)
            }
        }
    }
}
