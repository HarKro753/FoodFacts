//
//  NetworkMonitor.swift
//  Env
//
//  Created by Harro Krog on 20.11.25.
//

import Foundation
import Network
import SwiftUI

@MainActor
@Observable
public class NetworkMonitor {
    public static let shared = NetworkMonitor()

    private var _isConnected: Bool = true

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?._isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    public func getIsConnected() -> Bool {
        return _isConnected
    }

    public func stopMonitoring() {
        monitor.cancel()
    }
}
