//
//  PlayBallWidgetExtensionBundle.swift
//  PlayBallWidgetExtension
//
//  Created by Corey Gagnon on 4/30/25.
//

import WidgetKit
import SwiftUI

@main
struct PlayBallWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        PlayBallWidgetExtension()
        PlayBallWidgetExtensionControl()
        PlayBallWidgetExtensionLiveActivity()
    }
}
