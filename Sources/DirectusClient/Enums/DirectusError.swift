//
//  DirectusError.swift
//  
//
//  Created by Kellvem Barbosa on 06/09/2023.
//

import Foundation

/// DirectusError
/// write doc
public enum DirectusError: Error {
    case unauthorized
    case invalidUrl
    case emptyResponse
    case other(Error)
}
