//
//  SwiftUIView.swift
//  
//
//  Created by Kellvem Barbosa on 01/05/2023.
//

import SwiftUI

public struct StateAPI <T: Codable> {
    public var items: T
    public var page: Int
    public var canLoadNextPage: Bool
    public var hasError: Bool
    
    public init(items: T, page: Int = 1, canLoadNextPage: Bool = true, hasError: Bool = false) {
        self.items = items
        self.page = page
        self.canLoadNextPage = canLoadNextPage
        self.hasError = hasError
    }
}
