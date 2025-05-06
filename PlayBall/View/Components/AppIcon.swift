//
//  for.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/6/25.
//


import SwiftUI

/// A centralized enum for all SF Symbols used in PlayBall.
enum AppIcon: String {
    // Editing / Adding / Deleting
    case edit = "slider.horizontal.3"
    case add = "plus.circle.fill"
    case share = "square.and.arrow.up"
    case delete = "trash"
    case remove = "minus.circle.fill"
    case reorder = "line.3.horizontal"
    
    // Timer Management
    case pause = "pause.fill"
    case play = "play.fill"
    case jumpForward30 = "30.arrow.trianglehead.clockwise"
    case jumpBackward30 = "30.arrow.trianglehead.counterclockwise"
    
    // People / Teams
    case team = "person.3.fill"
    case playerAdd = "person.fill.badge.plus"
    
    // Settings / Misc
    case calendar = "calendar"
    case dismiss = "xmark.circle.fill"
    case chevronRight = "chevron.right"
    case save = "checkmark.circle.fill"
    case back = "chevron.backward.circle.fill"
    case menu = "chevron.down"
}

extension Image {
    /// Initializes an Image using an AppIcon.
    init(_ icon: AppIcon) {
        self.init(systemName: icon.rawValue)
    }
}
