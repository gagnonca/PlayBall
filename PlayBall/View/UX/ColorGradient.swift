//
//  ColorGradient.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/26/25.
//

import SwiftUI

struct ColorGradient: View {
    var body: some View {
        LinearGradient(
            colors: [
                .green,
                .mauve,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct TestGradientListView: View {
    @State private var editMode: EditMode = .inactive
    @State private var mockTeam = Team(
        name: "Mock Team",
        players: [
            Player(name: "Player 1", tint: .red),
            Player(name: "Player 2", tint: .orange),
            Player(name: "Player 3", tint: .yellow),
            Player(name: "Player 4", tint: .green),
            Player(name: "Player 5", tint: .blue),
            Player(name: "Player 6", tint: .purple)
        ]
    )

    var body: some View {
        NavigationStack {
            List {
                Section("Team") {
                    ForEach(mockTeam.players) { player in
                        Text(player.name)
                    }
                    .listRowBackground(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    )

                }
                Section("Team Again") {
                    ForEach(mockTeam.players) { player in
                        Text(player.name)
                    }
                    .listRowBackground(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    )
                }

            }
            .scrollContentBackground(.hidden)
            .background(ColorGradient())
            .environment(\.editMode, $editMode)
            .navigationTitle("Mock Team")
        }
    }
}

#Preview {
    TestGradientListView()
}

#Preview {
    ColorGradient()
}
