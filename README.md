# MacDeviceKey

A small Swift library for saving, loading, and deleting arbitrary secret
data in the macOS Keychain (generic password items).

## API

Swift (`MacDeviceKeyHelper`):

- `save(key:account:data:accessGroup:) -> OSStatus`
- `load(key:account:accessGroup:) -> Data?`
- `deleteKey(key:account:accessGroup:) -> OSStatus`

Each stored item is identified by `key` + `account` (mapped to the Keychain's
`kSecAttrService` / `kSecAttrAccount`, same naming as Keytar) plus an
optional `accessGroup`. Items are stored
`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` — device-only, never
synced via iCloud Keychain.

`Package.swift` builds this as a static library (`type: .static`), so it can
be linked directly into a Swift app or embedded in another binary.

## C ABI

The same operations are also exported as C-callable functions (via
`@_cdecl`), for consumers outside Swift:

- `saveKey(keyPtr, accountPtr, dataPtr, dataLength, accessGroupPtr) -> Int32`
- `fetchKey(keyPtr, accountPtr, outBuffer, bufferSize, accessGroupPtr) -> Int32`
- `deleteKey(keyPtr, accountPtr, accessGroupPtr) -> Int32`

### Notes

Package.swift targets an older macOS version for broad compatibility with
whatever app embeds this library (e.g. an Electron app):

```
    platforms: [
        .macOS(.v10_15)
    ],
```
