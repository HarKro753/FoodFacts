//
//  NetworkMonitor.swift
//  Env
//
//  Created by Harro Krog on 20.11.25.
//

import Foundation
import Network
import Combine
import SwiftUI

@MainActor
@Observable
public class NetworkMonitor {
    public static let shared = NetworkMonitor()

    public var isConnected: Bool = true
    public var connectionType: ConnectionType = .unknown

    public enum ConnectionType {
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

    public func stopMonitoring() {
        monitor.cancel()
    }

    public var connectionDescription: String {
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
