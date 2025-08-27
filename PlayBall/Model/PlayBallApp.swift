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
    private let coach = Coach.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(coach)
                .onOpenURL { url in
                    if url.pathExtension == "json" {
                        Coach.shared.importFrom(url: url)
                    }
                }
        }
    }
}
