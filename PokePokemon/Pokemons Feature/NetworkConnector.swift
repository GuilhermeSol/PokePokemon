//
//  NetworkConnector.swift
//  PokePokemon
//
//  Created by Guilherme Sol on 31/08/2025.
//

import Foundation
import Network

public class NetworkConnector: NetworkReachability {
    
    public var hasInternetConnection: Bool{ isConnected }
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var isConnected = false
    
    public init () {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
