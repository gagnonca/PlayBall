//
//  TimeControlSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/29/25.
//


import SwiftUI

struct TimeControlSection: View {
    let nextSubTime: TimeInterval?
    let lastSubTime: TimeInterval?
    @Binding var currentTime: TimeInterval
    let quarterLength: TimeInterval

    var body: some View {
        GlassCard(title: "Time Controls", sfSymbol: "clock.arrow.circlepath") {
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    if let last = lastSubTime {
                        Button("⏪ Last Sub") {
                            currentTime = last
                        }
                    }

                    if let next = nextSubTime {
                        Button("Next Sub ⏩") {
                            currentTime = next
                        }
                    }
                }

                HStack {
                    Text("Current Time:")
                    Spacer()
                    Text(currentTime.timeFormatted)
                }

                Slider(value: $currentTime, in: 0...quarterLength, step: 1)
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    @Previewable @State var currentTime: TimeInterval = 270 // 4:30
    TimeControlSection(
        nextSubTime: 300, // 5:00
        lastSubTime: 240, // 4:00
        currentTime: $currentTime,
        quarterLength: 600 // 10:00
    )
}
