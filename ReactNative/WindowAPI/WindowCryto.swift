//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React

#if canImport(CryptoKit)
import CryptoKit
#endif

extension Data {
    init?(hexString: String) {
        let length = hexString.count / 2
        var data = Data(capacity: length)
        for i in 0 ..< length {
            let j = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var byte = UInt8(bytes, radix: 16) {
                data.append(&byte, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }

    public func toHexString() -> String {
        return self.compactMap { String(format: "%02x", $0) }.joined()
    }

    public static func generateSecureRandomData(count: Int) -> Data {
        var outData = Data(count: count)

        let result = outData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, count, $0)
        }

        guard result == 0 else {
            fatalError("Failed to randomly generate bytes. SecRandomCopyBytes error code: (\(result)).")
        }

        return outData
    }
}

private class KeyStore {
    private var keys: [Data] = []

    func importKey(_ key: Data) -> Int {
        self.keys.append(key)
        return self.keys.count - 1
    }

    func exportKey(_ id: Int) -> Data? {
        if id >= self.keys.count {
            return nil
        }
        let key = self.keys[id]
        return key
    }
}

private struct Secret {
    var privateKeyId: Int
    var publicKeyId: Int
}

@objc(WindowCrypto)
class WindowCrypto: NSObject {
    private var keyStore = KeyStore()
    private var secretStore: [Int: Secret] = [:]

    @objc(digest:data:resolve:reject:)
    public func digest(
        algorighm: NSString,
        data: NSString,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 13.0, *) else {
            reject("E_crypto", "Crypto operations are not support for iOS older than 13", nil)
            return
        }

        if algorighm == "SHA-256" {
            guard let data = Data(hexString: data as String) else {
                reject("E_data", "Data in wrong format", nil)
                return
            }
            let hash = SHA256.hash(data: data)
            let hexHash = hash.compactMap { String(format: "%02x", $0) }.joined()
            resolve(hexHash)
        } else {
            reject("E_algorithm", "Algorithm is not supported", nil)
        }
    }

    @objc(generateEntropy:resolve:reject:)
    public func generateEntropy(
        count: NSInteger,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        let random = Data.generateSecureRandomData(count: count as Int)
        resolve(random.toHexString())
    }

    @objc(generateKey:reject:)
    public func generateKey(
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 13.0, *) else {
            reject("E_crypto", "Crypto operations are not support for iOS older than 13", nil)
            return
        }
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        let privateKeyId = self.keyStore.importKey(privateKey.rawRepresentation)
        let publicKeyId = self.keyStore.importKey(publicKey.rawRepresentation)

        resolve([
            "privateKeyId": privateKeyId,
            "publicKeyId": publicKeyId,
        ])
    }

    @objc(exportKey:resolve:reject:)
    public func exportKey(
        id: NSInteger,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 13.0, *) else {
            reject("E_crypto", "Crypto operations are not support for iOS older than 13", nil)
            return
        }

        if let key = self.keyStore.exportKey(id as Int) {
            resolve(key.toHexString())
        }
    }

    @objc(importKey:resolve:reject:)
    public func importKey(
        key: NSString,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 13.0, *) else {
            reject("E_crypto", "Crypto operations are not support for iOS older than 13", nil)
            return
        }

        guard let rawKey = Data(hexString: key as String) else {
            reject("E_data", "Data in wrong format", nil)
            return
        }

        let id = self.keyStore.importKey(rawKey)
        resolve(id)
    }

    @objc(deriveKey:publicKey:resolve:reject:)
    public func deriveKey(
        privateKey: NSString,
        publicKey: NSString,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 13.0, *) else {
            reject("E_crypto", "Crypto operations are not support for iOS older than 13", nil)
            return
        }

        guard let rawPrivateKey = Data(hexString: privateKey as String) else {
            reject("E_data", "Data in wrong format", nil)
            return
        }

        guard let rawPublicKey = Data(hexString: publicKey as String) else {
            reject("E_data", "Data in wrong format", nil)
            return
        }

        do {
            let p256PrivateKey = try P256.KeyAgreement.PrivateKey(rawRepresentation: rawPrivateKey)
            let p256PublicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: rawPublicKey)

            let sharedSecret = try p256PrivateKey.sharedSecretFromKeyAgreement(with: p256PublicKey)

            var rawSharedSecret: Data?
            sharedSecret.withUnsafeBytes { bytes in
                rawSharedSecret = Data(bytes)
            }
            guard let sharedKey = rawSharedSecret else {
                reject("E_data", "Data in wrong format", nil)
                return
            }
            let id = self.keyStore.importKey(sharedKey)
            resolve(id)
        } catch {
            reject("E_data", "Data in wrong format", nil)
            return
        }
    }

    @objc(encrypt:iv:data:resolve:reject:)
    public func encrypt(
        keyId: NSInteger,
        iv: NSString,
        data: NSString,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 13.0, *) else {
            reject("E_crypto", "Crypto operations are not support for iOS older than 13", nil)
            return
        }

        guard let sharedSecret = self.keyStore.exportKey(keyId as Int) else {
            reject("E_data", "No such key", nil)
            return
        }

        guard let message = Data(hexString: data as String) else {
            reject("E_data", "Data in wrong format", nil)
            return
        }

        guard let iv = Data(hexString: iv as String) else {
            reject("E_data", "Data in wrong format", nil)
            return
        }

        let symmetricKey = SymmetricKey(data: sharedSecret)
        do {
            let nonce = try AES.GCM.Nonce(data: iv)
            let box = try AES.GCM.seal(message, using: symmetricKey, nonce: nonce)
            resolve(box.ciphertext.toHexString() + box.tag.toHexString())
        } catch {
            reject("E_data", "Data in wrong format", nil)
            return
        }
    }

    @objc(decrypt:iv:tag:data:resolve:reject:)
    public func decrypt(
        keyId: NSInteger,
        iv: NSString,
        tag: NSString,
        data: NSString,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 13.0, *) else {
            reject("E_crypto", "Crypto operations are not support for iOS older than 13", nil)
            return
        }

        guard let sharedSecret = self.keyStore.exportKey(keyId as Int) else {
            reject("E_data", "No such key", nil)
            return
        }

        guard let cipher = Data(hexString: data as String) else {
            reject("E_data", "Data in wrong format", nil)
            return
        }

        guard let iv = Data(hexString: iv as String) else {
            reject("E_data", "Data in wrong format", nil)
            return
        }

        guard let tag = Data(hexString: tag as String) else {
            reject("E_data", "Data in wrong format", nil)
            return
        }

        let symmetricKey = SymmetricKey(data: sharedSecret)
        do {
            let nonce = try AES.GCM.Nonce(data: iv)
            let box: AES.GCM.SealedBox
            do {
                box = try AES.GCM.SealedBox(nonce: nonce, ciphertext: cipher, tag: tag)
            } catch {
                reject("E_data", "Data in wrong format", nil)
                return
            }
            let decryptedData = try AES.GCM.open(box, using: symmetricKey)
            resolve(decryptedData.toHexString())
        } catch {
            reject("E_data", "Data in wrong format", nil)
            return
        }
    }

    @objc
    func constantsToExport() -> [String: Any]! {
        var isAvailable = false
        if #available(iOS 13.0, *) {
            isAvailable = true
        }
        return [
            "isAvailable": isAvailable,
        ]
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
