# App Clip Validation Checklist

## Simulator (automated)
- [x] JS Bridge: `postMessage({token, username})` received by `WKScriptMessageHandler`
- [x] UserDefaults via App Group: App Clip writes, Host app reads
- [ ] Keychain via App Group: returns `-34018` on simulator (expected)

## Device (manual — needs provisioning)
- [ ] Build ICClipTestClip on device, tap "Send Token"
- [ ] Build ICClipTestHost on same device, verify `test-token-123` / `clip-user`
- [ ] Confirm keychain status is `0 (ok)` instead of `-34018`
- [ ] Verify `keychain-access-groups` entitlement is rejected on App Clips
- [ ] Verify `com.apple.security.application-groups` works as `kSecAttrAccessGroup`
