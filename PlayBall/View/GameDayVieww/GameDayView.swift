//
//  GameDayView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/27/25.
//

import SwiftUI

struct GameDayView: View {
    @Binding var game: Game
    let team: Team

    // Game time management
    @State private var segments: [SubSegment] = []
    @State private var currentTime: TimeInterval = 0
    @State private var currentQuarter: Int = 1
    @State private var timerRunning = false
    @State private var timer: Timer?
    let quarterLength: TimeInterval = 10 * 60
    let totalQuarters = 4
    var timerInterval: TimeInterval = 1 // to allow speeding up time for testing


    @State private var showingGameEditor = false
    @State private var showingGameOverview = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ColorGradient()

                ScrollView {
                    VStack(spacing: 12) {
                        // Game Info Header
                        VStack() {
                            Text(game.name)
                                .font(.title.bold())
                                .foregroundStyle(.primary)

                            Text(game.date, style: .date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 12)

                        // Game Clock
                        GameClockSection(
                            currentTimeFormatted: currentTimeFormatted,
                            currentQuarter: $currentQuarter,
                            timerRunning: timerRunning,
                            toggleTimer: toggleTimer,
                            nextSubTime: segments.first(where: { $0.on > totalElapsedTime })?.on,
                            lastSubTime: segments.last(where: { $0.on < totalElapsedTime })?.on,
                            currentTime: $currentTime,
                            quarterLength: quarterLength,
                            totalQuarters: totalQuarters
                        )

                        // On Field Section
                        OnFieldSection(players: currentPlayers)
                        
                        // Coming On Section
                        NextOnSection(nextPlayers: nextPlayers, nextSubRelativeFormatted: nextSubRelativeFormatted)
                        
                        // Bench Section
                        if (!benchPlayers.isEmpty) {
                            BenchSection(players: benchPlayers)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward.circle.fill")
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Edit Game", systemImage: "pencil") {
                            showingGameEditor = true
                        }

                        Button("Game Overview", systemImage: "list.bullet.rectangle") {
                            showingGameOverview = true
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(.white)
                    }
                }
            }
            .onAppear {
                segments = game.buildSegments()
            }
            .onChange(of: game) {
                segments = game.buildSegments()
            }
            .fullScreenCover(isPresented: $showingGameEditor) {
                GameEditView(game: $game, team: team)
            }
            .sheet(isPresented: $showingGameOverview) {
                GameOverviewView(game: game)
            }

        }
    }

    // MARK: - Helpers
    private var nextSubRelativeFormatted: String {
        if let next = segments.first(where: { $0.on > totalElapsedTime }) {
            let remaining = next.on - totalElapsedTime
            return remaining.timeFormatted
        } else {
            return "End"
        }
    }

    private var currentTimeFormatted: String {
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var nextSubTimeFormatted: String {
        if let next = segments.first(where: { $0.on > totalElapsedTime }) {
            return next.onFormatted
        } else {
            return "End"
        }
    }

    private var currentPlayers: [Player] {
        if let current = segments.last(where: { totalElapsedTime >= $0.on && totalElapsedTime < $0.off }) {
            return current.players
        } else {
            return []
        }
    }

    private var nextPlayers: [Player] {
        if let next = segments.first(where: { $0.on > totalElapsedTime }) {
            return next.players
        } else {
            return []
        }
    }
    
    private var benchPlayers: [Player] {
        game.availablePlayers.filter { !currentPlayers.contains($0) && !nextPlayers.contains($0)
        }
    }


    private var totalElapsedTime: TimeInterval {
        return (Double(currentQuarter - 1) * quarterLength) + currentTime
    }

    private func toggleTimer() {
        timerRunning.toggle()
        if timerRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            if currentTime < quarterLength {
                currentTime += 1
            } else {
                stopTimer()
                timerRunning = false

                if currentQuarter < totalQuarters {
                    currentQuarter += 1
                    currentTime = 0
                } else {
                    // Full game completed
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    @Previewable @State var game = Coach.previewCoach.teams.first!.games.first!
    GameDayView(
        game: $game,
        team: Coach.previewCoach.teams.first!,
        timerInterval: 1 // Fast preview mode
//        timerInterval: 0.01 // Fast preview mode
    )
}
