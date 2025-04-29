//
//  TeamNameSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//


//
//  TeamNameSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

struct TeamNameSection: View {
    @Binding var teamName: String

    var body: some View {
        GlassCard(title: "Team Name", sfSymbol: "pencil") {
            TextField("Enter Team Name", text: $teamName)
                .textInputAutocapitalization(.words)
                .font(.title3)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .foregroundStyle(.white)
        }
    }
}

#Preview {
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
                TeamNameSection(teamName: .constant("Mock Team Name"))
                TeamNameSection(teamName: .constant(""))
            }
            .padding(.top, 40)
        }
    }
}
