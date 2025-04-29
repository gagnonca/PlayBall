//
//  GlassCard.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    var title: String?
    var sfSymbol: String?
    var buttonSymbol: String?
    var onButtonTap: (() -> Void)? = nil
    var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title, let sfSymbol {
                HStack {
                    Label(title, systemImage: sfSymbol)
                        .font(.title3.bold())
                        .padding(.bottom, 4)

                    Spacer()

                    if let buttonSymbol, let onButtonTap {
                        Button(action: onButtonTap) {
                            Image(systemName: buttonSymbol)
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(.bottom, 4)
            }

            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}


#Preview("With Button") {
    GlassCard(
        title: "Games",
        sfSymbol: "calendar",
        buttonSymbol: "plus.circle.fill",
        onButtonTap: {
            print("Add Game tapped")
        }
    ) {
        VStack(alignment: .leading) {
            Text("Game 1")
            Text("Game 2")
            Text("Game 3")
        }
        .foregroundStyle(.white)
    }
}

#Preview("Without Button") {
    GlassCard(
        title: "Roster",
        sfSymbol: "person.3.fill"
    ) {
        VStack(alignment: .leading) {
            Text("Player 1")
            Text("Player 2")
            Text("Player 3")
        }
        .foregroundStyle(.white)
    }
}

