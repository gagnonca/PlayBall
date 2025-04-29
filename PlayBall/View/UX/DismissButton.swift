//
//  DismissButton.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//


import SwiftUI

struct DismissButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(Color.primary.opacity(0.9))
        }
    }
}

#Preview("ColorGradient") {
    ZStack {
        ColorGradient()
        DismissButton {
            print("Dismiss tapped")
        }
    }
}

#Preview("ColorGradient with Blur") {
    ZStack {
        ColorGradient()
            .opacity(0.3)
        DismissButton {
            print("Dismiss tapped")
        }
    }
}
