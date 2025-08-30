import SwiftUI
import MijickTimer

struct GameDayView: View {
    @Binding var game: Game
    let team: Team
    
    @State private var session: GameSession

    @State private var showingGameEditor = false
    @State private var showingGameOverview = false
    @State private var shouldDeleteGame = false

    @Environment(\.dismiss) private var dismiss

    init(game: Binding<Game>, team: Team) {
        _game = game
        self.team = team
        _session = State(wrappedValue: GameSession(game: game.wrappedValue, team: team))
    }

    var body: some View {
        ZStack {
            ColorGradient()
            
            ScrollView {
                VStack {
                    Text(session.game.name)
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    
                    Text(session.game.date, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 12)
                
                VStack(spacing: 12) {
                    GameClockSection(
                        clock: session.clockManager,
                        numberOfPeriods: session.game.numberOfPeriods
                    )
                    OnFieldSection(state: session.substitutionState)
                    if !session.substitutionState.nextPlayers.isEmpty {
                        NextOnSection(state: session.substitutionState, clock: session.clockManager)
                    }
                    if !session.substitutionState.benchPlayers.isEmpty {
                        BenchSection(state: session.substitutionState)
                    }
                }
            }
            .toolbar {
                GameDayToolbar(
                    dismiss: dismiss,
                    session: session,
                    showingGameEditor: $showingGameEditor,
                    showingGameOverview: $showingGameOverview,
                    shouldDeleteGame: $shouldDeleteGame
                )
            }
            .onChange(of: game) {
                session = GameSession(game: game, team: team)
                session.restartSubTimer()
            }
            .fullScreenCover(isPresented: $showingGameEditor) {
                GameEditView(game: $game, team: team)
            }
            .sheet(isPresented: $showingGameOverview) {
                GameOverviewView(plan: session.substitutionState.plan)
            }
            .onDisappear {
                if shouldDeleteGame {
                    session.team.removeGame(session.game)
                    Coach.shared.updateTeam(session.team)
                }
            }
        }
    }
}

struct GameClockSection: View {
    @ObservedObject var clock: GameClockManager
    let numberOfPeriods: GameFormat

    var body: some View {
        GlassCard(title: "Game Clock", sfSymbol: "timer") {
            HStack(spacing: 50) {
                VStack {
                    Text(numberOfPeriods == .quarter ? "Quarter" : "Half")
                        .font(.callout.bold())
                        .foregroundStyle(.secondary)
                    Text("\(clock.currentQuarter == 0 ? 1 : clock.currentQuarter)")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                }

                VStack {
                    Text("Time")
                        .font(.callout.bold())
                        .foregroundStyle(.secondary)
                    Text(clock.elapsedSeconds.timeFormatted)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                }
                
                Button(action: clock.togglePlayPause) {
                    Image(clock.isRunning ? .pause : .play)
                        .padding(12)
                        .background(.regularMaterial, in: Circle())
                }
                .disabled(clock.isGameOver)
                .font(.title2)
                .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct OnFieldSection: View {
    @ObservedObject var state: SubstitutionState

    var body: some View {
        GlassCard(title: "On Field", sfSymbol: "sportscourt") {
            VStack {
                if state.currentPlayers.isEmpty {
                    Text("No players on field")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    FlowLayout(items: state.currentPlayers, spacing: 8) { player in
                        PlayerPill(name: player.name, tint: player.tint)
                    }
                }
            }
        }
    }
}

struct NextOnSection: View {
    @ObservedObject var state: SubstitutionState
    @ObservedObject var clock: GameClockManager

    var body: some View {
        GlassCard(title: "Next On", sfSymbol: "arrow.right.circle") {
            VStack(alignment: .leading, spacing: 8) {
                if state.nextPlayers.isEmpty {
                    Text("No more substitutions")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Next Sub In: \(clock.subRemainingSeconds.timeFormatted)")
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)

                    FlowLayout(items: state.nextPlayers, spacing: 8) { player in
                        PlayerPill(name: player.name, tint: player.tint)
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
    @ObservedObject var state: SubstitutionState

    var body: some View {
        GlassCard(title: "Bench", sfSymbol: "chair.lounge") {
            VStack {
                if state.benchPlayers.isEmpty {
                    Text("No players on bench")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    FlowLayout(items: state.benchPlayers, spacing: 8) { player in
                        PlayerPill(name: player.name, tint: player.tint)
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
        ToolbarItem(placement: .topBarTrailing) {
            Button("Game Overview", systemImage: "list.bullet.rectangle") {
                showingGameOverview = true
            }
            .tint(.primary)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Edit Game", systemImage: "pencil") {
                    showingGameEditor = true
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
                    .tint(.primary)
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
