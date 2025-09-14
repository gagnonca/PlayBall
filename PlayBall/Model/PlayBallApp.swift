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
            ContentView()
                .environment(\.teamTheme, .default) 
//                .onOpenURL { url in
//                    if url.pathExtension == "json" {
////                        Coach.shared.importFrom(url: url)
//                    }
//                }
        }
    }
}
