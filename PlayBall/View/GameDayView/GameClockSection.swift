//
//  GameClockSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

/// Displays the current clock state, time, quarter, and control buttons.
struct GameClockSection: View {
    @ObservedObject var handler: GameTimeHandler

    var body: some View {
        GlassCard(title: "Game Clock", sfSymbol: "timer") {
            VStack(spacing: 16) {
                VStack {
                    Text(handler.formattedTime())
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)

                    Text("Quarter \(handler.currentQuarter)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                HStack(spacing: 24) {
                    Button(action: handler.jumpBackward30) {
                        Image(.jumpBackward30)
                    }

                    Button(action: handler.togglePlayPause) {
                        Image( handler.clockState == .running ? .pause : .play)
                            .padding(12)
                            .background(.regularMaterial, in: Circle())
                    }
                    .disabled(handler.clockState == .gameEnd)

                    Button(action: handler.jumpForward30) {
                        Image(.jumpForward30)
                    }
                }
                .font(.title2)
                .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    ZStack {
        ColorGradient()
        ScrollView {
            VStack(spacing: 32) {
                GameClockSection(handler: GameTimeHandler())
            }
            .padding(.top, 40)
        }
    }
}
