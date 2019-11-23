//
//  AppDelegate.swift
//  ComputeInstanceStatus
//
//  Created by Jaap Mengers on 19/11/2019.
//  Copyright © 2019 Jaap Mengers. All rights reserved.
//

import Cocoa

enum Status: String {
  case staging
  case running
  case stopping
  case terminated
}

extension String: Error { }

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var statusItem: NSStatusItem!
  let popover = NSPopover()

  var lastStatus: Status? = nil {
    didSet {
      switch lastStatus {
      case .some(.running):
        statusItem.button?.title = "🌝"
      case .some(.staging):
        statusItem.button?.title = "🌜"
      case .some(.stopping):
        statusItem.button?.title = "🌛"
      default:
        statusItem.button?.title = "🌚"
      }
    }
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    let menu = NSMenu(title: "Menu")
    menu.addItem(withTitle: "Preferences", action: #selector(openPreferences), keyEquivalent: "")
    
    statusItem.button?.title = "🌚"
    statusItem.button?.target = self
    statusItem.menu = menu
    
//    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
//      GCPService.getInstanceState().then { [weak self] status in
//        self?.lastStatus = status
//      }.trap { err in
//        print("Error: \(err)")
//      }
//    }
  }
  
  
  @objc func openPreferences() {
    let vc = PreferencesViewController.instantiate()
    let window = NSWindow(contentViewController: vc)
    window.title = "Preferences"
    window.orderFront(nil)
  }
}

