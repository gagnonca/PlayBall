//
//  AddTeamPageView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 9/14/25.
//


import SwiftUI

struct AddTeamPageView: View {
    @Binding var showingTeamCreation: Bool

    var body: some View {
        Button {
            showingTeamCreation = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                            .foregroundStyle(.white.opacity(0.35))
                    )

                VStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Add Team")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.95))
                    Text("Create a new team to track")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 44)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add Team")
    }
}
