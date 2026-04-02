# SecondPod

Lightweight iOS network reachability listener built on `SystemConfiguration`.

**Requires:** iOS 13+ · Swift 5.7+

---

## Installation

**SPM** — add to `Package.swift`:
```swift
.package(url: "https://github.com/harshil-gandhi-us/SecondPod.git", from: "1.0.0")
```

**CocoaPods:**
```ruby
pod 'SecondPod', '~> 1.0'
```

---

## Usage

```swift
import SecondPod

let listener = NetworkListener()
listener.start()

listener.onStatusChange = { status in
    switch status {
    case .connected(let interface): print("Online via \(interface)") // .wifi or .cellular
    case .disconnected:             print("Offline")
    }
}

// Stop when done
listener.stop()
```

Custom probe host or queue:
```swift
let listener = NetworkListener(host: "yourapi.com", queue: .main)
```

---

## API

| Member | Description |
|--------|-------------|
| `init(host:queue:)` | Probe host (default `"apple.com"`), callback queue (default background). |
| `start()` | Begin observing. Sets `currentStatus` immediately. |
| `stop()` | Stop observing. |
| `onStatusChange` | Closure called on every change. |
| `currentStatus` | Last known `Status`. `nil` before `start()`. |
| `isConnected` | `true` when connected. |

---

See [CHANGELOG.md](CHANGELOG.md) · [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) · [LICENSE](LICENSE)
