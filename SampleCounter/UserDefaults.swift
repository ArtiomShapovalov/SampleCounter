//
//  UserDefaults.swift
//  SampleCounter
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import Foundation

extension UserDefaults {
  @objc dynamic var videoSmplCount: Int {
    integer(forKey: "videoSmplCount")
  }
  
  @objc dynamic var audioAppSmplCount: Int {
    integer(forKey: "audioAppSmplCount")
  }
  
  @objc dynamic var audioMicSmplCount: Int {
    integer(forKey: "audioMicSmplCount")
  }
}
