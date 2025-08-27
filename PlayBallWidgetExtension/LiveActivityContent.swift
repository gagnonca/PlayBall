//
//  LiveActivityContent.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/14/25.
//

import SwiftUI
import ActivityKit
import WidgetKit

struct LiveActivityContent: View {
    let period: Int
    let currentTime: TimeInterval
    let periodLength: TimeInterval
    let nextOn: [Player]
    let subCountdown: TimeInterval

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 64) {
                VStack(spacing: 4) {
                    Text("Quarter")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Q\(period)")
                        .font(.title.bold())
                }

                VStack(alignment: .center, spacing: 2) {
                    Text("Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timerInterval: currentTime.toTimerInterval(upTo: periodLength), countsDown: false)
                        .font(.title.bold())
                        .frame(maxWidth: 85)
                }
            }

            VStack(spacing: 8) {
                HStack {
                    Text("Next on in")
                    Text(timerInterval: Date()...Date().addingTimeInterval(subCountdown), countsDown: true)
                        .monospacedDigit()
                        .frame(maxWidth: 85)
                }
                .font(.title3)
                .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    ForEach(nextOn, id: \..self) { player in
                        PlayerPill(name: player.name, tint: Color(hex: player.tintHex))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background {
            ColorGradient()
                .opacity(0.3)
        }
    }
}

private extension TimeInterval {
    func toTimerInterval(upTo limit: TimeInterval) -> ClosedRange<Date> {
        let now = Date()
        return now.addingTimeInterval(-self)...now.addingTimeInterval(limit - self)
    }
}

#Preview("Live Activity", as: .content, using: PlayBallWidgetLiveActivityAttributes.preview) {
    PlayBallWidgetExtensionLiveActivity()
} contentStates: {
    PlayBallWidgetLiveActivityAttributes.ContentState(
        currentTime: 500,
        periodLength: 600,
        quarter: 2,
        nextPlayers: [
            Player(name: "Addy", tintHex: "dc8a78"),
            Player(name: "Lucy", tintHex: "8839ef"),
            Player(name: "Haley", tintHex: "fe640b"),
            Player(name: "Eliza", tintHex: "1e66f5")
        ],
        nextSubCountdown: 90
    )
}
