//
//  GCPService.swift
//  ComputeInstanceStatus
//
//  Created by Jaap Mengers on 23/11/2019.
//  Copyright © 2019 Jaap Mengers. All rights reserved.
//

import Foundation
import Promissum

class GCPService {
  
  static func runCommand(_ serviceAccountPath: String, _ zone: String, _ instanceName: String, _ command: String = "status") -> Promise<Status, Error> {
    guard
      let cliPath = Bundle.main.path(forResource: "index-macos", ofType: nil)
      else {
        return Promise(error: "CLI not found")
    }
    
    let source = PromiseSource<Status, Error>()
    
    DispatchQueue.global(qos: .background).async {
      let task = Process()
      task.launchPath = cliPath
      task.arguments =  [command, "-z", zone, "-i", instanceName]
      task.environment = ["GOOGLE_APPLICATION_CREDENTIALS": serviceAccountPath]
      
      let pipe = Pipe()
      task.standardOutput = pipe
      task.launch()
      
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
      
      let processed = output.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
      
      let status = Status(rawValue: processed)
      switch status {
      case .some(let status):
        DispatchQueue.main.async {
          source.resolve(status)
        }
      case .none:
        DispatchQueue.main.async {
          source.reject("Invalid state \(processed) returned")
        }
      }
    }
    
    return source.promise
  }
}
