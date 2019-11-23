//
//  PreferencesViewController.swift
//  ComputeInstanceStatus
//
//  Created by Jaap Mengers on 23/11/2019.
//  Copyright © 2019 Jaap Mengers. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController, NSTextFieldDelegate {

  var serviceAccountFileBookmark: URL? = nil {
    didSet {
      serviceAccountTextField.stringValue = serviceAccountFileBookmark?.path ?? ""
      
      apply()
    }
  }
  
  var zone: String? = nil {
    didSet {
      zoneTextField.stringValue = zone ?? ""
      apply()
    }
  }
  
  var instanceName: String? = nil {
    didSet {
      instanceNameTextField.stringValue = instanceName ?? ""
      apply()
    }
  }
  
  @IBOutlet weak var serviceAccountTextField: NSTextField!
  @IBOutlet weak var zoneTextField: NSTextField!
  @IBOutlet weak var instanceNameTextField: NSTextField!
  @IBOutlet weak var testConnectionButton: NSButton!
  @IBOutlet weak var imageView: NSImageView!
  
  @IBOutlet weak var progressIndicator: NSProgressIndicator!
  
  @IBAction func didTouchSelectFile(_ sender: Any) {
    let dialog = NSOpenPanel();
    
    dialog.title = "Select a Service Account file";
    dialog.showsResizeIndicator = true;
    dialog.allowedFileTypes = ["json"];
    
    let response = dialog.runModal()
    guard
      response == NSApplication.ModalResponse.OK,
      let url = dialog.url
    else {
      return
    }
    
    do {
      self.serviceAccountFileBookmark = url
    } catch {
      print("Don't handle this for now")
    }
  }
  
  @IBAction func didTouchTestConnection(_ sender: Any) {
    var isStale = false
    guard
      let serviceAccountFileBookmark = serviceAccountFileBookmark,
      let zone = zone,
      let instanceName = instanceName
    else { return }
    
    self.imageView.isHidden = true
    progressIndicator.startAnimation(nil)
    
    GCPService.getInstanceState(serviceAccountFileBookmark.path, zone, instanceName)
      .then { [weak self] state in
        self?.imageView.isHidden = false
        self?.imageView.image = NSImage(named: "NSStatusAvailable")
      }
      .trap { [weak self] _ in
        self?.imageView.isHidden = false
        self?.imageView.image = NSImage(named: "NSCaution")
      }
      .finally { [weak self] in
        self?.progressIndicator.stopAnimation(nil)
      }
  }
  
  @IBAction func didSave(_ sender: Any) {
    UserDefaultsService.serviceAccountFileBookmark = serviceAccountFileBookmark
    UserDefaultsService.zone = zone
    UserDefaultsService.instanceName = instanceName
    
    self.view.window?.orderOut(nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    zoneTextField.delegate = self
    instanceNameTextField.delegate = self
    
    serviceAccountFileBookmark = UserDefaultsService.serviceAccountFileBookmark
    zone = UserDefaultsService.zone
    instanceName = UserDefaultsService.instanceName
  }
  
  func apply() {
    let allFieldsValid = serviceAccountFileBookmark != nil && !(zone?.isEmpty ?? true) && !(instanceName?.isEmpty ?? true)
    testConnectionButton.isEnabled = allFieldsValid
  }
  
  func controlTextDidChange(_ obj: Notification) {
    guard let view = obj.object as? NSTextField else { return }
    
    if(view == zoneTextField) {
      self.zone = zoneTextField.stringValue
    } else if (view == instanceNameTextField) {
      self.instanceName = instanceNameTextField.stringValue
    }
  }
}

extension PreferencesViewController {
  static func instantiate() -> PreferencesViewController {
    return PreferencesViewController.init(nibName: "PreferencesViewController", bundle: nil)
  }
}
