import Foundation
import SystemConfiguration

/// Monitors network reachability changes and notifies observers via a closure.
public final class NetworkListener {

    // MARK: - Types

    public enum Status: Equatable {
        case connected(interface: Interface)
        case disconnected

        public enum Interface: Equatable {
            case wifi
            case cellular
        }
    }

    public typealias StatusHandler = (Status) -> Void

    // MARK: - Public

    /// The most recently observed network status. `nil` until `start()` is called.
    public private(set) var currentStatus: Status?

    /// Called on `queue` whenever reachability changes.
    public var onStatusChange: StatusHandler?

    // MARK: - Private

    private let reachability: SCNetworkReachability
    private let queue: DispatchQueue

    // MARK: - Init

    /// Creates a listener that monitors reachability via a hostname probe.
    /// Using a hostname gives accurate results across Wi-Fi, cellular, and VPN.
    /// - Parameters:
    ///   - host: The host used as the reachability probe. Defaults to `"apple.com"`.
    ///   - queue: The dispatch queue on which `onStatusChange` is called.
    public init(
        host: String = "apple.com",
        queue: DispatchQueue = DispatchQueue(label: "com.secondpod.network-listener", qos: .utility)
    ) {
        // SCNetworkReachabilityCreateWithName is more accurate than address-based
        // creation because the OS evaluates the full routing policy for the host.
        self.reachability = SCNetworkReachabilityCreateWithName(nil, host)!
        self.queue = queue
    }

    deinit { stop() }

    // MARK: - Control

    /// Starts observing reachability. Fires `onStatusChange` with the current status immediately.
    public func start() {
        // Deliver current state synchronously before any callback fires.
        currentStatus = fetchStatus()

        var context = SCNetworkReachabilityContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        SCNetworkReachabilitySetCallback(reachability, { _, flags, info in
            guard let info else { return }
            let listener = Unmanaged<NetworkListener>.fromOpaque(info).takeUnretainedValue()
            let status = NetworkListener.Status(flags)
            listener.currentStatus = status
            listener.onStatusChange?(status)
        }, &context)

        SCNetworkReachabilitySetDispatchQueue(reachability, queue)
    }

    /// Stops observing and removes the callback.
    public func stop() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }

    // MARK: - Convenience

    /// `true` when the network is currently reachable.
    public var isConnected: Bool {
        if case .connected = currentStatus { return true }
        return false
    }

    // MARK: - Private

    private func fetchStatus() -> Status {
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(reachability, &flags) else { return .disconnected }
        return Status(flags)
    }
}

// MARK: - SCNetworkReachabilityFlags → Status

private extension NetworkListener.Status {
    init(_ flags: SCNetworkReachabilityFlags) {
        guard Self.isReachable(flags) else {
            self = .disconnected
            return
        }
        #if os(iOS)
        self = flags.contains(.isWWAN)
            ? .connected(interface: .cellular)
            : .connected(interface: .wifi)
        #else
        self = .connected(interface: .wifi)
        #endif
    }

    /// Mirrors Apple's recommended reachability evaluation:
    /// reachable AND (no connection required OR can connect automatically without user interaction).
    private static func isReachable(_ flags: SCNetworkReachabilityFlags) -> Bool {
        guard flags.contains(.reachable) else { return false }

        // No dial-up / VPN setup needed → directly reachable.
        if !flags.contains(.connectionRequired) { return true }

        // Connection is required but can be brought up on-demand/on-traffic
        // without prompting the user (e.g. VPN on demand, Wi-Fi auto-join).
        let canAutoConnect = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let noUserInteractionNeeded = !flags.contains(.interventionRequired)
        return canAutoConnect && noUserInteractionNeeded
    }
}
