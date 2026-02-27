import XCTest
@testable import ICClipTestHost

/// Tests that validate App Group storage mechanisms work correctly.
/// Layer 1: Unit tests (automated, run in CI or locally).
/// Layer 2: Simulator E2E tests (manual, cross-app validation).
final class AppGroupStorageTests: XCTestCase {

    // MARK: - UserDefaults via App Group

    func testDefaultsWriteAndReadToken() {
        let key = "test_authToken_\(UUID().uuidString)"
        let value = "test-token-123"

        let written = AppGroupStorage.saveToDefaults(key: key, value: value)
        XCTAssertTrue(written, "saveToDefaults should return true")

        let read = AppGroupStorage.readFromDefaults(key: key)
        XCTAssertEqual(read, value, "readFromDefaults should return the written token")

        // Cleanup
        UserDefaults(suiteName: AppGroupStorage.suiteName)?.removeObject(forKey: key)
    }

    func testDefaultsWriteAndReadUsername() {
        let key = "test_username_\(UUID().uuidString)"
        let value = "clip-user"

        let written = AppGroupStorage.saveToDefaults(key: key, value: value)
        XCTAssertTrue(written)

        let read = AppGroupStorage.readFromDefaults(key: key)
        XCTAssertEqual(read, value)

        UserDefaults(suiteName: AppGroupStorage.suiteName)?.removeObject(forKey: key)
    }

    func testDefaultsReadNonexistentKeyReturnsNil() {
        let read = AppGroupStorage.readFromDefaults(key: "nonexistent_key_\(UUID().uuidString)")
        XCTAssertNil(read, "Reading a nonexistent key should return nil")
    }

    func testDefaultsOverwriteExistingValue() {
        let key = "test_overwrite_\(UUID().uuidString)"

        AppGroupStorage.saveToDefaults(key: key, value: "first")
        AppGroupStorage.saveToDefaults(key: key, value: "second")

        let read = AppGroupStorage.readFromDefaults(key: key)
        XCTAssertEqual(read, "second", "Overwriting should store the latest value")

        UserDefaults(suiteName: AppGroupStorage.suiteName)?.removeObject(forKey: key)
    }

    func testDefaultsSharedSuiteIsAccessible() {
        let defaults = UserDefaults(suiteName: AppGroupStorage.suiteName)
        XCTAssertNotNil(defaults, "App Group UserDefaults suite should be accessible")
    }

    // MARK: - Keychain (same-app read/write)

    func testKeychainWriteAndRead() {
        let key = "test_kc_\(UUID().uuidString)"
        let value = "keychain-test-token"

        let writeResult = AppGroupStorage.saveToKeychain(key: key, value: value)

        // On simulator without provisioning, keychain with App Group access group
        // returns -34018. This is expected — the test documents the behavior.
        if writeResult.status == -34018 {
            // Expected on simulator: errSecMissingEntitlement
            // This test PASSES on device with real provisioning.
            print("Keychain write returned -34018 (expected on simulator without provisioning)")
        } else {
            XCTAssertTrue(writeResult.success, "Keychain write should succeed (status: \(writeResult.status))")

            let readResult = AppGroupStorage.readFromKeychain(key: key)
            XCTAssertEqual(readResult.value, value, "Keychain read should return the written value")
        }
    }

    func testKeychainReadNonexistentKey() {
        let result = AppGroupStorage.readFromKeychain(key: "nonexistent_kc_\(UUID().uuidString)")

        // Either -34018 (simulator, no entitlement) or -25300 (item not found)
        XCTAssertNil(result.value, "Reading nonexistent keychain key should return nil")
        XCTAssertTrue(
            result.status == -25300 || result.status == -34018,
            "Status should be errSecItemNotFound (-25300) or errSecMissingEntitlement (-34018), got \(result.status)"
        )
    }

    // MARK: - App Group suite name

    func testSuiteNameIsInstacartAppGroup() {
        XCTAssertEqual(
            AppGroupStorage.suiteName,
            "group.com.instacart",
            "Suite name must match the Instacart App Group"
        )
    }
}
