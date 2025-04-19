//
//  GameDayView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/16/25.
//


import SwiftUI

struct GameDayView: View {
    @Binding var game: Game
    let team: Team
    
    @State private var showEditor = false
    
    private var segments: [SubSegment] {
        game.buildSegments()
    }
    
    private let timeColumnWidth: CGFloat = 50
    
    var body: some View {
        List {
            HStack {
                Text("On").bold()
                    .frame(width: timeColumnWidth, alignment: .leading)
                
                Text("🐆").bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Off").bold()
                    .frame(width: timeColumnWidth, alignment: .trailing)
            }
            .listRowBackground(Color.green.opacity(0.30))
            
            ForEach(segments) { segment in
                HStack(alignment: .top, spacing: 8) {
                    Text(segment.onFormatted)
                        .monospacedDigit()
                        .frame(width: timeColumnWidth, alignment: .leading)
                    
                    HStack(spacing:4) {
                        ForEach(segment.players) { player in
                            PlayerBadge(player: player)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(segment.offFormatted)
                        .monospacedDigit()
                        .frame(width: timeColumnWidth, alignment: .trailing)
                }
                .listRowBackground(Color.green.opacity(0.10))
            }
        }
        .listStyle(.plain)
        .navigationTitle(game.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditor = true }
            }
        }
        .sheet(isPresented: $showEditor) {
            GameEditView(game: $game, team: team)
        }
    }
}

private struct GameDayWrapper: View {
    @State var game = Coach.previewCoach.teams.first!.games.first!
    var body: some View {
        NavigationStack {
            GameDayView(game: $game,
                        team: Coach.previewCoach.teams.first!)
        }
    }
}

#Preview { GameDayWrapper() }

