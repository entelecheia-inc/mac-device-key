# MacDeviceKey

A small Swift library for saving, loading, and deleting arbitrary secret data
in the macOS Keychain (generic password items), with a C-callable interface
so it can be linked into non-Swift binaries.

## API

Swift (`MacDeviceKeyHelper`):

- `save(key:account:data:accessGroup:) -> OSStatus`
- `load(key:account:accessGroup:) -> Data?`
- `deleteKey(key:account:accessGroup:) -> OSStatus`

C ABI (exported via `@_cdecl`):

- `saveKey(keyPtr, accountPtr, dataPtr, dataLength, accessGroupPtr) -> Int32`
- `fetchKey(keyPtr, accountPtr, outBuffer, bufferSize, accessGroupPtr) -> Int32`
- `deleteKey(keyPtr, accountPtr, accessGroupPtr) -> Int32`

Each stored item is identified by `key` + `account` (mapped to the Keychain's
`kSecAttrService` / `kSecAttrAccount`, same naming as Keytar) plus an
optional `accessGroup`. Items are stored
`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` — device-only, never
synced via iCloud Keychain.

## Building

`Package.swift` builds this as a static library (`type: .static`), meant to
be linked into a native addon rather than used as a standalone Swift
dependency — `crosspass-electron` statically links `libMacDeviceKey.a` into
its own Node addon.

### Notes

Package.swift must target the same version of macOS as Electron:

```
    platforms: [
        .macOS(.v10_15)
    ],
```
