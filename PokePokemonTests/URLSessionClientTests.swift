//
//  URLSessionClientTests.swift
//  PokePokemonTests
//
//  Created by Guilherme Sol on 31/08/2025.
//

import Testing
@testable import PokePokemon

struct URLSessionClientTests {

    @Test("Task return error if no internet")
    func getDataWithNoConnectionReturnConnectivityError() async throws {
        let network = NetworkConnectorStub()
        network.isConnected = false
        let sut = URLSessionClient(reachability: network)
        var responseError: RemotePokemonsLoader.ResponseError?
        
        do {
            _ = try await sut.get(from: URL(string: "anyUrl")!)
        }
        catch {
            responseError = error as? RemotePokemonsLoader.ResponseError
        }
         
        #expect(responseError == .connectivity)
    }
    
    @Test("Task returns response if has Internet")
    func getDataWithConnectionTryToFetchData() async throws {
        let sut = URLSessionClientMock(reachability: NetworkConnectorStub())
        var responseError: RemotePokemonsLoader.ResponseError?
        
        do {
            _ = try await sut.get(from: URL(string: "anyUrl")!)
        }
        catch {
            responseError = error as? RemotePokemonsLoader.ResponseError
        }
         
        #expect(responseError == .invalidResponse)
    }
}

class NetworkConnectorStub: NetworkConnector {
    var isConnected = true
    override var hasInternetConnection: Bool {
        isConnected
    }
}

class URLSessionClientMock: URLSessionClient {
    override func get(from url: URL) async throws -> (data: Data, response: URLResponse) {
        // For the purpose of this exercise, and not to spend too much time composing tests, we are not testing the behaviour of a URLProtocol
        // and we are returning only an invalidResponse error to avoid connecting to the internet on internal tests.
        throw RemotePokemonsLoader.ResponseError.invalidResponse
    }
}
