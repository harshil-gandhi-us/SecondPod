// BasicUsage.swift — SecondPod reference examples
// This file is for documentation purposes only; it is not part of the compiled library.

import Foundation
import Combine
import SecondPod

// MARK: - 1. Simple one-shot listener

func exampleSimple() {
    let listener = NetworkListener()
    listener.start()
    listener.onStatusChange = { status in
        switch status {
        case .connected(let interface):
            print("Online via \(interface)")   // .wifi or .cellular
        case .disconnected:
            print("Offline")
        }
    }

   
    // Call listener.stop() when you no longer need updates.
}


// MARK: - 2. Check connectivity at a single point in time

func exampleSnapshot() {
    let listener = NetworkListener()
    listener.start()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        print("Connected? \(listener.isConnected)")
        print("Status: \(String(describing: listener.currentStatus))")
        listener.stop()
    }
}


// MARK: - 3. Deliver updates on the main thread

func exampleMainQueueUpdates() {
    let listener = NetworkListener(queue: .main)
    listener.start()
    listener.onStatusChange = { status in
        // Already on the main thread — safe to update UI directly.
        switch status {
        case .connected(let interface):
            print("Interface: \(interface) — update UI here")
        case .disconnected:
            print("No connection — show offline banner")
        }
    }

   
}


// MARK: - 4. Lifecycle tied to a view controller

#if canImport(UIKit)
import UIKit

final class HomeViewController: UIViewController {

    private let networkListener = NetworkListener(queue: .main)

    override func viewDidLoad() {
        super.viewDidLoad()

        networkListener.onStatusChange = { [weak self] status in
            self?.handleNetworkStatus(status)
        }
        networkListener.start()
    }

    deinit {
        networkListener.stop()
    }

    private func handleNetworkStatus(_ status: NetworkListener.Status) {
        switch status {
        case .connected(let interface):
            print("HomeVC — connected via \(interface)")
        case .disconnected:
            print("HomeVC — no network, show alert or banner")
        }
    }
}
#endif


// MARK: - 5. Combine / SwiftUI

final class NetworkViewModel: ObservableObject {

    @Published var isOnline: Bool = false
    @Published var interfaceType: NetworkListener.Status.Interface?

    private let listener = NetworkListener(queue: .main)

    init() {
        listener.onStatusChange = { [weak self] status in
            switch status {
            case .connected(let interface):
                self?.isOnline = true
                self?.interfaceType = interface
            case .disconnected:
                self?.isOnline = false
                self?.interfaceType = nil
            }
        }
        listener.start()
    }

    deinit { listener.stop() }
}


// MARK: - 6. Async/await — wait for first connection

func waitForConnection() async -> NetworkListener.Status.Interface {
    await withCheckedContinuation { continuation in
        let listener = NetworkListener(queue: .main)

        listener.onStatusChange = { status in
            if case .connected(let interface) = status {
                listener.stop()
                continuation.resume(returning: interface)
            }
        }

        listener.start()
    }
}

// Usage:
// Task {
//     let interface = await waitForConnection()
//     print("First connected via \(interface)")
// }
