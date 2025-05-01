//
//  StaticPlayerBadge.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/30/25.
//

import SwiftUI

struct StaticPlayerBadge: View {
    let name: String
    let tint: Color

    var body: some View {
        Text(name)
            .font(.subheadline)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(tint.opacity(0.25), in: Capsule())
            .overlay(
                Capsule().stroke(tint, lineWidth: 2)
            )
    }
}

#Preview {
    StaticPlayerBadge(name: "Haley", tint: .purple)
}
