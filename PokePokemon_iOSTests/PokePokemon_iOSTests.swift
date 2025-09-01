//
//  PokePokemon_iOSTests.swift
//  PokePokemon_iOSTests
//
//  Created by Guilherme Sol on 31/08/2025.
//

import Testing
import Combine
@testable import PokePokemon
@testable import PokePokemon_iOS

private let mockedName: String = "mocked"

struct PokePokemon_iOSTests {
    @Test("Load Pokemons Fails Display Error")
    func loadItemsOnViewModelDisplayErrorMessageOnLoadError() async throws {
        let loader = PokemonsLoaderMock()
        loader.completionError = .invalidData
        let vm = PokemonListViewModel(loader: loader)
        
        #expect(vm.errorMessage == nil)
        
        await vm.load()
        
        #expect(vm.items.isEmpty)
        #expect(vm.pokeCard == nil)
        #expect(vm.errorMessage == loader.completionError?.localizedDescription)
    }
    
    @Test("Load Pokemons Display Items")
    func loadItemsDisplayItems() async throws {
        let vm = PokemonListViewModel(loader: PokemonsLoaderMock())
        
        #expect(vm.items.isEmpty)
        
        await vm.load()
        
        #expect(!vm.items.isEmpty)
        #expect(vm.errorMessage == nil)
        #expect(vm.pokeCard == nil)
    }
    
    @Test("Load Pokemons Display Next Items")
    func loadNextItemsRequestNextItems() async throws {
        let loader = PokemonsLoaderMock()
        
        let vm = PokemonListViewModel(loader: loader)
        #expect(loader.lastPageCalled == nil)
        #expect(vm.currentPage == 0)
        #expect(vm.items.count == 0)
        
        await vm.load()
        #expect(loader.lastPageCalled == 0)
        #expect(vm.currentPage == 0)
        #expect(vm.items.count == 1)
        
        await vm.loadNext()
        #expect(loader.lastPageCalled == 1)
        #expect(vm.currentPage == 1)
        #expect(vm.items.count == 2)
    }
    
    @Test("Load Pokemons Display Next Items")
    func loadNextItemsFailDoesNotUpdatePage() async throws {
        let loader = PokemonsLoaderMock()
        let vm = PokemonListViewModel(loader: loader)
        await vm.load()
        #expect(loader.lastPageCalled == 0)
        #expect(vm.currentPage == 0)
        #expect(vm.items.count == 1)
        
        loader.completionError = .invalidResponse
        await vm.loadNext()
        #expect(loader.lastPageCalled == 1)
        #expect(vm.currentPage == 0)
        #expect(vm.items.count == 1)
    }
    
    @Test("Load Pokemons Updates Loading Next")
    func loadingToggleIsLoading() async throws {
        let vm = PokemonListViewModel(loader: PokemonsLoaderMock())
        
        async let loadTask: () = vm.load()
        await waitLoadingNextChange(on: vm, expected: false)
        await loadTask
        #expect(!vm.isLoading)
        #expect(!vm.isLoadingNext)
        
        async let loadnextTask: () = vm.loadNext()
        await waitLoadingNextChange(on: vm, expected: true)
        await loadnextTask
        #expect(!vm.isLoading)
        #expect(!vm.isLoadingNext)
        
        async let refreshTask: () = vm.refresh()
        await waitLoadingNextChange(on: vm, expected: false)
        await refreshTask
        #expect(!vm.isLoading)
        #expect(!vm.isLoadingNext)
    }
    
    @Test("Load Next Pokemons displays Bottom Spinner")
    func loadingNextTogglesSpinners() async throws {
        let vm = PokemonListViewModel(loader: PokemonsLoaderMock())
        
        async let loadTask: () = vm.load()
        await waitIsLoadingChange(on: vm, expected: true)
        await loadTask
        #expect(!vm.isLoading)
        #expect(!vm.isLoadingNext)
        
        async let loadnextTask: () = vm.loadNext()
        await waitIsLoadingChange(on: vm, expected: true)
        await loadnextTask
        #expect(!vm.isLoading)
        #expect(!vm.isLoadingNext)
        
        async let refreshTask: () = vm.refresh()
        await waitIsLoadingChange(on: vm, expected: true)
        await refreshTask
        #expect(!vm.isLoading)
        #expect(!vm.isLoadingNext)
    }
    
    ///MARK: Load Pokemon Tests
    
    @Test("Load Pokemon Fails Display Error")
    func loadPokemonOnViewModelDisplayErrorMessageOnLoadError() async throws {
        let loader = PokemonsLoaderMock()
        loader.completionError = .invalidResponse
        let vm = PokemonListViewModel(loader: loader)
        
        #expect(vm.errorMessage == nil)
        
        await vm.selected(PokeListItem(name: "anyName", url: "anyURl"))
        
        #expect(vm.items.isEmpty)
        #expect(vm.pokeCard == nil)
        #expect(vm.errorMessage == loader.completionError?.localizedDescription)
    }
    
    @Test("Load Pokemon Display Card")
    func loadPokemonDisplayItems() async throws {
        let vm = PokemonListViewModel(loader: PokemonsLoaderMock())
        
        #expect(vm.pokeCard == nil)
        
        await vm.selected(.init(name: "any", url: "AnyUrl"))
        
        #expect(vm.items.isEmpty)
        #expect(vm.errorMessage == nil)
        #expect(vm.pokeCard != nil)
    }
    
    @Test("Load Pokemons Cancel current task")
    func loadPokemonsCancelcurrentTask() async throws {
        let loader = PokemonsLoaderMock()
        
        let vm = PokemonListViewModel(loader: loader)
        #expect(loader.cancelCalled == nil)
        
        await vm.selected(.init(name: "any", url: "AnyUrl"))
        #expect(loader.cancelCalled == true)
    }
}

private extension PokePokemon_iOSTests {
    func waitLoadingNextChange(on sut: PokemonListViewModel, expected: Bool) async {
        var cancelables = Set<AnyCancellable>()
        await withCheckedContinuation { continuation in
            sut.$isLoading
                .sink { loading in
                    if loading == expected {
                        continuation.resume()
                    }
                }
                .store(in: &cancelables)
        }
    }
    
    func waitIsLoadingChange(on sut: PokemonListViewModel, expected: Bool) async {
        var cancelables = Set<AnyCancellable>()
        await withCheckedContinuation { continuation in
            sut.$isLoading
                .sink { loading in
                    if loading == expected {
                        continuation.resume()
                    }
                }
                .store(in: &cancelables)
        }
    }
}

private class PokemonsLoaderMock: PokemonsLoader {
    var lastPageCalled: Int?
    var cancelCalled: Bool?
    var completionError: RemotePokemonsLoader.ResponseError?
    
    func loadPokemons(page: Int = 0) async -> Result<[PokeItem], any Error> {
        lastPageCalled = page
        if let error = completionError {
            return .failure(error)
        }
        let pokeItems:[PokeItem] = [.init(name: mockedName, url: "AnyUrl")]
        return .success(pokeItems)
    }
    
    func loadPokemon(named: String) async -> Result<Pokemon, any Error> {
        if let error = completionError {
            return .failure(error)
        }
        let pokemon = Pokemon.init(
            id: 1,
            name: mockedName,
            height: 1,
            sprites: Pokemon.Sprites(front_default: "AnyUrl")
        )
        return .success(pokemon)
    }
    
    func cancel() {
        cancelCalled = true
    }
}
