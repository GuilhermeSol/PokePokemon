//
//  PokemonViewModel.swift
//  PokePokemon_iOS
//
//  Created by Guilherme Sol on 31/08/2025.
//

import Foundation

struct PokemonViewModel: PokemonViewable, Identifiable  {
    let id: Int
    let name: String
    let imageUrl: URL
    var details: [Detail]
}
