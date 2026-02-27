import SwiftUI

struct HostContentView: View {
    @State private var defaultsToken = "—"
    @State private var defaultsUsername = "—"
    @State private var keychainToken = "—"
    @State private var keychainStatus: OSStatus = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Instacart Host App")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
                Text("App Group UserDefaults:")
                    .font(.headline)
                Text("  Token: \(defaultsToken)")
                Text("  Username: \(defaultsUsername)")

                Divider()

                Text("App Group Keychain:")
                    .font(.headline)
                Text("  Token: \(keychainToken)")
                Text("  Status: \(keychainStatus) \(keychainStatus == 0 ? "(ok)" : keychainStatus == -34018 ? "(expected on sim)" : "")")
            }
            .font(.body.monospaced())
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            Button("Refresh") { readAll() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear { readAll() }
    }

    private func readAll() {
        defaultsToken = AppGroupStorage.readFromDefaults(key: "authToken") ?? "(empty)"
        defaultsUsername = AppGroupStorage.readFromDefaults(key: "username") ?? "(empty)"
        let kr = AppGroupStorage.readFromKeychain(key: "authToken")
        keychainToken = kr.value ?? "(empty)"
        keychainStatus = kr.status
        print("HOST_READ: defaults=\(defaultsToken)/\(defaultsUsername) keychain=\(keychainToken) status=\(keychainStatus)")
    }
}
