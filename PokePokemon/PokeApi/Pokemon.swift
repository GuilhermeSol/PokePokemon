//
//  Pokemon.swift
//  PokePokemon
//
//  Created by Guilherme Sol on 30/08/2025.
//

import Foundation

public struct Pokemon: Codable {
    public struct Sprites: Codable {
        public let front_default: String?
    }
    public let id: Int
    public let name: String
    public let height: Int
    public let sprites: Sprites
}
