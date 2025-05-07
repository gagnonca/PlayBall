//
//  PlayBallWidgetExtensionLiveActivity.swift
//  PlayBallWidgetExtension
//
//  Created by Corey Gagnon on 4/30/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PlayBallWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PlayBallWidgetLiveActivityAttributes.self) { context in
            VStack(spacing: 16) {
                // Quarter & Time Section
                HStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Text("Quarter")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Q\(context.state.quarter)")
                            .font(.title2.bold())
                    }

                    VStack(spacing: 4) {
                        Text("Time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(context.state.currentTime.formattedTime)
                            .monospacedDigit()
                            .font(.title2.bold())
                    }
                }

                if let countdown = context.state.nextSubCountdown {
                    VStack(spacing: 8) {
                        Text("Next on in \(countdown.formattedTime)")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 6) {
                            ForEach(context.state.nextPlayers, id: \.self) { player in
                                StaticPlayerBadge(name: player.name, tint: Color(hex: player.tintHex))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background {
                ColorGradient()
                    .opacity(0.3)
            }
        }
        dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    Text("Q\(context.state.quarter)")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.currentTime))s")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Next: \(context.state.nextPlayers.map(\.name).joined(separator: ", "))")
                        .font(.caption)
                }
            } compactLeading: {
                Text("Q\(context.state.quarter)")
            } compactTrailing: {
                Text("\(Int(context.state.currentTime))s")
            } minimal: {
                Text("⚽️")
            }
        }
    }
}

extension TimeInterval {
    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview("Lock Screen", as: .content, using: PlayBallWidgetLiveActivityAttributes()) {
    PlayBallWidgetExtensionLiveActivity()
} contentStates: {
    PlayBallWidgetLiveActivityAttributes.ContentState(
        currentTime: 102,
        quarter: 2,
        isRunning: true,
        nextPlayers: [
            LivePlayer(name: "Addy", tintHex: "dc8a78"),    // rosewater
            LivePlayer(name: "Lucy", tintHex: "dd7878"),    // flamingo
            LivePlayer(name: "Haley", tintHex: "ea76cb"),   // pink
            LivePlayer(name: "Brooke", tintHex: "8839ef")   // mauve
        ],
        nextSubCountdown: 120
    )
}

#Preview("Dynamic Island", as: .dynamicIsland(.compact), using: PlayBallWidgetLiveActivityAttributes()) {
    PlayBallWidgetExtensionLiveActivity()
} contentStates: {
    PlayBallWidgetLiveActivityAttributes.ContentState(
        currentTime: 102,
        quarter: 2,
        isRunning: true,
        nextPlayers: [
            LivePlayer(name: "Addy", tintHex: "dc8a78"),
            LivePlayer(name: "Lucy", tintHex: "dd7878"),
            LivePlayer(name: "Haley", tintHex: "ea76cb")
        ]
    )
}
