//
//  SwiftUIView.swift
//  
//
//  Created by Kellvem Barbosa on 06/09/2023.
//

import Foundation

public struct AccessTokenModel: Codable {
    var accessToken: String
    var expires: Int
    var refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expires
        case refreshToken = "refresh_token"
    }
}
