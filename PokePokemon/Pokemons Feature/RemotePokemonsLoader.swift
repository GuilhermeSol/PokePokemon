//
//  PokemonLoader.swift
//  PokePokemon
//
//  Created by Guilherme Sol on 30/08/2025.
//

import Foundation

private struct PokeResults: Codable {
    var results: [PokeItem]
}

public struct RemotePokemonsLoader {
    public enum ResponseError: Swift.Error {
        case connectivity
        case invalidResponse
        case invalidData
        case cancelled
    }
    
    struct PokeApiUrls {
        private static let baseUrlString = "https://pokeapi.co/api/v2/pokemon"
        
        private static func baseUrl() -> URL {
            URL(string: baseUrlString)!
        }
        
        static func pokemonsUrl(page: Int = 0) -> URL {
            let limit = 20
            let pagination = "?offset=\(page*limit)&limit=\(limit)"
            let url = baseUrl().absoluteString + pagination
            return URL(string: url)!
        }
        
        static func pokemonUrl(named: String) -> URL {
            baseUrl().appendingPathComponent("/\(named)")
        }
    }
    
    private var client: HTTPClient
    
    public init(client: HTTPClient = URLSessionClient()) {
        self.client = client
    }
}

extension RemotePokemonsLoader: PokemonsLoader {
    public func loadPokemons(page: Int = 0) async -> Result<[PokeItem], Swift.Error> {
        cancel()
        let result: (data: Data, response: URLResponse)
        do {
            result = try await client.get(from: PokeApiUrls.pokemonsUrl(page: page))
        }
        catch {
            return .failure(RemotePokemonsLoader.ResponseError.connectivity)
        }
        guard let response = result.response as? HTTPURLResponse,
              response.statusCode == 200
        else {
            return .failure(RemotePokemonsLoader.ResponseError.invalidResponse)
        }
        do {
            let pokeResults = try JSONDecoder().decode(PokeResults.self, from: result.data)
            return .success(pokeResults.results)
        }
        catch {
            return .failure(RemotePokemonsLoader.ResponseError.invalidData)
        }
    }
    
    public func loadPokemon(named: String) async -> Result<Pokemon, any Error> {
        cancel()
        let result: (data: Data, response: URLResponse)
        do {
            let url = PokeApiUrls.pokemonUrl(named: named)
            result = try await client.get(from: url)
        }
        catch is CancellationError {
            return .failure(RemotePokemonsLoader.ResponseError.cancelled)
        }
        catch {
            return .failure(RemotePokemonsLoader.ResponseError.connectivity)
        }
        guard let response = result.response as? HTTPURLResponse,
              response.statusCode == 200
        else {
            return .failure(RemotePokemonsLoader.ResponseError.invalidResponse)
        }
        do {
            let pokemon = try JSONDecoder().decode(Pokemon.self, from: result.data)
            return .success(pokemon)
        }
        catch {
            return .failure(RemotePokemonsLoader.ResponseError.invalidData)
        }
    }
    
    public func cancel() {
        client.cancel()
    }
}
