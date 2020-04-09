//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

private struct NewsArticle {
    let domain: String
    let title: String
    let description: String

    var text: String {
        // ":" makes synth to pause for a bit
        return "\(domain): \(title): \(description):"
    }
}

@objc(ReadTheNews)
class ReadTheNews: NSObject {
    private lazy var synth: SpeechSynthesizer = {
        let synth = SpeechSynthesizer()
        synth.delegate = self
        return synth
    }()

    private var news: [NewsArticle] = []
    private var index = 0
    private var language: SpeechLanguage = .en_us
    private var isPaused = false

    @objc(read:language:)
    func read(news: NSArray, language: NSString) {
        guard let news = news as? [[String: Any]] else { return }

        guard let language = SpeechLanguage(rawValue: language as String) else { return }

        if language == self.language {
            if synth.isReading {
                synth.pause()
                self.isPaused = true
                return
            } else if self.isPaused {
                synth.resume()
                self.isPaused = false
                return
            }
        }

        self.language = language
        self.index = 0
        self.isPaused = false
        self.news = news.map { article in NewsArticle(
            domain: article["domain"] as! String,
            title: article["title"] as! String,
            description: article["description"] as! String
        )}

        guard let firstArticle = self.news[safe: 0] else { return }

        self.read(firstArticle)
    }

    @objc(previous)
    func previous() {
        synth.stop()
        self.index -= 1
        if self.index <= 0 {
            self.index = 0
            return
        }
        guard let article = self.news[safe: self.index] else { return }
        self.read(article)
    }

    @objc(next)
    func next() {
        synth.stop()
        self.index += 1
        if self.index > self.news.count - 1 {
            self.index = 0
            return
        }
        guard let article = self.news[safe: self.index] else { return }
        self.read(article)
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }

    private func read(_ article: NewsArticle) {
        self.isPaused = false
        self.synth.start(text: article.text, language: self.language)
    }
}

extension ReadTheNews: SpeechSynthesizerDelegate {
    func speechSynthesizerDidStart() {

    }

    func speechSynthesizerDidPause() {

    }

    func speechSynthesizerDidCancel() {

    }

    func speechSynthesizerDidFinish() {
        self.next()
    }

    func speechSynthesizerDidContinue() {

    }

}
