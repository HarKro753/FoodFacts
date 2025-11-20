//
//  NetworkMonitor.swift
//  FoodFacts
//
//  Created by Harro Krog on 20.11.25.
//

import Foundation
import Network
import Combine

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published var isConnected: Bool = true
    @Published var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.getConnectionType(path) ?? .unknown
            }
        }
        monitor.start(queue: queue)
    }

    private func getConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        }
        return .unknown
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    var connectionDescription: String {
        if !isConnected {
            return "No Internet Connection"
        }
        switch connectionType {
        case .wifi:
            return "Connected via Wi-Fi"
        case .cellular:
            return "Connected via Cellular"
        case .ethernet:
            return "Connected via Ethernet"
        case .unknown:
            return "Connected"
        }
    }
}
