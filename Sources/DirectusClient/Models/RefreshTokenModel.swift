//
//  SwiftUIView.swift
//  
//
//  Created by Kellvem Barbosa on 06/09/2023.
//
import Foundation

public struct RefreshTokenModel: Codable {
    var refreshToken: String
    var mode: String = "json"
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case mode
    }
}
