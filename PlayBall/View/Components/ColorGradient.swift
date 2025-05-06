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
                .pink,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ColorGradient()
}
