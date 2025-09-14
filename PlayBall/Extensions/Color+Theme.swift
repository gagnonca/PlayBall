//
//  Color+Theme.swift
//  PlayBall
//
//  Created by Corey Gagnon on 4/30/25.
//

import SwiftUI

extension Color {
    static let rosewater = Color(hex: "#dc8a78")
    static let flamingo = Color(hex: "#dd7878")
    static let pink = Color(hex: "#ea76cb")
    static let mauve = Color(hex: "#8839ef")
    static let red = Color(hex: "#d20f39")
    static let maroon = Color(hex: "#e64553")
    static let peach = Color(hex: "#fe640b")
    static let yellow = Color(hex: "#df8e1d")
    static let green = Color(hex: "#40a02b")
    static let teal = Color(hex: "#179299")
    static let sky = Color(hex: "#04a5e5")
    static let sapphire = Color(hex: "#209fb5")
    static let blue = Color(hex: "#1e66f5")
    static let lavender = Color(hex: "#7287fd")
}

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
    
    /// Hex string in "#RRGGBB" format (no alpha)
    func toHexRGB() -> String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return "#000000" }
        func h(_ x: CGFloat) -> String { String(format: "%02X", Int(round(x * 255))) }
        return "#\(h(r))\(h(g))\(h(b))"
    }}
