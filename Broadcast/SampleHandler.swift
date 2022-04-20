//
//  SampleHandler.swift
//  Broadcast
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import ReplayKit

let ud = UserDefaults(suiteName: "group.anjlab.SampleCounter")!

class SampleHandler: RPBroadcastSampleHandler {
  final private var _counter = 0
  final private var _videoSmplCount = 0
  final private var _audioAppSmplCount = 0
  final private var _audioMicSmplCount = 0
  final private var _sampleResolution = ud.string(forKey: "res") ?? ""
  
  override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
    _counter += 1
    
    if let buf = sampleBuffer.imageBuffer {
      let w = CVPixelBufferGetWidth(buf)
      let h = CVPixelBufferGetHeight(buf)
      let newRes = "\(w)x\(h)px"
      
      if _sampleResolution != newRes {
        _sampleResolution = newRes
        ud.set(newRes, forKey: "res")
        let logs = ud.logs
        ud.set(logs + "\n[\(Date())] \(newRes)", forKey: "logs")
      }
    }
    
    if _counter % 10 == 0 {
      ud.set(_videoSmplCount,    forKey: "videoSmplCount")
      ud.set(_audioAppSmplCount, forKey: "audioAppSmplCount")
      ud.set(_audioMicSmplCount, forKey: "audioMicSmplCount")
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
