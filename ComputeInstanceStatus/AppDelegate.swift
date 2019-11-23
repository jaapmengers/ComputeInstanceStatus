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
  let menu = NSMenu(title: "Menu")
  let statusMenuItem = NSMenuItem(title: "Status unknown", action: nil, keyEquivalent: "")
  let startMenuItem = NSMenuItem(title: "Start", action: #selector(start), keyEquivalent: "")
  let stopMenuItem = NSMenuItem(title: "Stop", action: #selector(stop), keyEquivalent: "")

  var lastStatus: Status? = nil {
    didSet {
      switch lastStatus {
      case .some(.running):
        statusItem.button?.title = "🌝"
        statusMenuItem.title = "Running"
        startMenuItem.isHidden = true
        stopMenuItem.isHidden = false
      case .some(.staging):
        statusItem.button?.title = "🌜"
        statusMenuItem.title = "Staging"
        startMenuItem.isHidden = true
        stopMenuItem.isHidden = false
      case .some(.stopping):
        statusItem.button?.title = "🌛"
        statusMenuItem.title = "Stopping"
        startMenuItem.isHidden = true
        stopMenuItem.isHidden = true
      case .some(.terminated):
        statusItem.button?.title = "🌚"
        statusMenuItem.title = "Terminated"
        startMenuItem.isHidden = false
        stopMenuItem.isHidden = true
      default:
        statusItem.button?.title = "🌚"
        statusMenuItem.title = "Status unknown"
        startMenuItem.isHidden = true
        stopMenuItem.isHidden = true
      }
    }
  }
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    statusMenuItem.isEnabled = false
    
    startMenuItem.isHidden = true
    stopMenuItem.isHidden = true
    
    menu.addItem(statusMenuItem)
    menu.addItem(NSMenuItem.separator())
    menu.addItem(startMenuItem)
    menu.addItem(stopMenuItem)
    menu.addItem(withTitle: "Preferences", action: #selector(openPreferences), keyEquivalent: "")
    
    statusItem.button?.title = "🌚"
    statusItem.button?.target = self
    statusItem.menu = menu
    
    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
     self?.runCommand(command: "status")
    }
  }
  
  @objc func start() {
    runCommand(command: "start")
  }
  
  @objc func stop(){
    runCommand(command: "stop")
  }
  
  @objc func openPreferences() {
    let vc = PreferencesViewController.instantiate()
    let window = NSWindow(contentViewController: vc)
    window.title = "Preferences"
    window.orderFront(nil)
  }
  
  private func runCommand(command: String) {
    guard let serviceAccountPath = UserDefaultsService.serviceAccountFileBookmark,
      let zone = UserDefaultsService.zone,
      let instanceName = UserDefaultsService.instanceName
      else { return }
    
    GCPService.runCommand(serviceAccountPath.path, zone, instanceName, command)
      .then { [weak self] status in
        self?.lastStatus = status
    }.trap { err in
      print("Error: \(err)")
    }
  }
}

