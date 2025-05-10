//
//  ColorPickerSection.swift
//  PlayBall
//
//  Created by Corey Gagnon on 5/7/25.
//

import SwiftUI

struct ColorPickerSection: View {
    @Binding var primaryColorHex: String
    @Binding var secondaryColorHex: String
    
    @State private var primaryColor: Color = .blue
    @State private var secondaryColor: Color = .pink
    
    var body: some View {
        GlassCard(title: "Team Colors", sfSymbol: "paintpalette") {
            VStack(alignment: .leading, spacing: 12) {
                ColorPicker("Primary Color", selection: $primaryColor)
                ColorPicker("Secondary Color", selection: $secondaryColor)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 80)
                    .overlay(
                        Text("Preview")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.top, 50),
                        alignment: .top
                    )
                    .padding(.top, 8)
            }
            //            .onChange(of: primaryColor) {
            //                primaryColorHex = primaryColor.toHex()
            //            }
            //            .onChange(of: secondaryColor) {
            //                secondaryColorHex = secondaryCol
        }
    }
}

#Preview {
    @Previewable @State var primaryColorHex = "0000FF" // Example: Blue
    @Previewable @State var secondaryColorHex = "FF69B4" // Example: Pink

    return ColorPickerSection(
        primaryColorHex: $primaryColorHex,
        secondaryColorHex: $secondaryColorHex
    )
}
