//
//  EmptyTeamView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/26/25.
//

import SwiftUI

struct EmptyTeamView: View {
    @Binding var showingTeamCreation: Bool

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 30) {
                // Icon
                Image(systemName: "person.3.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.8))

                // Title
                Text("No Team Selected")
                    .font(.title.bold())
                    .foregroundStyle(.white)

                // Subtitle
                Text("Once you create or your first team, it will appear here.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Create Button
                Button {
                    showingTeamCreation = true
                } label: {
                    Text("Create Team")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
                .padding(.horizontal, 40)
            }
            .padding(.vertical, 100)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 12)

            Spacer()
        }
    }
}

#Preview {
    EmptyTeamView(showingTeamCreation: .constant(false))
}
