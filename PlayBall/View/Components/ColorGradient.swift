//
//  ColorGradient.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/26/25.
//

import SwiftUI

struct ColorGradient: View {
    @Environment(\.teamTheme) private var theme

    var start: Color = .green
    var end: Color = .pink
    var body: some View {
        LinearGradient(
            colors: [theme.start, theme.end],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ColorGradient()
}
