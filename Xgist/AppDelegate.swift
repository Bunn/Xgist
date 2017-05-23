//
//  AppDelegate.swift
//  Xgist
//
//  Created by Fernando Bunn on 10/12/16.
//  Copyright © 2016 Fernando Bunn. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    private var statusWindowController: BezelMessageWindowController!
    
    private var didOpenURL = false
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        
        NSAppleEventManager.shared().setEventHandler(self,
                                                     andSelector: #selector(handleURLEvent(_:replyEvent:)),
                                                     forEventClass: UInt32(kInternetEventClass),
                                                     andEventID: UInt32(kAEGetURL))
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.didOpenURL {
                // Application was launched normally, just show
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func handleURLEvent(_ event: NSAppleEventDescriptor!, replyEvent: NSAppleEventDescriptor!) {
        guard let urlString = event.paramDescriptor(forKeyword: UInt32(keyDirectObject))?.stringValue else { return }
        guard let url = URL(string: urlString) else { return }
        guard let message = BezelMessage(url: url) else { return }
        
        didOpenURL = true
        
        showBezelMessage(message)
    }
    
    private func showBezelMessage(_ message: BezelMessage) {
        statusWindowController = BezelMessageWindowController(status: message)
        
        statusWindowController.show(for: 3.0) {
            NSApp.terminate(nil)
        }
    }
    
    @objc private func killAgent() {
        NSApp.terminate(nil)
    }
    
}

