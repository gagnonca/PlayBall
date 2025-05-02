//
//  GameOverviewView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/29/25.
//

import SwiftUI

struct GameOverviewView: View {
    let game: Game
    private var segments: [SubSegment] {
        game.buildSegments()
    }

    private let timeColumnWidth: CGFloat = 50

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("Players").bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 4)

                    Text("Off").bold()
                        .frame(width: timeColumnWidth, alignment: .center)
                        .padding(.horizontal, 4)
                }
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.25))

                // Segment rows
                ForEach(segments) { segment in
                    HStack(alignment: .top, spacing: 8) {
                        FlowLayout(items: segment.players, spacing: 4) { player in
                            PlayerBadge(player: player)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 4)

                        Text(segment.offFormatted)
                            .monospacedDigit()
                            .frame(width: timeColumnWidth, alignment: .center)
                            .padding(.top, 4)
                            .padding(.horizontal, 4)
                    }
                    .padding(.vertical, 10)
                    .background(Color.green.opacity(0.15))
                }
            }
        }
    }
}

#Preview {
    PreviewSheetContainer()
}

private struct PreviewSheetContainer: View {
    @State private var showingSheet = true

    var body: some View {
        Color.clear // background doesn't matter
            .sheet(isPresented: $showingSheet) {
                let coach = Coach.previewCoach
                let game = coach.teams.first!.games.first!
                GameOverviewView(game: game)
            }
    }
}
