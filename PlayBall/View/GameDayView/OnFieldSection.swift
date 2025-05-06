//
//  OnFieldSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

struct OnFieldSection: View {
    var players: [Player]

    var body: some View {
        GlassCard(title: "On Field", sfSymbol: "sportscourt") {
            VStack {
                if players.isEmpty {
                    Text("No players on field")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    FlowLayout(items: players, spacing: 8) { player in
                        PlayerBadge(player: player)
                    }
                }
            }
        }
    }
}

#Preview ("On Field Section") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 64/255, green: 160/255, blue: 43/255),
                Color(red: 136/255, green: 57/255, blue: 239/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 32) {
                OnFieldSection(players: [
                    Player(name: "Alana", tint: .purple),
                    Player(name: "Lucy", tint: .blue),
                    Player(name: "Elaina", tint: .cyan),
                    Player(name: "Amelia", tint: .orange)
                ])
                OnFieldSection(players: [])
            }
            .padding(.top, 40)
        }
    }
}
