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
            LiveActivityContent(
                period: context.state.quarter,
                currentTime: context.state.currentTime,
                periodLength: context.state.periodLength,
                nextOn: context.state.nextPlayers,
                subCountdown: context.state.nextSubCountdown!)
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

//#Preview("Lock Screen", as: .content, using: PlayBallWidgetLiveActivityAttributes()) {
//    PlayBallWidgetExtensionLiveActivity()
//} contentStates: {
//    PlayBallWidgetLiveActivityAttributes.ContentState(
//        currentTime: 102,
//        quarter: 2,
//        nextPlayers: [
//            Player(name: "Addy", tintHex: "dc8a78"),    // rosewater
//            Player(name: "Lucy", tintHex: "dd7878"),    // flamingo
//            Player(name: "Haley", tintHex: "ea76cb"),   // pink
//            Player(name: "Brooke", tintHex: "8839ef")   // mauve
//        ],
//        nextSubCountdown: 120
//    )
//}
//
//#Preview("Dynamic Island", as: .dynamicIsland(.compact), using: PlayBallWidgetLiveActivityAttributes()) {
//    PlayBallWidgetExtensionLiveActivity()
//} contentStates: {
//    PlayBallWidgetLiveActivityAttributes.ContentState(
//        currentTime: 102,
//        quarter: 2,
//        nextPlayers: [
//            Player(name: "Addy", tintHex: "dc8a78"),
//            Player(name: "Lucy", tintHex: "dd7878"),
//            Player(name: "Haley", tintHex: "ea76cb")
//        ]
//    )
//}
