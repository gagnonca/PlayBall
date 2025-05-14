//
//  PlayBallApp.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//

import SwiftUI
import SwiftData

@main
struct PlayBallApp: App {
    var body: some Scene {
        WindowGroup {
//            var quarterHandler: QuarterHandler = .init()
//            var substitutionHandler: SubstitutionHandler = .init()
//            TimerTestView(quarterTimer: quarterHandler.timer, substitutionTimer: substitutionHandler.timer)
            
            ContentView()
                .onOpenURL { url in
                    if url.pathExtension == "json" {
                        Coach.shared.importFrom(url: url)
                    }
                }
        }
    }
}
