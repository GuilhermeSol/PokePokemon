//
//  HTTPClient.swift
//  PokePokemon
//
//  Created by Guilherme Sol on 31/08/2025.
//

import Foundation


public protocol HTTPClient {
    func get(from url: URL) async throws -> (data: Data, response: URLResponse)
    func cancel()
}

public protocol NetworkReachability {
    var hasInternetConnection: Bool { get }
}
