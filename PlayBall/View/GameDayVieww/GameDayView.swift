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

    @StateObject private var timerManager = GameTimerManager()
    private let liveActivityManager = LiveActivityManager()

    @State private var showingGameEditor = false
    @State private var showingGameOverview = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ColorGradient()

                ScrollView {
                    VStack(spacing: 12) {
                        VStack {
                            Text(game.name)
                                .font(.title.bold())
                                .foregroundStyle(.primary)

                            Text(game.date, style: .date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 12)

                        GameClockSection(
                            currentTimeFormatted: currentTimeFormatted,
                            currentQuarter: $timerManager.currentQuarter,
                            timerRunning: timerManager.timerRunning,
                            toggleTimer: timerManager.toggleTimer,
                            nextSubTime: nextSubTime,
                            lastSubTime: lastSubTime,
                            currentTime: $timerManager.currentTime,
                            quarterLength: timerManager.quarterLength,
                            totalQuarters: timerManager.totalQuarters
                        )

                        OnFieldSection(players: currentPlayers)
                        NextOnSection(nextPlayers: nextPlayers, nextSubRelativeFormatted: nextSubRelativeFormatted)

                        if !benchPlayers.isEmpty {
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
                timerManager.updateSegments(game.buildSegments())
                timerManager.configure(gameName: game.name, availablePlayers: game.availablePlayers)
            }
            .onChange(of: game) {
                timerManager.updateSegments(game.buildSegments())
            }
            .fullScreenCover(isPresented: $showingGameEditor) {
                GameEditView(game: $game, team: team)
            }
            .sheet(isPresented: $showingGameOverview) {
                GameOverviewView(game: game)
            }
        }
    }

    // MARK: - Computed Properties

    private var totalElapsedTime: TimeInterval {
        timerManager.totalElapsedTime
    }

    private var currentPlayers: [Player] {
        if let current = timerManager.segments.last(where: { totalElapsedTime >= $0.on && totalElapsedTime < $0.off }) {
            return current.players
        }
        return []
    }

    private var nextPlayers: [Player] {
        if let next = timerManager.segments.first(where: { $0.on > totalElapsedTime }) {
            return next.players
        }
        return []
    }

    private var benchPlayers: [Player] {
        game.availablePlayers.filter { !currentPlayers.contains($0) && !nextPlayers.contains($0) }
    }

    private var currentTimeFormatted: String {
        let minutes = Int(timerManager.currentTime) / 60
        let seconds = Int(timerManager.currentTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var nextSubRelativeFormatted: String {
        if let next = timerManager.segments.first(where: { $0.on > totalElapsedTime }) {
            let remaining = next.on - totalElapsedTime
            return remaining.timeFormatted
        }
        return "End"
    }

    private var nextSubTime: TimeInterval? {
        timerManager.segments.first(where: { $0.on > totalElapsedTime })?.on
    }

    private var lastSubTime: TimeInterval? {
        timerManager.segments.last(where: { $0.on < totalElapsedTime })?.on
    }
}

#Preview {
    @Previewable @State var game = Coach.previewCoach.teams.first!.games.first!
    GameDayView(
        game: $game,
        team: Coach.previewCoach.teams.first!
    )
}
