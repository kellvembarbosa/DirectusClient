//
//  SwiftUIView.swift
//  
//
//  Created by Kellvem Barbosa on 06/09/2023.
//

import Foundation

public struct AccessTokenModel: Codable {
    public var accessToken: String
    public var expires: Int
    public var refreshToken: String
    
    public enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expires
        case refreshToken = "refresh_token"
    }
}
