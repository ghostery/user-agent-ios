//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React
import CryptoKit

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

private protocol KeyStoreProtocol {
    func create() -> Int
    func getKey(_ id: Int) -> Data?
}

private class KeyStoreStub: KeyStoreProtocol {
    func create() -> Int { return 0 }
    func getKey(_ id: Int) -> Data? { return nil }
}

@available(iOS 13.0, *)
private class KeyStore: KeyStoreProtocol {
    private var privateKeys: [P256.KeyAgreement.PrivateKey] = []
    private var publicKeys: [P256.KeyAgreement.PublicKey] = []

    func create() -> Int {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey

        self.privateKeys.append(privateKey)
        self.publicKeys.append(publicKey)

        return self.publicKeys.count - 1
    }

    func getKey(_ id: Int) -> Data? {
        if id >= self.publicKeys.count {
            return nil
        }
        let key = self.publicKeys[id]
        return key.rawRepresentation
    }
}

@objc(WindowCrypto)
class WindowCrypto: NSObject {
    private lazy var keyStore: KeyStoreProtocol = {
        if #available(iOS 13.0, *) {
            return KeyStore()
        } else {
            return KeyStoreStub()
        }
    }()

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

        let id = self.keyStore.create()
        resolve(id)
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

        if let key = self.keyStore.getKey(id as Int) {
            resolve(key.toHexString())
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
