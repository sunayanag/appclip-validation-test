import XCTest
import WebKit
@testable import AppClipUI

/// Tests that validate the JS bridge (WebView → native) works correctly.
/// This proves: webkit.messageHandlers.appClipAuth.postMessage() → WKScriptMessageHandler
final class JSBridgeTests: XCTestCase {

    func testWebViewControllerReceivesJSBridgeMessage() {
        let expectation = expectation(description: "JS bridge message received")
        var receivedBody: [String: Any]?

        let html = """
        <html><body>
        <script>
            // Send token immediately on load
            webkit.messageHandlers.appClipAuth.postMessage({
                token: "test-token-123",
                username: "clip-user"
            });
        </script>
        </body></html>
        """

        let vc = WebViewController(html: html)
        vc.onJSBridgeMessage = { body in
            receivedBody = body
            expectation.fulfill()
        }

        // Load the view to trigger viewDidLoad → WebView loads HTML
        vc.loadViewIfNeeded()

        // Need a window for WebView to actually render and execute JS
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = vc
        window.makeKeyAndVisible()

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "JS bridge message should be received within timeout")
        }

        XCTAssertNotNil(receivedBody, "Should have received a message body")
        XCTAssertEqual(receivedBody?["token"] as? String, "test-token-123")
        XCTAssertEqual(receivedBody?["username"] as? String, "clip-user")
    }

    func testWebViewControllerLoadsURL() {
        // Verify the URL-based init doesn't crash
        guard let url = URL(string: "https://example.com") else {
            XCTFail("Could not create URL")
            return
        }
        let vc = WebViewController(url: url)
        vc.loadViewIfNeeded()
        XCTAssertNotNil(vc.view, "View should load without crashing")
    }
}
