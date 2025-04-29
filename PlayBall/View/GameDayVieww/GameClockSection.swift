//
//  GameClockSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//


import SwiftUI

struct GameClockSection: View {
    var currentTimeFormatted: String
    var currentQuarter: Int
    var timerRunning: Bool
    var toggleTimer: () -> Void

    var body: some View {
        GlassCard(title: "Game Clock", sfSymbol: "timer") {
            VStack(spacing: 16) {
                VStack {
                    Text(currentTimeFormatted)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)

                    Text("Quarter \(currentQuarter)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .center)


                Button(action: {
                    toggleTimer()
                }) {
                    Label(timerRunning ? "Pause" : "Start", systemImage: timerRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title3)
                        .padding()
                        .padding(.horizontal, 32)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(Color.accentColor)
                }
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
                GameClockSection(
                    currentTimeFormatted: "1:24",
                    currentQuarter: 1,
                    timerRunning: false,
                    toggleTimer: {}
                )

                GameClockSection(
                    currentTimeFormatted: "3:12",
                    currentQuarter: 1,
                    timerRunning: true,
                    toggleTimer: {}
                )
            }
            .padding(.top, 40)
        }
    }
}
