//
//  AppDelegate.swift
//  ComputeInstanceStatus
//
//  Created by Jaap Mengers on 19/11/2019.
//  Copyright © 2019 Jaap Mengers. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var statusItem: NSStatusItem!


  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    let menu = NSMenu(title: "Status bar menu")
    menu.addItem(NSMenuItem(title: "Do nothing", action: #selector(doSomething), keyEquivalent: ""))
    
    statusItem.button?.title = "🌯"
    statusItem.button?.target = self
    statusItem.button?.action = #selector(displayMenu)
    statusItem.menu = menu
  }
  
  @objc func displayMenu() {
    
  }
  
  @objc func doSomething() {
    guard
      let youtubedlPath = Bundle.main.path(forResource: "youtube-dl" ,ofType:"command"),
      let ffprobePath = Bundle.main.resourcePath
      else {
        self.log("Unable to locate youtube-dl.command")
        return
    }
    
    print(youtubedlPath)
    
    let downloadTask = Process()
    downloadTask.launchPath = youtubedlPath
    downloadTask.arguments =  arguments + ["--ffmpeg-location", ffprobePath, url]
    
    downloadTask.terminationHandler = {
      task in
      DispatchQueue.main.async(execute: {
        let filesAfterwards = self.getFiles(in: FileManager.default.homeDirectoryForCurrentUser)
        
        let newFiles = Set(filesAfterwards).subtracting(filesBeforeHand)
        
        switch newFiles.count {
        case 0: self.log("Finished downloading, but couldn't find the file in download directory")
        case 1: self.saveDownloadedFile(with: newFiles.first!)
        default: self.log("Found more than one new file in the download directory. Try again")
        }
      })
    }
    
    let outputPipe = Pipe()
    downloadTask.standardOutput = outputPipe
    outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading, queue: nil) { notification in
      
      let output = outputPipe.fileHandleForReading.availableData
      let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
      
      DispatchQueue.main.async(execute: {
        self.log(outputString)
      })
      
      outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
    downloadTask.launch()
    
    downloadTask.waitUntilExit()
  }

  
}

