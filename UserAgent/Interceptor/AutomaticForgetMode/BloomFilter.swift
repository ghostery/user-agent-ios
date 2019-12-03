//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class BloomFilter {

    private var filePath: String!
    private var buckets: [Int32] = [Int32]()
    private var nHashes: Int = 2
    private var memory: Int = 0

    private let bitsPerBucket = 32

    init(filePath: String) {
        self.filePath = filePath
        self.load()
    }

    func contains(_ value: String) -> Bool {
        let (prefix, suffix) = self.dividedHex(value: value)
        let indexes = self.indexesFor(prefix: prefix, suffix: suffix)
        for bitIndex in indexes {
            let bucketIndex = bitIndex / self.bitsPerBucket
            let bucketBitIndex = 1 << (bitIndex % self.bitsPerBucket)
            if Int(self.buckets[bucketIndex]) & bucketBitIndex == 0 {
                return false
            }
        }
        return true
    }

    // MARK: - Private methods

    private func dividedHex(value: String) -> (Int, Int) {
        let result = MD5(value)
        let firstIndex = result.index(result.startIndex, offsetBy: 8)
        let secondIndex = result.index(firstIndex, offsetBy: 8)
        let md5Prefix = result[..<firstIndex]
        let md5Suffix = result[firstIndex..<secondIndex]
        guard let prefixInt = Int(md5Prefix, radix: 16), let suffixInt = Int(md5Suffix, radix: 16) else {
            return (0, 0)
        }
        return (prefixInt, suffixInt)
    }

    private func indexesFor(prefix: Int, suffix: Int) -> [Int] {
        var x = prefix % self.memory
        var indexes = [Int]()
        for _ in 0..<self.nHashes {
            indexes.append(x < 0 ? x + self.memory : x)
            x = (x + suffix) % self.memory
        }
        return indexes
    }

    private func load() {
        guard let inputStream = InputStream(fileAtPath: self.filePath) else {
            return
        }
        let data = NSMutableData()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        inputStream.open()
        // Ingnoring first 7 bytes data
        inputStream.read(buffer, maxLength: 7)
        // reading number of hashes
        inputStream.read(buffer, maxLength: 1)
        self.nHashes = Int(buffer.pointee)
        // reading rest data
        while inputStream.hasBytesAvailable {
            let read = inputStream.read(buffer, maxLength: bufferSize)
            data.append(buffer, length: read)
        }
        buffer.deallocate()
        inputStream.close()
        let dataRange = NSRange(location: 0, length: data.count)
        var int32Array = [Int32](repeating: 0, count: data.count / 4)
        data.getBytes(&int32Array, range: dataRange)
        self.buckets = int32Array
        self.memory = self.buckets.count * self.bitsPerBucket
    }

}
