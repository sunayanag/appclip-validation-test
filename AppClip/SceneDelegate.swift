import AppClipUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let testHTML = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body { font-family: -apple-system, sans-serif; padding: 40px 20px; text-align: center; background: #f5f5f5; }
            h1 { color: #0aad0a; }
            button { background: #0aad0a; color: white; border: none; padding: 16px 32px; border-radius: 8px; font-size: 18px; margin-top: 20px; }
            #status { margin-top: 20px; padding: 12px; background: white; border-radius: 8px; font-family: monospace; }
        </style>
    </head>
    <body>
        <h1>Instacart App Clip</h1>
        <p>JS Bridge + Token Storage Test</p>
        <button onclick="sendToken()">Send Token via JS Bridge</button>
        <div id="status">Ready</div>
        <script>
            function sendToken() {
                var payload = { token: "test-token-123", username: "clip-user" };
                document.getElementById('status').innerText = 'Sending: ' + JSON.stringify(payload);
                try {
                    webkit.messageHandlers.appClipAuth.postMessage(payload);
                    document.getElementById('status').innerText = 'Sent! Check native logs.';
                } catch(e) {
                    document.getElementById('status').innerText = 'Error: ' + e.message;
                }
            }
            // Auto-send after 1 second for automated testing
            setTimeout(sendToken, 1000);
        </script>
    </body>
    </html>
    """

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.frame = windowScene.coordinateSpace.bounds
        self.window = window

        // Use test HTML to validate JS bridge and token storage
        let webVC = WebViewController(html: testHTML)
        webVC.onJSBridgeMessage = { body in
            self.handleBridgeMessage(body)
        }
        window.rootViewController = webVC
        window.makeKeyAndVisible()
    }

    private func handleBridgeMessage(_ body: [String: Any]) {
        guard let token = body["token"] as? String,
              let username = body["username"] as? String else {
            print("JS_BRIDGE: invalid payload: \(body)")
            return
        }

        print("JS_BRIDGE: parsed token=\(token) username=\(username)")

        // Write to App Group UserDefaults (works on simulator)
        let defaultsToken = AppGroupStorage.saveToDefaults(key: "authToken", value: token)
        let defaultsUser = AppGroupStorage.saveToDefaults(key: "username", value: username)
        print("WRITE: defaults token=\(defaultsToken) user=\(defaultsUser)")

        // Write to App Group Keychain (works on device, returns -34018 on simulator)
        let kcToken = AppGroupStorage.saveToKeychain(key: "authToken", value: token)
        let kcUser = AppGroupStorage.saveToKeychain(key: "username", value: username)
        print("WRITE: keychain token=\(kcToken) user=\(kcUser)")
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Handle URL when app clip is invoked while already running
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }

        if let window {
            let webViewController = WebViewController(url: url)
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = webViewController
            }
        }
    }
}
