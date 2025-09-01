//
//  PokemonsLoaderTests.swift
//  PokePokemonTests
//
//  Created by Guilherme Sol on 30/08/2025.
//

import Testing
@testable import PokePokemon
import XCTest

struct PokemonsLoaderTests {
    
    @Test("Load not called at instantiation")
    func noRequestAtInit() {
        let (_, client) = makeSUt()
        
        #expect(client.url == nil)
    }
    
    @Test("Load request from URL")
    func loadPokemonsRequestUrl() async {
        let url = "https://pokeapi.co/api/v2/pokemon?offset=0&limit=20"
        let (sut, client) = makeSUt()
        
        _ = await sut.loadPokemons()
        
        #expect(client.url?.absoluteString == url)
    }
    
    @Test("Load request returns Connectivity error")
    func loadRequestReturnsConnectivityError() async {
        let (sut, client) = makeSUt()
        var responseError: RemotePokemonsLoader.ResponseError?
        client.completionError = .connectivity
        
        let result = await sut.loadPokemons()
        do {
            _ = try result.get()
        }
        catch {
            responseError = error as? RemotePokemonsLoader.ResponseError
        }

        #expect(responseError == .connectivity)
    }
    
    @Test("Load request returns invalid Data error", arguments: Array(400...420) + Array(500...505))
    func loadRequestReturnsInvalidResponseError(statusCode: Int) async {
        let (sut, client) = makeSUt()
        var responseError: RemotePokemonsLoader.ResponseError?
        client.statusCode = statusCode
        
        let result = await sut.loadPokemons()
        do {
            _ = try result.get()
        }
        catch {
            responseError = error as? RemotePokemonsLoader.ResponseError
        }
        
        #expect(responseError == .invalidResponse)
    }
    
    @Test("Load request returns invalid Data error")
    func loadRequestReturnsInvalidDataError() async {
        let (sut, _) = makeSUt()
        var responseError: RemotePokemonsLoader.ResponseError?
        
        let result = await sut.loadPokemons()
        do {
            _ = try result.get()
        }
        catch {
            responseError = error as? RemotePokemonsLoader.ResponseError
        }
        
        #expect(responseError == .invalidData)
    }
    
    @Test("Load request returns valid Data")
    func loadRequestReturnsValidData() async throws {
        let (sut, client) = makeSUt()
        let pokeItems = ["results":[["name":"name", "url":"someUrl1"]]]
        client.result = try JSONEncoder().encode(pokeItems)
        
        let result = await sut.loadPokemons()
        let items = try result.get()

        #expect(!items.isEmpty)
    }
    
    
    
    
    @Test("Load Pokemon request from URL")
    func loadPokemonRequestFromUrl() async {
        let url = "https://pokeapi.co/api/v2/pokemon/anyName"
        let (sut, client) = makeSUt()
        
        _ = await sut.loadPokemon(named: "anyName")
        
        #expect(client.url?.absoluteString == url)
    }
    
    @Test("Load request returns Connectivity error")
    func loadPokemonRequestReturnsConnectivityError() async {
        let (sut, client) = makeSUt()
        var responseError: RemotePokemonsLoader.ResponseError?
        client.completionError = .connectivity
        
        let result = await sut.loadPokemon(named: "anyName")
        do {
            _ = try result.get()
        }
        catch {
            responseError = error as? RemotePokemonsLoader.ResponseError
        }

        #expect(responseError == .connectivity)
    }
    
    @Test("Load request returns invalid Data error", arguments: Array(400...420) + Array(500...505))
    func loadPokemonRequestReturnsInvalidResponseError(statusCode: Int) async {
        let (sut, client) = makeSUt()
        var responseError: RemotePokemonsLoader.ResponseError?
        client.statusCode = statusCode
        
        let result = await sut.loadPokemon(named: "anyName")
        do {
            _ = try result.get()
        }
        catch {
            responseError = error as? RemotePokemonsLoader.ResponseError
        }
        
        #expect(responseError == .invalidResponse)
    }
    
    @Test("Load request returns invalid Data error")
    func loadPokemonRequestReturnsInvalidDataError() async {
        let (sut, _) = makeSUt()
        var responseError: RemotePokemonsLoader.ResponseError?
        
        let result = await sut.loadPokemon(named: "anyName")
        do {
            _ = try result.get()
        }
        catch {
            responseError = error as? RemotePokemonsLoader.ResponseError
        }
        
        #expect(responseError == .invalidData)
    }
    
    @Test("Load request returns valid Data")
    func loadPokemonRequestReturnsValidData() async throws {
        let (sut, client) = makeSUt()
        let pokemon = Pokemon(id: 1, name: "charmander", height: 6, sprites: Pokemon.Sprites(front_default: "anyUrl"))
        client.result = try JSONEncoder().encode(pokemon)
        
        let result = await sut.loadPokemon(named: "charmander")
        let item = try result.get()
        
        #expect(item.name == "charmander")
    }
}

private extension PokemonsLoaderTests {
    class HTTPClientStub: HTTPClient {
        var url: URL?
        var completionError: RemotePokemonsLoader.ResponseError?
        var statusCode = 200
        var result: Data = Data()
        
        func get(from url: URL) async throws -> (data: Data, response: URLResponse) {
            self.url = url
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            if let completionError {
                if completionError == .invalidData {
                    return (result, response)
                }
                throw completionError
            }
            return (result, response)
        }
        
        func cancel() {
            
        }
    }
    
    func makeSUt() -> (RemotePokemonsLoader, client: HTTPClientStub) {
        let client = HTTPClientStub()
        let sut = RemotePokemonsLoader(client: client)
        return (sut,client)
    }
}

