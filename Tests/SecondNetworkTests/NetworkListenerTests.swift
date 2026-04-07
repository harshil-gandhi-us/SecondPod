import XCTest

@testable import SecondNetwork

final class NetworkListenerTests: XCTestCase {

    func testListenerStartsWithoutCrashing() {
        let listener = NetworkListener()
        listener.start()
        listener.stop()
    }

    func testStatusHandlerIsCalledOnStart() {
        let expectation = expectation(description: "status received")
        let listener = NetworkListener()
        listener.onStatusChange = { _ in
            expectation.fulfill()
        }
        listener.start()
        wait(for: [expectation], timeout: 3.0)
        listener.stop()
    }

    func testCurrentStatusSetAfterStart() {
        let listener = NetworkListener()
        XCTAssertNil(listener.currentStatus)
        listener.start()
        XCTAssertNotNil(listener.currentStatus)
        listener.stop()
    }

    func testIsConnectedReflectsCurrentStatus() {
        let listener = NetworkListener()
        XCTAssertFalse(listener.isConnected)
        listener.start()
        if case .connected = listener.currentStatus {
            XCTAssertTrue(listener.isConnected)
        } else {
            XCTAssertFalse(listener.isConnected)
        }
        listener.stop()
    }
}
