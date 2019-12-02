//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

typealias AutomaticForgetModeCheck = (Bool) -> Void

class AutomaticForgetModeDetector {

    private let queue: DispatchQueue
    private var bloomFilter: BloomFilter!

    private var domains = [String]()

    init(queue: DispatchQueue) {
        self.queue = queue
        self.queue.async {
            self.load()
        }
    }

    func shouldBlockURL(_ url: URL, completion:@escaping AutomaticForgetModeCheck) -> Bool {
        guard url.host != "localhost" && url.host != "local" else {
            completion(false)
            return false
        }

        self.queue.async {
            self.scanURL(url, completion: completion)
        }

        return false
    }

    // MARK: - Private methods

    private func load() {
        guard self.domains.isEmpty else {
            return
        }
        self.bloomFilter = BloomFilter()
    }

    private func scanURL(_ url: URL, completion:@escaping (Bool) -> Void) {
        guard let domain = url.baseDomain, !self.domains.contains(domain), self.bloomFilter != nil else {
            completion(true)
            return
        }
        self.queue.async {
            completion(self.bloomFilter.query(domain))
        }
    }

}

extension UInt8 {
    var toBool: Bool {
        return self == 0x01 ? true : false
    }
}

class BloomFilter {

    private var array: [UInt8]
    private var nHashes: Int = 2
    private var m: Int = 0

    private let bitsPerBucket = 32

    init() {
        self.array = [UInt8]()
        self.load()
    }

    func query(_ value: String) -> Bool {
        let (a, b) = self.ab(value: value)
        let indexes = self.indexes(a: a, b: b)
        for bitIndex in indexes {
            let bucketIndex = bitIndex / self.bitsPerBucket
            let bucketBitIndex = 1 << (bitIndex % self.bitsPerBucket)
            if Int(self.array[bucketIndex]) & bucketBitIndex == 0 {
                return false
            }
        }
        return true
    }

    private func indexes(a: Int, b: Int) -> [Int] {
        var x = a % self.m
        var indexes = [Int]()
        for _ in 0..<self.nHashes {
            if x < 0 {
                indexes.append(x + self.m)
            } else {
                indexes.append(x)
            }
            x = (x + b) % self.m
        }
        return indexes
    }

    // MARK: - Private methods

    private func toHex(input: String) -> String {
        let bytes: [UInt8] = Array(input.utf8)
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        CC_MD5_Init(context)
        CC_MD5_Update(context, bytes, CC_LONG(bytes.count))
        let hashLength = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: hashLength)
        CC_MD5_Final(&digest, context)
        print(digest)
        var result = ""
        for i in digest {
            let a = String(format: "%02X", i)
            let b = a.suffix(from: a.index(a.endIndex, offsetBy: -2))
            result += b
        }
        return result.lowercased()
    }

    private func ab(value: String) -> (Int, Int) {
        let result = MD5(value)
//        let result = self.toHex(input: value)
        let firstIndex = result.index(result.startIndex, offsetBy: 8)
        let secondIndex = result.index(firstIndex, offsetBy: 8)
        let md5Prefix = result[..<firstIndex]
        let md5Suffix = result[firstIndex..<secondIndex]
        guard let prefixInt = Int(md5Prefix, radix: 16), let suffixInt = Int(md5Suffix, radix: 16) else {
            return (0, 0)
        }
        return (prefixInt, suffixInt)
    }

    private func load() {
        guard let filePath = Bundle.main.path(forResource: "adult-domains", ofType: "bin"),
            let inputStream = InputStream(fileAtPath: filePath) else {
            return
        }
        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        inputStream.open()
        inputStream.read(buffer, maxLength: 7)
        inputStream.read(buffer, maxLength: 1)
        self.nHashes = Int(buffer.pointee)
        while inputStream.hasBytesAvailable {
            let read = inputStream.read(buffer, maxLength: bufferSize)
            data.append(buffer, count: read)
        }
        buffer.deallocate()
        inputStream.close()
        self.array = data.getBytes()
        self.m = self.array.count * self.bitsPerBucket
    }

}
