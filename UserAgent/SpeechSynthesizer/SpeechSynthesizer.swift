//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation

public enum SpeechLanguage: String {
    case de = "de-DE" // German
    case en_us = "en-US" // English(US)
    case en_gb = "en-GB" // English(GB)
    case fr = "fr-CA" // French
    case it = "it-IT" // Italian
    case es = "es-ES" // Spanish
}

protocol SpeechSynthesizerDelegate: class {
    func speechSynthesizerDidStart()
    func speechSynthesizerDidPause()
    func speechSynthesizerDidCancel()
    func speechSynthesizerDidFinish()
    func speechSynthesizerDidContinue()
}

class SpeechSynthesizer: NSObject {
    public var isReading = false

    weak var delegate: SpeechSynthesizerDelegate?

    private let speechSynthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        self.speechSynthesizer.delegate = self
    }

    deinit {
        self.stop()
    }

    func start(text: String, language: SpeechLanguage) {
        if self.speechSynthesizer.isSpeaking {
            self.speechSynthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        utterance.postUtteranceDelay = 0.7
        self.speechSynthesizer.speak(utterance)
    }

    func pause() {
        self.speechSynthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        self.speechSynthesizer.continueSpeaking()
    }

    func stop() {
        self.speechSynthesizer.stopSpeaking(at: .word)
    }

}

extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.delegate?.speechSynthesizerDidStart()
        self.isReading = true
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        self.delegate?.speechSynthesizerDidPause()
        self.isReading = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.delegate?.speechSynthesizerDidCancel()
        self.isReading = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.delegate?.speechSynthesizerDidFinish()
        self.isReading = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        self.delegate?.speechSynthesizerDidContinue()
        self.isReading = true
    }

}
