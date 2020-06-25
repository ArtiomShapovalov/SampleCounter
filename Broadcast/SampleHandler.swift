//
//  SampleHandler.swift
//  Broadcast
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {
  final private let ud = UserDefaults(suiteName: "group.anjlab.SampleCounter")!
  final private var _frameCount = 0
  final private var _videoSmplCount = 0
  final private var _audioAppSmplCount = 0
  final private var _audioMicSmplCount = 0
  
  override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
    _frameCount += 1
    
    if _frameCount % 10 == 0 {
      ud.set(_videoSmplCount, forKey: "videoSmplCount")
      ud.set(_audioAppSmplCount, forKey: "audioAppSmplCount")
      ud.set(_audioMicSmplCount, forKey: "audioMicSmplCount")
      
      _frameCount = 0
    }
    
    switch sampleBufferType {
    case RPSampleBufferType.video:
      _videoSmplCount += 1
      break
    case RPSampleBufferType.audioApp:
      _audioAppSmplCount += 1
      break
    case RPSampleBufferType.audioMic:
      _audioMicSmplCount += 1
      break
    @unknown default:
      fatalError("Unknown type of sample buffer")
    }
  }
  
  override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
    _videoSmplCount = 0
    _audioAppSmplCount = 0
    _audioMicSmplCount = 0
  }
  override func broadcastPaused() {}
  override func broadcastResumed() {}
  override func broadcastFinished() {}
}
