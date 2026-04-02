# Changelog

All notable changes to SecondPod are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) · [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

---

## [1.0.0] — 2026-04-02

### Added
- `NetworkListener` using `SCNetworkReachability` for accurate iOS network monitoring.
- `.connected(.wifi)` / `.connected(.cellular)` / `.disconnected` status reporting.
- Hostname-based probe (`"apple.com"` by default) for reliable results over Wi-Fi, cellular, and VPN.
- SPM (`Package.swift`) and CocoaPods (`SecondPod.podspec`) support.
- Reference examples: UIViewController, Combine/SwiftUI, async/await.
