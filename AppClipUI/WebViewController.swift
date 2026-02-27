import UIKit
import WebKit

// swiftlint:disable uiviewcontroller_invalid_subclass
public final class WebViewController: UIViewController, WKScriptMessageHandler {
    private let url: URL?
    private let htmlString: String?
    private var webView: WKWebView!

    /// Callback when JS bridge receives a message
    public var onJSBridgeMessage: (([String: Any]) -> Void)?

    public init(url: URL) {
        self.url = url
        self.htmlString = nil
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }

    public init(html: String) {
        self.url = nil
        self.htmlString = html
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Full Screen Support

    public override var prefersStatusBarHidden: Bool {
        true
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .fade
    }

    public override var prefersHomeIndicatorAutoHidden: Bool {
        false
    }

    public override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        [.bottom]
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Configure WebView
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController.add(self, name: "appClipAuth")

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = .white

        view.addSubview(webView)

        // Layout constraints
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Load content
        if let htmlString {
            webView.loadHTMLString(htmlString, baseURL: nil)
        } else if let url {
            webView.load(URLRequest(url: url))
        }
    }

    // MARK: - WKScriptMessageHandler

    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "appClipAuth",
              let body = message.body as? [String: Any] else {
            return
        }
        print("JS_BRIDGE: received message from WebView: \(body)")
        onJSBridgeMessage?(body)
    }
}

// swiftlint:enable uiviewcontroller_invalid_subclass
