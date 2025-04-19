//
//  ShareTeamsButton.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/18/25.
//


//  ShareSheet helper
import SwiftUI
import UniformTypeIdentifiers

struct ShareTeamsButton: View {
    @State private var exportURL: URL?

    var body: some View {
        Button {
            exportURL = Coach.shared.exportToTempFile()
        } label: {
            Label("Share Data", systemImage: "square.and.arrow.up")
        }
        .sheet(item: $exportURL) { url in
            ShareLink(item: url) { Text("Export") }
        }
    }
}

extension URL: Identifiable {
    public var id: Self { self }   // the URL itself is a perfect unique ID
}
