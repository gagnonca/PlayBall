//
//  TeamNameSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

struct TeamNameSection: View {
    @Binding var teamName: String
    @FocusState private var isFocused: Bool

    var body: some View {
        GlassCard(title: "Team Name", sfSymbol: "figure.run") {
            TextField("Enter Team Name", text: $teamName)
                .textInputAutocapitalization(.words)
                .foregroundStyle(.primary)
                .textInputAutocapitalization(.words)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
        }
    }
}

#Preview {
    TeamNameSection(teamName: .constant("Mock Team Name"))
    TeamNameSection(teamName: .constant(""))
}
