//
//  TeamsOverviewView.swift
//  PlayBall
//
//  2-col team cards (ColorGradient + name) — tap to select & dismiss
//

import SwiftUI

struct TeamsOverviewView: View {
    var coach: Coach

    @Binding var currentIndex: Int
    @Binding var lastSelectedTeamID: String
    @Binding var showingTeamCreation: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Teams")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") { dismiss() }
                    }
                }
                .onAppear { appeared = true }
        }
    }

    // MARK: - Body pieces

    @ViewBuilder
    private var content: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(coach.teams.enumerated()), id: \.1.id) { index, team in
                    Button {
                        // Select this team and close the sheet
                        currentIndex = index
                        lastSelectedTeamID = team.id.uuidString
                        withAnimation(.easeInOut(duration: 0.18)) {
                            dismiss()
                        }
                    } label: {
                        TeamCard(
                            theme: theme(for: team),
                            name: team.name,
                            appeared: appeared
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(team.name)")
                }

                AddTeamCard {
                    showingTeamCreation = true
                    dismiss()
                }
                .modifier(ScaleFade(appeared: appeared))
            }
            .padding(16)
        }
        .modifier(SheetZoomOut(appeared: appeared))
    }

    // Build the theme separately (safe default if colors are nil)
    private func theme(for team: Team) -> TeamTheme {
        if let colors = team.colors {
            return TeamTheme(
                start: Color(hex: colors.homeHex),
                end:   Color(hex: colors.awayHex)
            )
        } else {
            return .default
        }
    }
}

// MARK: - Subviews

/// Team card with per-card ColorGradient and the team name.
private struct TeamCard: View {
    let theme: TeamTheme
    let name: String
    let appeared: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.clear)
                .background(
                    ColorGradient()
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                )

            Text(name)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .shadow(radius: 2)
                .padding(.horizontal, 12)
                .multilineTextAlignment(.center)
        }
        .frame(height: 220)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 10, y: 6)
        .environment(\.teamTheme, theme)
        .modifier(ScaleFade(appeared: appeared))
    }
}

/// Dashed “+” card (interactive).
private struct AddTeamCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                            .foregroundStyle(.primary.opacity(0.35))
                    )
                Image(systemName: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.primary.opacity(0.85))
            }
            .frame(height: 220)
            .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
            .accessibilityLabel("Add Team")
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Lightweight modifiers

private struct ScaleFade: ViewModifier {
    var appeared: Bool
    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1.0 : 0.95)
            .opacity(appeared ? 1.0 : 0.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.9), value: appeared)
    }
}

private struct SheetZoomOut: ViewModifier {
    var appeared: Bool
    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1.0 : 1.06)
            .opacity(appeared ? 1.0 : 0.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.9), value: appeared)
    }
}

#Preview {
    let previewCoach = Coach.previewCoach
    return TeamsOverviewView(
        coach: previewCoach,
        currentIndex: .constant(0),
        lastSelectedTeamID: .constant(""),
        showingTeamCreation: .constant(false)
    )
}
