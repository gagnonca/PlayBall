//
//  GlassCard.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    var title: String
    var sfSymbol: String
    var buttonSymbol: String?
    var onButtonTap: (() -> Void)? = nil
    var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: sfSymbol)
                    .font(.headline.bold())
                    .padding(.bottom, 4)

                Spacer()

                if let buttonSymbol, let onButtonTap {
                    Button(action: onButtonTap) {
                        Image(systemName: buttonSymbol)
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            .padding(.bottom, 4)
        
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

#Preview("Font Size") {
    let title = "Games"
    let sfSymbol = "calendar"
    
    Label("LargeTitle", systemImage: sfSymbol)
        .font(.largeTitle.bold())
        .padding(.bottom, 4)
    Label("Title", systemImage: sfSymbol)
        .font(.title.bold())
        .padding(.bottom, 4)
    Label("Title2", systemImage: sfSymbol)
        .font(.title2.bold())
        .padding(.bottom, 4)
    Label("Title3", systemImage: sfSymbol)
        .font(.title3.bold())
        .padding(.bottom, 4)
    Label("Headline", systemImage: sfSymbol)
        .font(.headline.bold())
        .padding(.bottom, 4)
    Label("Subheadline", systemImage: sfSymbol)
        .font(.subheadline.bold())
        .padding(.bottom, 4)
    Label("Body", systemImage: sfSymbol)
        .font(.body.bold())
        .padding(.bottom, 4)
    Label("Footnote", systemImage: sfSymbol)
        .font(.footnote.bold())
        .padding(.bottom, 4)
    Label("Callout", systemImage: sfSymbol)
        .font(.callout.bold())
        .padding(.bottom, 4)
    Label("Caption", systemImage: sfSymbol)
        .font(.caption.bold())
        .padding(.bottom, 4)
    Label("Caption2", systemImage: sfSymbol)
        .font(.caption2.bold())
        .padding(.bottom, 4)
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
    }
}

