//
//  PokePokemonServerDataTests.swift
//  PokePokemonServerDataTests
//
//  Created by Guilherme Sol on 31/08/2025.
//

import Testing
@testable import PokePokemon

struct PokePokemonServerDataTests {
    
    let reachability = NetworkConnector()
    
    @Test("Client returns Pokemons")
    mutating func loadPokemons() async throws {
        let sut = RemotePokemonsLoader()

        let result = await sut.loadPokemons()
        let retrievedPokemons = try result.get()
        
        #expect(retrievedPokemons.count == 20)
    }
    
    ///MARK: Real No internet tests must have the internet access disabled.
    
    @Test("Client returns error if no internet and no cache")
    func loadPokemonsIsEmptyWithNoInternet() async {
        guard !reachability.hasInternetConnection
        else {
            return // no point to perform a real internet connection test if there is internet connection
        }
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let client = URLSessionClient(configuration: configuration, reachability: NoNetwork())
        let sut = RemotePokemonsLoader(client: client)
        var responseError: RemotePokemonsLoader.ResponseError?
        do {
            let result = await sut.loadPokemons()
            let pokemons = try result.get()
            #expect(pokemons.isEmpty)
        }
        catch {
            responseError = error as? RemotePokemonsLoader.ResponseError
        }
        #expect(responseError == .connectivity)
    }
    
    
    @Test("Client returns Pokemons")
    mutating func loadPokemon() async throws {
        let name = "charmander"

        let sut = RemotePokemonsLoader()
        
        let result = await sut.loadPokemon(named: name)
        let pokemon = try result.get()
        
        #expect(pokemon.name == name)
    }
}

class NoNetwork: NetworkConnector {
    override var hasInternetConnection: Bool {
        false
    }
}
