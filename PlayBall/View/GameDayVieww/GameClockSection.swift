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
    var elapsedTime: TimeInterval
    var quarterLength: TimeInterval
    var nextSubTime: TimeInterval?
    var lastSubTime: TimeInterval?

    var toggleTimer: () -> Void
    var jumpBack30: () -> Void
    var jumpForward30: () -> Void
    var jumpToLastSub: () -> Void
    var jumpToNextSub: () -> Void

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

                let quarterOffset = Double(currentQuarter - 1) * quarterLength

                let canJumpBack30 = elapsedTime >= 30
                let canJumpForward30 = elapsedTime + 30 <= quarterLength
                let canJumpToLastSub = lastSubTime != nil && lastSubTime! - quarterOffset >= 0
                let canJumpToNextSub = nextSubTime != nil && nextSubTime! - quarterOffset <= quarterLength

                HStack(spacing: 24) {
                    Button(action: jumpToLastSub) {
                        Image(systemName: "arrowtriangle.backward.fill")
                            .opacity(canJumpToLastSub ? 1 : 0.5)
                    }
                    .disabled(!canJumpToLastSub)

                    Button(action: jumpBack30) {
                        Image(systemName: "30.arrow.trianglehead.counterclockwise")
                            .opacity(canJumpBack30 ? 1 : 0.5)
                    }
                    .disabled(!canJumpBack30)

                    Button(action: toggleTimer) {
                        Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                            .padding(12)
                            .background(.regularMaterial, in: Circle())
                    }

                    Button(action: jumpForward30) {
                        Image(systemName: "30.arrow.trianglehead.clockwise")
                            .opacity(canJumpForward30 ? 1 : 0.5)
                    }
                    .disabled(!canJumpForward30)

                    Button(action: jumpToNextSub) {
                        Image(systemName: "arrowtriangle.forward.fill")
                            .opacity(canJumpToNextSub ? 1 : 0.5)
                    }
                    .disabled(!canJumpToNextSub)
                }
                .font(.title2)
                .foregroundStyle(.primary)
            }
        }
    }
}

#Preview("Normal State (Playing, mid-quarter)") {
    @Previewable @State var currentQuarter = 1

    ZStack {
        ColorGradient()
        ScrollView {
            VStack(spacing: 32) {
                GameClockSection(
                    currentTimeFormatted: "4:30",
                    currentQuarter: $currentQuarter,
                    timerRunning: true,
                    elapsedTime: 270, // 4 min 30 sec
                    quarterLength: 600,
                    nextSubTime: 300,
                    lastSubTime: 240,
                    toggleTimer: {},
                    jumpBack30: {},
                    jumpForward30: {},
                    jumpToLastSub: {},
                    jumpToNextSub: {}
                )
            }
            .padding(.top, 40)
        }
    }
}

#Preview("Disabled Back Buttons (at 0:00)") {
    @Previewable @State var currentQuarter = 1

    ZStack {
        ColorGradient()
        ScrollView {
            VStack(spacing: 32) {
                GameClockSection(
                    currentTimeFormatted: "0:00",
                    currentQuarter: $currentQuarter,
                    timerRunning: false,
                    elapsedTime: 0,
                    quarterLength: 600,
                    nextSubTime: 100,
                    lastSubTime: nil, // no previous sub
                    toggleTimer: {},
                    jumpBack30: {},
                    jumpForward30: {},
                    jumpToLastSub: {},
                    jumpToNextSub: {}
                )
            }
            .padding(.top, 40)
        }
    }
}

#Preview("Disabled Forward Buttons (at 10:00)") {
    @Previewable @State var currentQuarter = 4

    ZStack {
        ColorGradient()
        ScrollView {
            VStack(spacing: 32) {
                GameClockSection(
                    currentTimeFormatted: "10:00",
                    currentQuarter: $currentQuarter,
                    timerRunning: false,
                    elapsedTime: 600,
                    quarterLength: 600,
                    nextSubTime: nil, // no next sub
                    lastSubTime: 540,
                    toggleTimer: {},
                    jumpBack30: {},
                    jumpForward30: {},
                    jumpToLastSub: {},
                    jumpToNextSub: {}
                )
            }
            .padding(.top, 40)
        }
    }
}
