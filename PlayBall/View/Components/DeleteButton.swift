//
//  DeleteButton.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/29/25.
//


import SwiftUI

struct DeleteButton: View {
    let title: String
    let onDelete: () -> Void

    var body: some View {
        Button(role: .destructive) {
            onDelete()
        } label: {
            Label(title, systemImage: "trash")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .foregroundColor(.red)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.thickMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.horizontal)
        .padding(.top, 24)
    }
}

#Preview {
    VStack {
        DeleteButton(title: "Delete Team") {}
        DeleteButton(title: "Delete Game") {}
    }
}
