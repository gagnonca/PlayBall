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
            Image(systemName: "xmark")
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(.gray, in: Circle())
                .opacity(0.8)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        DismissButton {
            print("Dismiss tapped")
        }
    }
}
