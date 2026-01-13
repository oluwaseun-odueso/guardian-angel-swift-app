//
//  Color+Guardian.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 28/12/2025.
//

import SwiftUI

extension Color {
    /// Initialize a Color from a hex string.
    /// Supports the following formats: RGB (e.g. "#ABC"), RRGGBB (e.g. "#AABBCC"), AARRGGBB (e.g. "#FFAABBCC").
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)

        let r, g, b, a: Double
        switch hexString.count {
        case 3: // RGB (12-bit)
            let r4 = (int >> 8) & 0xF
            let g4 = (int >> 4) & 0xF
            let b4 = int & 0xF
            r = Double((r4 << 4) | r4) / 255.0
            g = Double((g4 << 4) | g4) / 255.0
            b = Double((b4 << 4) | b4) / 255.0
            a = 1.0
        case 6: // RRGGBB (24-bit)
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
            a = 1.0
        case 8: // AARRGGBB (32-bit)
            a = Double((int >> 24) & 0xFF) / 255.0
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            // Fallback to white if the string isn't a recognized length
            r = 1.0; g = 1.0; b = 1.0; a = 1.0
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// Namespaced Guardian brand colors to avoid symbol collisions.
    struct Guardian {
        static let black = Color(hex: "#000000")
        static let white = Color(hex: "#FFFFFF")
        static let navy  = Color(hex: "#002147")
        static let grey  = Color(hex: "#555555")
        static let lightGrey = Color(hex: "#F4F4F4")
        static let magenta = Color(hex: "#8C1946")
    }
}


//extension Color {
//    /// Initialize a Color from a hex value like 0xRRGGBB and optional alpha (0...1).
//init(hex: UInt, alpha: Double = 1.0) {
//    let r = Double((hex >> 16) & 0xFF) / 255.0
//    let g = Double((hex >> 8) & 0xFF) / 255.0
//    let b = Double(hex & 0xFF) / 255.0
//    self = Color(red: r, green: g, blue: b, opacity: alpha)
//}

    // App brand colors (adjust values to match your design system)
//    static let guardianBlack = Color(hex: 0x1A1A1A)
//    static let guardianWhite = Color(hex: 0xFFFFFF)
//    static let guardianNavy  = Color(hex: 0x0D2B45)
//}
