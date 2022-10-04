//
//  FileManager.swift
//  SampleCounter
//
//  Created by Artem Shapovalov on 21.09.2022.
//  Copyright © 2022 Anjlab. All rights reserved.
//

import Foundation

extension FileManager {
  
  var testFileName: String {
    "test_writing_\(UserDefaults.suite.writingIndex + 1).h264"
  }
  
  var testFileCopyName: String {
    "test_writing_\(UserDefaults.suite.writingIndex).h264"
  }
  
  var containerURL: URL? {
    containerURL(
      forSecurityApplicationGroupIdentifier: "group.anjlab.SampleCounter"
    )
  }
  
  func loadAll() -> [String] {
    
    guard let containerURL = containerURL else {
      return []
    }
    
    var items: [URL] = []
    
    do {
      items = try contentsOfDirectory(
        at: containerURL,
        includingPropertiesForKeys: nil,
        options: .includesDirectoriesPostOrder
      )
    } catch {
      debugPrint("Cant get urls. \(error)")
    }
    
    return items.map { $0.lastPathComponent }
  }
}
