//
//  GameClockSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

//
//  GameClockSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

struct GameClockSection: View {
    var currentTimeFormatted: String
    @Binding var currentQuarter: Int
    var timerRunning: Bool
    var toggleTimer: () -> Void

    var nextSubTime: TimeInterval?
    var lastSubTime: TimeInterval?
    @Binding var currentTime: TimeInterval
    var quarterLength: TimeInterval
    var totalQuarters: Int

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

                HStack(spacing: 24) {
                    // Previous Sub
                    let canJumpBackToSub = lastSubTime != nil && lastSubTime! <= quarterLength
                    Button {
                        if canJumpBackToSub {
                            currentTime = lastSubTime!
                        }
                    } label: {
                        Image(systemName: "arrowtriangle.backward.fill")
                            .foregroundStyle(.primary.opacity(canJumpBackToSub ? 1 : 0.3))
                    }

                    // -30 Seconds
                    let canGoBack30 = currentTime >= 30
                    Button {
                        if canGoBack30 {
                            currentTime = max(0, currentTime - 30)
                        }
                    } label: {
                        Image(systemName: "30.arrow.trianglehead.counterclockwise")
                            .foregroundStyle(.primary.opacity(canGoBack30 ? 1 : 0.3))
                    }

                    // Play / Pause
                    Button(action: toggleTimer) {
                        Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                            .padding(12)
                            .background(.regularMaterial, in: Circle())
                            .foregroundStyle(.primary)
                    }

                    // +30 Seconds
                    let canGoForward30 = currentTime + 30 <= quarterLength
                    Button {
                        if canGoForward30 {
                            currentTime = min(quarterLength, currentTime + 30)
                        }
                    } label: {
                        Image(systemName: "30.arrow.trianglehead.clockwise")
                            .foregroundStyle(.primary.opacity(canGoForward30 ? 1 : 0.3))
                    }

                    // Next Sub
                    let canJumpForwardToSub = nextSubTime != nil && nextSubTime! <= quarterLength
                    Button {
                        if canJumpForwardToSub {
                            currentTime = nextSubTime!
                        }
                    } label: {
                        Image(systemName: "arrowtriangle.forward.fill")
                            .foregroundStyle(.primary.opacity(canJumpForwardToSub ? 1 : 0.3))
                    }
                }
                .font(.title2)

                .font(.title2)
                .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    @Previewable @State var currentTime: TimeInterval = 84
    @Previewable @State var currentQuarter = 1

    ZStack {
        ColorGradient()
        ScrollView {
            VStack(spacing: 32) {
                GameClockSection(
                    currentTimeFormatted: "1:24",
                    currentQuarter: $currentQuarter,
                    timerRunning: false,
                    toggleTimer: {},
                    nextSubTime: 120,
                    lastSubTime: 60,
                    currentTime: $currentTime,
                    quarterLength: 600,
                    totalQuarters: 4
                )
            }
            .padding(.top, 40)
        }
    }
}
