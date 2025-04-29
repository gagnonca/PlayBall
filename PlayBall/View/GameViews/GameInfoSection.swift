//
//  GameInfoSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//


import SwiftUI

struct GameInfoSection: View {
    @Binding var gameName: String
    @Binding var gameDate: Date

    var body: some View {
        GlassCard(
            title: "Game Info",
            sfSymbol: "calendar.badge.plus"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Enter Game Name", text: $gameName)
                    .textInputAutocapitalization(.words)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .foregroundStyle(.primary)

                DatePicker("Game Date", selection: $gameDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview("Game Info Section") {
    @Previewable @State var gameName = "Game vs Tigers"
    @Previewable @State var gameDate = Date()

    return GameInfoSection(gameName: $gameName, gameDate: $gameDate)
}
