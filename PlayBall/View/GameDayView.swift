import SwiftUI
import MijickTimer

struct GameDayView: View {
    @Binding var game: Game
    let team: Team
    
    @State private var session: GameSession

    @State private var showingGameEditor = false
    @State private var showingGameOverview = false
    @State private var shouldDeleteGame = false
    @State private var showingResyncTimerSheet = false

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
                VStack(spacing: 12) {
                    GlassCard {
                        VStack {
                            Text(session.game.name)
                                .font(.title.bold())
                                .foregroundStyle(.primary)

                            Text(session.game.date, style: .date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
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
            .scrollDisabled(true)
            .toolbar {
                GameDayToolbar(
                    dismiss: dismiss,
                    session: session,
                    showingGameEditor: $showingGameEditor,
                    showingGameOverview: $showingGameOverview,
                    shouldDeleteGame: $shouldDeleteGame,
                    showingResyncTimerSheet: $showingResyncTimerSheet
                )
            }
            .onChange(of: game) {
                session.applyGameChanges(game)
            }
            .fullScreenCover(isPresented: $showingGameEditor) {
                GameEditView(game: $game, team: team)
            }
            .sheet(isPresented: $showingGameOverview) {
                GameOverviewView(plan: session.substitutionState.plan)
            }
            .sheet(isPresented: $showingResyncTimerSheet) {
                TimerResyncSheet(
                    maxSeconds: session.clockManager.periodLength,
                    currentElapsed: session.clockManager.elapsedSeconds,
                    maxQuarter: session.game.numberOfPeriods.rawValue,
                    currentQuarter: max(session.clockManager.currentQuarter, 1)
                ) { newSeconds, targetQuarter in
                    session.resyncTimer(to: newSeconds, inQuarter: targetQuarter)
                }
                .presentationDetents([.height(360), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(16)
            }
            .onDisappear {
                session.endLiveActivity()
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
    @Binding var showingResyncTimerSheet: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Game Overview", systemImage: "list.bullet.rectangle") {
                showingGameOverview = true
            }
            .tint(.primary)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button("Resync Timer", systemImage: "clock.arrow.circlepath") {
                showingResyncTimerSheet = true
            }
            .tint(.primary)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Edit Game", systemImage: "pencil") {
                    showingGameEditor = true
                }
                Button(role: .destructive) {
                    session.endLiveActivity()
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

struct TimerResyncSheet: View {
    let maxSeconds: Int
    let currentElapsed: Int
    let maxQuarter: Int
    let currentQuarter: Int
    let onSave: (Int, Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 0
    @State private var selectedQuarter: Int = 1

    private var maxMinutes: Int {
        maxSeconds / 60
    }
    private var maxSecondsForSelectedMinute: Int {
        if selectedMinutes == maxMinutes {
            return maxSeconds % 60
        } else {
            return 59
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Quarter", selection: $selectedQuarter) {
                    ForEach(1...maxQuarter, id: \.self) { q in
                        Text("Q\(q)").tag(q)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                HStack {
                    Picker("Minutes", selection: $selectedMinutes) {
                        ForEach(0...maxMinutes, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)

                    Picker("Seconds", selection: $selectedSeconds) {
                        ForEach(0...maxSecondsForSelectedMinute, id: \.self) { second in
                            Text("\(second) sec").tag(second)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Resync Timer")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let total = selectedMinutes * 60 + selectedSeconds
                        onSave(total, selectedQuarter)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                selectedQuarter = min(max(currentQuarter, 1), maxQuarter)
                let minutes = currentElapsed / 60
                let seconds = currentElapsed % 60
                if minutes <= maxMinutes {
                    selectedMinutes = minutes
                    selectedSeconds = seconds <= (minutes == maxMinutes ? maxSeconds % 60 : 59) ? seconds : 0
                } else {
                    selectedMinutes = maxMinutes
                    selectedSeconds = maxSeconds % 60
                }
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
