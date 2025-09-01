//
//  PokemonListViewModel.swift
//  PokePokemon_iOS
//
//  Created by Guilherme Sol on 31/08/2025.
//

import Foundation
import PokePokemon

struct PokeListItem: Identifiable {
    var id = UUID()
    var name: String
    var url: String
}

class PokemonListViewModel {
    private var loader: PokemonsLoader
    internal var currentPage: Int = 0
    @Published var isLoading: Bool = false
    @Published var isLoadingNext: Bool = false
    @Published var items: [PokeListItem] = []
    @Published var pokeCard: PokemonViewModel?
    @Published var errorMessage: String?
    
    internal init(loader: PokemonsLoader) {
        self.loader = loader
    }
}

private extension PokemonListViewModel {
    @MainActor
    func load(page: Int = 0) async {
        guard !isLoading
        else {
            return
        }
        isLoading = true
        defer {

            isLoadingNext = false
            isLoading = false
        }
        let result = await loader.loadPokemons(page: page)
        switch result {
        case .success(let results):
            if page == 0 {
                items.removeAll()
                currentPage = 0
            }
            else {
                currentPage += 1
            }
            items = items + results
                .map{
                    .init(
                        name: $0.name.capitalized,
                        url: $0.url
                    )
                }
                .sorted {
                    $0.name < $1.name
                }
        case .failure(let error):
            if let error = error as? RemotePokemonsLoader.ResponseError {
                switch error {
                case .connectivity:
                    errorMessage = "Sorry, the pokemons appear to be on holidays and are not available at the moment, try again later."
                default:
                    errorMessage = error.localizedDescription
                }
            }
            else {
                errorMessage = error.localizedDescription
            }
        }
    }
}

extension PokemonListViewModel: PokemonListViewable {
    @MainActor
    func load() async {
        await load(page: 0)
    }
    
    @MainActor
    func loadNext() async {
        isLoadingNext = true
        await load(page: currentPage + 1)
    }
    
    @MainActor
    func refresh() async {
        await load(page: 0)
    }
    
    @MainActor
    func selected(_ item: PokeListItem) async {
        loader.cancel()
        isLoading = true
        defer {
            isLoadingNext = false
            isLoading = false
        }
        let result = await loader.loadPokemon(named: item.name)
        switch result {
        case .success(let pokemon):
            pokeCard = PokemonViewModel(
                id: pokemon.id,
                name: pokemon.name.capitalized,
                imageUrl: URL(string: pokemon.sprites.front_default ?? "")!,
                details: [.init(id: "Height", value: "\(pokemon.height)")]
            )
        case .failure(let error):
            if let error = error as? RemotePokemonsLoader.ResponseError {
                switch error {
                case .cancelled:
                    errorMessage = nil
                default:
                    errorMessage = error.localizedDescription
                }
            }
            else {
                errorMessage = error.localizedDescription
            }
        }
    }
}
