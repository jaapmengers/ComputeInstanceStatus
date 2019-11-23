//
//  UserDefaultService.swift
//  ComputeInstanceStatus
//
//  Created by Jaap Mengers on 23/11/2019.
//  Copyright © 2019 Jaap Mengers. All rights reserved.
//

import Foundation



struct UserDefaultsService {

  static var serviceAccountFileBookmark: URL? {
    get {
      let data = UserDefaults.standard.data(forKey: "serviceAccountFileBookmark")
      var isStale = false
      return data.flatMap { try? URL(resolvingBookmarkData: $0, bookmarkDataIsStale: &isStale) }
    } set {
      let data = try? newValue?.bookmarkData()
      UserDefaults.standard.set(data, forKey: "serviceAccountFileBookmark")
    }
  }
  
  static var zone: String? {
    get {
      UserDefaults.standard.string(forKey: "zone")
    } set {
      UserDefaults.standard.set(newValue, forKey: "zone")
    }
  }
  
  static var instanceName: String? {
    get {
      UserDefaults.standard.string(forKey: "instanceName")
    } set {
      UserDefaults.standard.set(newValue, forKey: "instanceName")
    }
  }
}
