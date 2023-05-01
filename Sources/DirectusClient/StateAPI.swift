//
//  SwiftUIView.swift
//  
//
//  Created by Kellvem Barbosa on 01/05/2023.
//

import SwiftUI

public struct StateAPI <T: Codable> {
    public var items: T
    public var page: Int = 1
    public var canLoadNextPage = true
}
