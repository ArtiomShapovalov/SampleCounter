//
//  SampleHandler.swift
//  Broadcast
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {
  final private let _ud = UserDefaults(suiteName: "group.anjlab.SampleCounter")!
  
  final private var _counter = 0
  final private var _videoSmplCount = 0
  final private var _audioAppSmplCount = 0
  final private var _audioMicSmplCount = 0
  
  override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
    _counter += 1
    
    if _counter % 10 == 0 {
      _ud.set(_videoSmplCount,    forKey: "videoSmplCount")
      _ud.set(_audioAppSmplCount, forKey: "audioAppSmplCount")
      _ud.set(_audioMicSmplCount, forKey: "audioMicSmplCount")
    }
    
    switch sampleBufferType {
    case .video:    _videoSmplCount += 1
    case .audioApp: _audioAppSmplCount += 1
    case .audioMic: _audioMicSmplCount += 1
    @unknown default:
      fatalError("Unknown type of sample buffer")
    }
  }
}
