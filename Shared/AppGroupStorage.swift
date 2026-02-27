import Foundation
import Security

/// Shared storage using the real Instacart App Group: group.com.instacart
enum AppGroupStorage {
    static let suiteName = "group.com.instacart"

    // MARK: - UserDefaults (works on simulator)

    static func saveToDefaults(key: String, value: String) -> Bool {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return false }
        defaults.set(value, forKey: key)
        return defaults.synchronize()
    }

    static func readFromDefaults(key: String) -> String? {
        UserDefaults(suiteName: suiteName)?.string(forKey: key)
    }

    // MARK: - Keychain with App Group (works on device with provisioning)

    static func saveToKeychain(key: String, value: String) -> (success: Bool, status: OSStatus) {
        guard let data = value.data(using: .utf8) else { return (false, -1) }

        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.instacart.appclip.auth",
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: suiteName
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.instacart.appclip.auth",
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: suiteName,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return (status == errSecSuccess, status)
    }

    static func readFromKeychain(key: String) -> (value: String?, status: OSStatus) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.instacart.appclip.auth",
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: suiteName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        let value = (result as? Data).flatMap { String(data: $0, encoding: .utf8) }
        return (value, status)
    }
}
