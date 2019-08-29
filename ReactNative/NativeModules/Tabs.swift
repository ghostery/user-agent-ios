//
//  Tabs.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 28.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//
import React
import Storage

@objc(Tabs)
class Tabs: NSObject {
    @objc(open:)
    func open(url: NSString) {
        DispatchQueue.main.async {
            guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            if let url = URL(string: url as String) {
                appDel.browserViewController.homePanel(didSelectURL: url, visitType: VisitType.bookmark)
            }
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
