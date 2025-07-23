import SwiftUI
import MijickTimer

@MainActor
final class GameClockManager: ObservableObject {
    // Published state for the UI
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var subRemainingSeconds: Int = 0
    @Published private(set) var currentQuarter: Int = 0

    // Configuration
    let totalPeriods: Int
    let periodLength: Int         // seconds
    let substitutionInterval: Int // seconds

    // Callbacks
    var onGameStart: (() -> Void)?
    var onGameEnd: (() -> Void)?
    var onSubTimerFinish: (() -> Void)?
    var onSubTimerRestarted: (() -> Void)?

    // Internal state
    private var quarterTimer: MTimer
    private var lastSubstitutionTimestamp: Int = 0

    init(totalPeriods: Int,
         periodLength: TimeInterval,
         substitutionInterval: TimeInterval,
         timerID: String = UUID().uuidString) {
        self.totalPeriods = totalPeriods
        self.periodLength = Int(periodLength)
        self.substitutionInterval = Int(substitutionInterval)
        self.quarterTimer = MTimer(MTimerID(rawValue: timerID))
        self.subRemainingSeconds = self.substitutionInterval
    }

    var isGameOver: Bool {
        currentQuarter >= totalPeriods
    }

    // MARK: - Public controls

    func togglePlayPause() {
        guard !isGameOver else {
            onGameEnd?()
            return
        }
        switch quarterTimer.timerStatus {
        case .notStarted, .finished:
            startQuarter()
        case .running:
            quarterTimer.pause()
        case .paused:
            try? quarterTimer.resume()
        }
    }

    func restartSubTimer(remaining: TimeInterval) {
        // Manually restart the substitution countdown from a given remaining value.
        let remainingInt = max(Int(remaining), 0)
        let cyclePos = substitutionInterval - remainingInt
        lastSubstitutionTimestamp = elapsedSeconds - cyclePos
        subRemainingSeconds = remainingInt
        onSubTimerRestarted?()
    }

    // MARK: - Private helpers

    private func startQuarter() {
        currentQuarter += 1
        elapsedSeconds = 0
        lastSubstitutionTimestamp = 0
        subRemainingSeconds = substitutionInterval

        // Configure the underlying timer to tick every second up to the period length.
        try? quarterTimer
            .publish(every: 1)
            .onTimerStatusChange { [weak self] status in
                self?.handleTimerStatusChange(status)
            }
            .start(from: 0, to: TimeInterval(periodLength))

        onGameStart?()
    }

    private func handleTimerStatusChange(_ status: MTimerStatus) {
        switch status {
        case .running:
            let newElapsed = quarterTimer.timerTime.totalSeconds
            // Update elapsed time
            if newElapsed != elapsedSeconds {
                elapsedSeconds = newElapsed
            }

            // Compute remaining time until next substitution
            let timeSinceLastSub = newElapsed - lastSubstitutionTimestamp
            let remaining = substitutionInterval - timeSinceLastSub
            if remaining != subRemainingSeconds {
                subRemainingSeconds = max(remaining, 0)
            }

            // Trigger substitution if we hit zero and period not yet finished
            if remaining <= 0 && newElapsed < periodLength {
                lastSubstitutionTimestamp = newElapsed
                subRemainingSeconds = substitutionInterval
                onSubTimerFinish?()
                onSubTimerRestarted?()
            }

        case .finished:
            // Period ended
            elapsedSeconds = periodLength
            subRemainingSeconds = 0
            quarterTimer.pause()  // Ensure timer stops
            onGameEnd?()

        default:
            break
        }
    }
}
