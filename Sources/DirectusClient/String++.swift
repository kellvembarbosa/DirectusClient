//
//  SwiftUIView.swift
//  
//
//  Created by Kellvem Barbosa on 16/05/2023.
//

import SwiftUI

public extension String {
    var toColor: Color {
        let hex = self.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        return Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
    
    
    func getAssetUrl(urlAsset: String = "", isCard:Bool = false, width:Int = 320, height:Int = 420) -> String {
        let urlAsset = "\(urlAsset)\(self)\(isCard ? "?width=\(width)&height=\(height)" : "")"
        return urlAsset
    }
    
    func getUrlDownload(urlAsset: String = "") -> String {
        let urlAsset = "\(urlAsset)\(self)?download=true"
        return urlAsset
    }
}
