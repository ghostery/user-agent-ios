/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Storage
import NaturalLanguage

protocol DocumentAnalyser {
    var name: String { get }
    associatedtype NewMetadata
    func analyse(metadata: PageMetadata) -> NewMetadata?
}

struct LanguageDetector: DocumentAnalyser {
    let name = "language" // This key matches the DerivedMetadata property
    typealias NewMetadata = String // This matches the value for the DerivedMetadata key above

    func analyse(metadata: PageMetadata) -> LanguageDetector.NewMetadata? {
        if let metadataLanguage = metadata.language {
            return metadataLanguage
        }
        // Lets not use any language detection until we can pass more text to the language detector
        return nil // https://bugzilla.mozilla.org/show_bug.cgi?id=1519503
        /*
        guard let text = metadata.description else { return nil }
        let language: String?
        if #available(iOS 12.0, *) {
            language = NLLanguageRecognizer.dominantLanguage(for: text)?.rawValue
        } else {
            language = NSLinguisticTagger.dominantLanguage(for: text)
        }
        return language
        */
    }
}

struct DerivedMetadata: Codable {
    let language: String?

    // New keys need to be mapped in this constructor
    static func from(dict: [String: Any?]) -> DerivedMetadata? {
        return DerivedMetadata(language: dict["language"] as? String)
    }
}
