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
                        OnFieldSection(state: session.substitutionState)
                        if !session.substitutionState.nextPlayers.isEmpty {
                            NextOnSection(state: session.substitutionState, timer: session.timerCoordinator.subTimer)
                        }
                        if !session.substitutionState.benchPlayers.isEmpty {
                            BenchSection(state: session.substitutionState)
                        }                    }
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
//                session.cleanup()
                if shouldDeleteGame {
                    session.team.removeGame(session.game)
                    Coach.shared.updateTeam(session.team)
                }
            }
        }
    }
}

struct GameClockSection: View {
    @StateObject var coordinator: GameTimerCoordinator
    @ObservedObject var timer: MTimer
    let numberOfPeriods: PeriodStyle

    var body: some View {
        let timer = coordinator.quarterTimer

        GlassCard(title: "Game Clock", sfSymbol: "timer") {
            HStack(spacing: 64) {
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
                        PlayerBadge(player: player)
                    }
                }
            }
        }
    }
}

struct NextOnSection: View {
    @ObservedObject var state: SubstitutionState
    @ObservedObject var timer: MTimer

    var body: some View {
        GlassCard(title: "Next On", sfSymbol: "arrow.right.circle") {
            VStack(alignment: .leading, spacing: 8) {
                if state.nextPlayers.isEmpty {
                    Text("No more substitutions")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Next Sub In: \(timer.timerTime.toString(getFormatter))")
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)

                    FlowLayout(items: state.nextPlayers, spacing: 8) { player in
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

#Preview {
    @Previewable @State var game = Coach.previewCoach.teams.first!.games.first!
    GameDayView(
        game: $game,
        team: Coach.previewCoach.teams.first!
    )
}
