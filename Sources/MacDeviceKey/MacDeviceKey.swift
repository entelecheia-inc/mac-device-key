//
//  MacDeviceKey.swift
//  MacDeviceKey
//
//  Created by Your Name on 2025-09-18.
//

import Foundation
import Security

// MARK: - Core Keychain Helper
public class MacDeviceKeyHelper {
    
    /// Save symmetric key to Keychain (ThisDeviceOnly)
    /// - Parameters:
    ///   - key: Key name (like Keytar service)
    ///   - account: Account name (like Keytar account)
    ///   - data: Key data
    ///   - accessGroup: Optional access group. Pass nil for development to avoid binding.
    public static func save(key: String, account: String, data: Data, accessGroup: String? = nil) -> OSStatus {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        if let group = accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }
        
        // First try to delete any existing item (only by key, account and access group, not data)
        var deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecAttrAccount as String: account
        ]
        
        if let group = accessGroup {
            deleteQuery[kSecAttrAccessGroup as String] = group
        }
        
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Now add the new item
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    /// Load symmetric key from Keychain
    /// - Parameters:
    ///   - key: Key name (like Keytar service)
    ///   - account: Account name (like Keytar account)
    ///   - accessGroup: Optional access group
    public static func load(key: String, account: String, accessGroup: String? = nil) -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let group = accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            return data
        } else {
            return nil
        }
    }
    
    /// Delete symmetric key from Keychain
    /// - Parameters:
    ///   - key: Key name (like Keytar service)
    ///   - account: Account name (like Keytar account)
    ///   - accessGroup: Optional access group
    public static func deleteKey(key: String, account: String, accessGroup: String? = nil) -> OSStatus {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecAttrAccount as String: account
        ]
        
        if let group = accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Return success if item was deleted or if it didn't exist
        if status == errSecSuccess || status == errSecItemNotFound {
            return errSecSuccess
        }
        
        return status
    }
    
    /// Create a unique ID (UUID)
    public static func createUniqueID() -> String {
        return UUID().uuidString
    }
}


@_cdecl("saveKey")
public func saveKey(keyPtr: UnsafePointer<CChar>, accountPtr: UnsafePointer<CChar>, dataPtr: UnsafePointer<CChar>, dataLength: Int, accessGroupPtr: UnsafePointer<CChar>) -> Int32 {
    let key = String(cString: keyPtr)
    let account = String(cString: accountPtr)
    let data = Data(bytes: dataPtr, count: dataLength)
    let accessGroupStr = String(cString: accessGroupPtr)
    // Use nil if empty string, otherwise use the provided access group
    let accessGroup = accessGroupStr.isEmpty ? nil : accessGroupStr
    let status = MacDeviceKeyHelper.save(key: key, account: account, data: data, accessGroup: accessGroup)
    return Int32(status)
}

@_cdecl("fetchKey")
public func fetchKey(keyPtr: UnsafePointer<CChar>, accountPtr: UnsafePointer<CChar>, outBuffer: UnsafeMutablePointer<CChar>, bufferSize: Int, accessGroupPtr: UnsafePointer<CChar>) -> Int32 {
    let key = String(cString: keyPtr)
    let account = String(cString: accountPtr)
    let accessGroupStr = String(cString: accessGroupPtr)
    // Use nil if empty string, otherwise use the provided access group
    let accessGroup = accessGroupStr.isEmpty ? nil : accessGroupStr
    guard let data = MacDeviceKeyHelper.load(key: key, account: account, accessGroup: accessGroup) else {
        return -1
    }
    
    if data.count > bufferSize {
        return -2
    }
    
    data.withUnsafeBytes { bytes in
        outBuffer.initialize(from: bytes.bindMemory(to: CChar.self).baseAddress!, count: data.count)
    }
    return Int32(data.count)
}

@_cdecl("deleteKey")
public func deleteKey(keyPtr: UnsafePointer<CChar>, accountPtr: UnsafePointer<CChar>, accessGroupPtr: UnsafePointer<CChar>) -> Int32 {
    let key = String(cString: keyPtr)
    let account = String(cString: accountPtr)
    let accessGroupStr = String(cString: accessGroupPtr)
    // Use nil if empty string, otherwise use the provided access group
    let accessGroup = accessGroupStr.isEmpty ? nil : accessGroupStr
    let status = MacDeviceKeyHelper.deleteKey(key: key, account: account, accessGroup: accessGroup)
    return Int32(status)
}

