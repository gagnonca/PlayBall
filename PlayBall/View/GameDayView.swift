import SwiftUI
import MijickTimer

struct GameDayView: View {
    @Binding var game: Game
    let team: Team
    
//    @State private var session: GameSession
    @StateObject private var session: GameSession

    @State private var showingGameEditor = false
    @State private var showingGameOverview = false
    @State private var shouldDeleteGame = false

    @Environment(\.dismiss) private var dismiss

    init(game: Binding<Game>, team: Team) {
        _game = game
        self.team = team
        _session = StateObject(wrappedValue: GameSession(game: game.wrappedValue, team: team))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ColorGradient()
                
                ScrollView {
                    VStack {
                        Text(session.game.name)
                            .font(.title.bold())
                            .foregroundStyle(.primary)
                        
                        Text(session.game.date, style: .date)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 12)
                    
                    VStack(spacing: 12) {
                        GameClockSection(
                            coordinator: session.timerCoordinator,
                            timer: session.timerCoordinator.quarterTimer,
                            numberOfPeriods: session.game.numberOfPeriods
                        )
                        OnFieldSection(players: session.currentPlayers)
                        if let countDown = session.nextSubstitutionCountdown
                        {
//                        if !session.nextPlayers.isEmpty {
                            NextOnSection(
                                players: session.nextPlayers,
                                countdownTarget:countDown
                            )
                        }
                        if !session.benchPlayers.isEmpty {
                            BenchSection(players: session.benchPlayers)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                GameDayToolbar(
                    dismiss: dismiss,
                    session: session,
                    showingGameEditor: $showingGameEditor,
                    showingGameOverview: $showingGameOverview,
                    shouldDeleteGame: $shouldDeleteGame
                )
            }

//            .onReceive(session.timerCoordinator.quarterTimer.$timerTime) { time in
////                session.checkForSubstitutionAdvance(elapsed: time.totalSeconds)
//            }
//            .onReceive(session.timerCoordinator.$elapsedTime) { seconds in
//                session.updateSubstitutionState(elapsed: seconds)
//            }
            .onReceive(session.timerCoordinator.$elapsedTime) { seconds in
                session.currentElapsedTime = seconds
                session.updateSubstitutionState(elapsed: seconds)
            }

//            .onChange(of: game) {
//                session = GameSession(game: game, team: team)
////                session.restartSubTimer()
//            }
            .onChange(of: game) {
                session.update(from: game)
            }
            .fullScreenCover(isPresented: $showingGameEditor) {
                GameEditView(game: $game, team: team)
            }
            .sheet(isPresented: $showingGameOverview) {
                GameOverviewView(plan: session.substitutionPlan)
            }
            .onDisappear {
//                session.cleanup()
                if shouldDeleteGame {
                    session.team.removeGame(session.game)
                    Coach.shared.updateTeam(session.team)
                }
            }
        }
    }
}

//extension GameSession {
//    var nextSubstitutionCountdown: TimeInterval {
//        let cycle = substitutionState.plan.subDuration
//        let intoCycle = totalElapsedTime.truncatingRemainder(dividingBy: cycle)
//        return max(cycle - intoCycle, 0)
//    }
//}

struct GameClockSection: View {
    @StateObject var coordinator: GameTimerCoordinator
    @ObservedObject var timer: MTimer
    let numberOfPeriods: GameFormat

    var body: some View {
        let timer = coordinator.quarterTimer

        GlassCard(title: "Game Clock", sfSymbol: "timer") {
            HStack(spacing: 50) {
                VStack {
                    Text(numberOfPeriods == .quarter ? "Quarter" : "Half")
                        .font(.callout.bold())
                        .foregroundStyle(.secondary)
                    Text("\(coordinator.currentQuarter)")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                }

                VStack {
                    Text("Time")
                        .font(.callout.bold())
                        .foregroundStyle(.secondary)
                    Text(timer.timerTime.toString(getFormatter))
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                }
                
                Button(action: coordinator.togglePlayPause) {
                    Image(timer.timerStatus == .running ? .pause : .play)
                        .padding(12)
                        .background(.regularMaterial, in: Circle())
                }
                .disabled(coordinator.isGameOver)
                .font(.title2)
                .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct OnFieldSection: View {
    let players: [Player]

    var body: some View {
        GlassCard(title: "On Field", sfSymbol: "sportscourt") {
            VStack {
                if players.isEmpty {
                    Text("No players on field")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    FlowLayout(items: players, spacing: 8) { player in
                        PlayerBadge(player: player)
                    }
                }
            }
        }
    }
}

struct NextOnSection: View {
    let players: [Player]
    let countdownTarget: TimeInterval

    var body: some View {
        GlassCard(title: "Next On", sfSymbol: "arrow.right.circle") {
            VStack(alignment: .leading, spacing: 8) {
                if players.isEmpty {
                    Text("No more substitutions")
                        .foregroundStyle(.secondary)
                } else {
//                    if let countdown = countdownTarget, countdown > 0 {
//                        let targetDate = Date().addingTimeInterval(countdown)
                        Text(countdownTarget.timeFormatted)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
//                    }

//                    if let offTime = countdownTarget {
//                        let targetDate = Date().addingTimeInterval(offTime - GameSession.nowElapsed)
//                        Text(timerInterval: Date()...targetDate, countsDown: true)
//                            .monospacedDigit()
//                            .foregroundStyle(.secondary)
//                            .padding(.bottom, 8)
//                    }

                    FlowLayout(items: players, spacing: 8) { player in
                        PlayerBadge(player: player)
                    }
                }
            }
        }
    }
}

extension View {
    func getFormatter(_ formatter: DateComponentsFormatter) -> DateComponentsFormatter {
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }
}

struct BenchSection: View {
    let players: [Player]

    var body: some View {
        GlassCard(title: "Bench", sfSymbol: "chair.lounge") {
            VStack {
                if players.isEmpty {
                    Text("No players on bench")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    FlowLayout(items: players, spacing: 8) { player in
                        PlayerBadge(player: player)
                    }
                }
            }
        }
    }
}

private struct GameDayToolbar: ToolbarContent {
    var dismiss: DismissAction
    var session: GameSession
    @Binding var showingGameEditor: Bool
    @Binding var showingGameOverview: Bool
    @Binding var shouldDeleteGame: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
//                session.liveActivityHandler.endLiveActivity()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
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
//                    session.liveActivityHandler.endLiveActivity()
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
}

struct GameDayViewWrapper: View {
    let gameID: UUID
    @Binding var team: Team

    var body: some View {
        if let index = team.games.firstIndex(where: { $0.id == gameID }) {
            GameDayView(game: $team.games[index], team: team)
        } else {
            Text("Game not found or deleted.")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    @Previewable @State var game = Coach.previewCoach.teams.first!.games.first!
    GameDayView(
        game: $game,
        team: Coach.previewCoach.teams.first!
    )
}
