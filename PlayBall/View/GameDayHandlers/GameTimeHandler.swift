//
//  GameTimeHandler.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/3/25.
//

import SwiftUI
import Combine

/// Represents the different states the game clock can be in.
enum GameClockState {
    case running
    case paused
    case quarterEnd
    case gameEnd
}

/// Controls the core game timer logic: play/pause, quarter tracking, and jumps.
@MainActor
final class GameTimeHandler: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentQuarter: Int = 1
    @Published var clockState: GameClockState = .paused

    private let quarterLength: TimeInterval = 600 // 10 minutes
    private var cancellable: AnyCancellable?

    init() {}
}

// MARK: - Timer Ticking
extension GameTimeHandler {
    private func tick() {
        elapsedTime += 1
        if elapsedTime >= quarterLength {
            advanceQuarter()
        }
    }
}

// MARK: - Play / Pause Control
extension GameTimeHandler {
    private func startTimer() {
        guard clockState != .gameEnd else { return }
        clockState = .running
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func pauseTimer() {
        clockState = .paused
        cancellable?.cancel()
        cancellable = nil
    }

    func togglePlayPause() {
        switch clockState {
        case .running: pauseTimer()
        case .paused, .quarterEnd: startTimer()
        case .gameEnd: break
        }
    }
}

// MARK: - Quarter Management
extension GameTimeHandler {
    private func advanceQuarter() {
        pauseTimer()
        if currentQuarter < 4 {
            currentQuarter += 1
            elapsedTime = 0
            clockState = .quarterEnd
        } else {
            clockState = .gameEnd
        }
    }
}

// MARK: - Manual Time Hops
extension GameTimeHandler {
    func jumpForward30() {
        elapsedTime = min(elapsedTime + 30, quarterLength)
    }

    func jumpBackward30() {
        elapsedTime = max(elapsedTime - 30, 0)
    }
}

// MARK: - Formatting
extension GameTimeHandler {
    /// Returns formatted elapsed time as `minutes:seconds`
    func formattedTime() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
