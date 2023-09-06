//
//  SwiftUIView.swift
//  
//
//  Created by Kellvem Barbosa on 06/09/2023.
//
import Foundation

public struct RefreshTokenModel: Codable {
    public var refreshToken: String
    public var mode: String
    
    public init(refreshToken: String, mode: String = "json") {
        self.refreshToken = refreshToken
        self.mode = mode
    }
    
    public enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case mode
    }
}
