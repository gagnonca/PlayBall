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

    @StateObject private var gameDayHandler: GameDayHandler

    @State private var showingGameEditor = false
    @State private var showingGameOverview = false
    @State private var shouldDeleteGame = false

    @Environment(\.dismiss) private var dismiss

    init(game: Binding<Game>, team: Team) {
        _game = game
        self.team = team
        _gameDayHandler = StateObject(wrappedValue: GameDayHandler(game: game.wrappedValue, team: team))
    }

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

                        TimelineView(.periodic(from: Date(), by: 1)) { _ in
                            GameClockSection(handler: gameDayHandler.timeHandler)
                            OnFieldSection(players: currentPlayers)
                            NextOnSection(nextPlayers: nextPlayers, nextSubRelativeFormatted: nextSubRelativeFormatted)
                            
                            if !benchPlayers.isEmpty {
                                BenchSection(players: benchPlayers)
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        gameDayHandler.endLiveActivity()
                        dismiss()
                    } label: {
                        Image(.back)
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

                        Button(role: .destructive) {
                            gameDayHandler.endLiveActivity()
                            shouldDeleteGame = true
                            dismiss()
                        } label: {
                            Label("Delete Game", systemImage: "trash")
                        }
                    } label: {
                        Image(.edit)
                            .foregroundStyle(.white)
                    }
                }
            }
            .onAppear {
                gameDayHandler.startLiveActivityIfNeeded()
            }
            .onChange(of: game) { _ in
                gameDayHandler.refreshSegments()
            }
            .onDisappear {
                if shouldDeleteGame {
                    team.removeGame(game)
                    Coach.shared.updateTeam(team)
                }
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
        gameDayHandler.totalElapsedTime
    }

    private var currentPlayers: [Player] {
        gameDayHandler.segmentsHandler.currentPlayers(totalElapsedTime: totalElapsedTime)
    }

    private var nextPlayers: [Player] {
        gameDayHandler.segmentsHandler.nextPlayers(totalElapsedTime: totalElapsedTime)
    }

    private var benchPlayers: [Player] {
        gameDayHandler.segmentsHandler.benchPlayers(current: currentPlayers, next: nextPlayers)
    }

    private var nextSubRelativeFormatted: String {
        if let next = gameDayHandler.segmentsHandler.nextSubTime(totalElapsedTime: totalElapsedTime) {
            let remaining = next - totalElapsedTime
            return remaining.timeFormatted
        }
        return "End"
    }
}

#Preview {
    @Previewable @State var game = Coach.previewCoach.teams.first!.games.first!
    GameDayView(
        game: $game,
        team: Coach.previewCoach.teams.first!
    )
}
