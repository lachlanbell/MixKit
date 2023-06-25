//
//  AppDelegate.swift
//  MixKitDemoApp
//
//  Created by Lachlan Bell on 21/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.appearance = NSAppearance(named: .darkAqua)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

