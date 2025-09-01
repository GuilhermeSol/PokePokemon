//
//  URLSessionClient.swift
//  PokePokemon
//
//  Created by Guilherme Sol on 31/08/2025.
//

import Foundation

public class URLSessionClient: HTTPClient {
    private let session: URLSession
    private let reachability: NetworkReachability
    private var currentTask: Task<(Data, URLResponse), any Error>?
    public init(configuration: URLSessionConfiguration = .default, reachability: NetworkReachability = NetworkConnector()) {
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: configuration)
        self.reachability = reachability
    }

    public func get(from url: URL) async throws -> (data: Data, response: URLResponse) {
        guard reachability.hasInternetConnection
        else {
            throw RemotePokemonsLoader.ResponseError.connectivity
        }
        let task = Task {
            // As the purpose of this project is to test architecture, I'm adding a delay on the callback to check
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return try await session.data(from: url)
        }
        currentTask = task
        return try await task.value
    }
    
    public func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
}

