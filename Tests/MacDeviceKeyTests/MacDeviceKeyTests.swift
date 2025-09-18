import Testing
import Security
import Foundation
@testable import MacDeviceKey

@Test
func testSaveAndLoadKey() async throws {
    let testKey = "com.example.testSaveAndLoadKey"
    let testAccount = "testAccount"
    let testData = "testData123".data(using: .utf8)!
    
    // Ensure key is deleted first
    _ = MacDeviceKeyHelper.deleteKey(key: testKey, account: testAccount, accessGroup: nil)
    
    // Save the key
    let status = MacDeviceKeyHelper.save(key: testKey, account: testAccount, data: testData, accessGroup: nil)
    #expect(status == errSecSuccess)
    
    // Load the key
    let loadedData = MacDeviceKeyHelper.load(key: testKey, account: testAccount, accessGroup: nil)
    #expect(loadedData != nil)
    #expect(loadedData == testData)
    
    // Clean up
    _ = MacDeviceKeyHelper.deleteKey(key: testKey, account: testAccount, accessGroup: nil)
}

@Test
func testDeleteKey() async throws {
    let testKey = "com.example.testDeleteKey"
    let testAccount = "testAccount"
    let testData = "testData123".data(using: .utf8)!
    
    // Ensure key is deleted first
    _ = MacDeviceKeyHelper.deleteKey(key: testKey, account: testAccount, accessGroup: nil)
    
    // Save the key first
    let saveStatus = MacDeviceKeyHelper.save(key: testKey, account: testAccount, data: testData, accessGroup: nil)
    #expect(saveStatus == errSecSuccess)
    
    // Delete the key
    let status = MacDeviceKeyHelper.deleteKey(key: testKey, account: testAccount, accessGroup: nil)
    #expect(status == errSecSuccess)
    
    // Attempt to load the deleted key
    let loadedData = MacDeviceKeyHelper.load(key: testKey, account: testAccount, accessGroup: nil)
    #expect(loadedData == nil)
}

@Test
func testCreateUniqueID() async throws {
    let id1 = MacDeviceKeyHelper.createUniqueID()
    let id2 = MacDeviceKeyHelper.createUniqueID()
    
    #expect(!id1.isEmpty)
    #expect(id1 != id2)
}

@Test
func testOverwriteKey() async throws {
    let testKey = "com.example.testOverwriteKey"
    let testAccount = "testAccount"
    let testData = "testData123".data(using: .utf8)!
    
    // Ensure key is deleted first
    _ = MacDeviceKeyHelper.deleteKey(key: testKey, account: testAccount, accessGroup: nil)
    
    // Save initial key
    let initialStatus = MacDeviceKeyHelper.save(key: testKey, account: testAccount, data: testData, accessGroup: nil)
    #expect(initialStatus == errSecSuccess)
    
    // Save a new value with same key
    let newData = "newTestData".data(using: .utf8)!
    let overwriteStatus = MacDeviceKeyHelper.save(key: testKey, account: testAccount, data: newData, accessGroup: nil)
    #expect(overwriteStatus == errSecSuccess)
    
    // Load and check that data is updated
    let loadedData = MacDeviceKeyHelper.load(key: testKey, account: testAccount, accessGroup: nil)
    #expect(loadedData == newData)
    
    // Clean up
    _ = MacDeviceKeyHelper.deleteKey(key: testKey, account: testAccount, accessGroup: nil)
}

@Test
func testDifferentAccountsSameKey() async throws {
    let testKey = "com.example.testDifferentAccountsSameKey"
    let testAccount1 = "testAccount1"
    let testAccount2 = "testAccount2"
    let testData1 = "testData1".data(using: .utf8)!
    let testData2 = "testData2".data(using: .utf8)!
    
    // Ensure keys are deleted first
    _ = MacDeviceKeyHelper.deleteKey(key: testKey, account: testAccount1, accessGroup: nil)
    _ = MacDeviceKeyHelper.deleteKey(key: testKey, account: testAccount2, accessGroup: nil)
    
    // Save keys with different accounts
    let status1 = MacDeviceKeyHelper.save(key: testKey, account: testAccount1, data: testData1, accessGroup: nil)
    #expect(status1 == errSecSuccess)
    
    let status2 = MacDeviceKeyHelper.save(key: testKey, account: testAccount2, data: testData2, accessGroup: nil)
    #expect(status2 == errSecSuccess)
    
    // Load keys and verify they are different
    let loadedData1 = MacDeviceKeyHelper.load(key: testKey, account: testAccount1, accessGroup: nil)
    let loadedData2 = MacDeviceKeyHelper.load(key: testKey, account: testAccount2, accessGroup: nil)
    
    #expect(loadedData1 == testData1)
    #expect(loadedData2 == testData2)
    #expect(loadedData1 != loadedData2)
    
    // Clean up
    _ = MacDeviceKeyHelper.deleteKey(key: testKey, account: testAccount1, accessGroup: nil)
    _ = MacDeviceKeyHelper.deleteKey(key: testKey, account: testAccount2, accessGroup: nil)
}

