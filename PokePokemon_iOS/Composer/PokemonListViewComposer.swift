//
//  PokemonListViewComposer.swift
//  PokePokemon_iOS
//
//  Created by Guilherme Sol on 31/08/2025.
//

import Foundation
import SwiftUI
import PokePokemon


public class PokemonListViewComposer {
    public static func pokemonListView() -> some View {
        let loader = RemotePokemonsLoader()
        let viewModel = PokemonListViewModel(loader: loader)
        let view = PokemonListView(viewModel: viewModel)
        return view
    }
}
