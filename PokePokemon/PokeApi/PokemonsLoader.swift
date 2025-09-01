//
//  PokemonsLoader.swift
//  PokePokemon
//
//  Created by Guilherme Sol on 31/08/2025.
//

import Foundation

public protocol PokemonsLoader {
    func loadPokemons(page: Int) async -> Result<[PokeItem], Error>
    func loadPokemon(named: String) async -> Result<Pokemon, Swift.Error>
    func cancel()
}
