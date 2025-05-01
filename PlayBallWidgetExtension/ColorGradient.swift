//
//  ColorGradient.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/30/25.
//

import SwiftUI

struct ColorGradient: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 64/255, green: 160/255, blue: 43/255),
                Color(red: 136/255, green: 57/255, blue: 239/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
