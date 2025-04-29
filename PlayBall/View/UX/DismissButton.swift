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
                .foregroundStyle(Color.primary)
        }
    }
}

#Preview {
    DismissButton {
        print("Dismiss tapped")
    }
}
