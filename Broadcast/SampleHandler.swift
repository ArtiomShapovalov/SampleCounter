//
//  SampleHandler.swift
//  Broadcast
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import ReplayKit

let ud = UserDefaults(suiteName: "group.anjlab.SampleCounter")!

extension ContiguousBytes {
    func objects<T>() -> [T] { withUnsafeBytes { .init($0.bindMemory(to: T.self)) } }
    var uInt8Array: [UInt8] { objects() }
    var int32Array: [Int32] { objects() }
}

fileprivate var NALUHeader: [UInt8] = [0, 0, 0, 1]

class SampleHandler: RPBroadcastSampleHandler {
  final private var _counter = 0
  final private var _videoSmplCount = 0
  final private var _audioAppSmplCount = 0
  final private var _audioMicSmplCount = 0
  final private var _sampleResolution = ud.string(forKey: "res") ?? ""
  final private var _fileHandler: FileHandle? = nil
  final private var _count = 0
  
  override init() {
    let furl = FileManager.default.containerURL?
      .appending(path: FileManager.default.testFileName)
    let oldFURL = FileManager.default.containerURL?
      .appending(path: FileManager.default.testFileCopyName)
    
    try? FileManager.default.removeItem(at: furl!)
    try? FileManager.default.removeItem(at: oldFURL!)
    FileManager.default.createFile(atPath: furl!.relativePath, contents: nil)
    
    debugPrint(FileManager.default.loadAll())
    
    _fileHandler = FileHandle(forWritingAtPath: furl!.relativePath)
    
    debugPrint(_fileHandler)
    
    super.init()
    
    H264Encoder.sampleOutput = { buf, pts, dts in
      let formatDesc = CMSampleBufferGetFormatDescription(buf)
      
//      debugPrint(formatDesc?.frameDuration)
//      debugPrint(formatDesc?.nalUnitHeaderLength)
//      debugPrint(formatDesc?.parameterSets[0].uInt8Array)
//      debugPrint(formatDesc?.parameterSets[1].uInt8Array)
      
      var paramCount: UInt = 0
      var spsSize: UInt = 0
      var ppsSize: UInt = 0
      var sps: UnsafePointer<UInt8>? = nil
      var pps: UnsafePointer<UInt8>? = nil
      var nalUnitHeader: UInt32 = 0
      
      guard let fd = formatDesc else {
        return
      }
      
      CMVideoFormatDescriptionGetH264ParameterSetAtIndex(
        fd,
        parameterSetIndex: 0,
        parameterSetPointerOut: &sps,
        parameterSetSizeOut: &spsSize,
        parameterSetCountOut: &paramCount,
        nalUnitHeaderLengthOut: &nalUnitHeader)
      
      CMVideoFormatDescriptionGetH264ParameterSetAtIndex(
        fd,
        parameterSetIndex: 1,
        parameterSetPointerOut: &pps,
        parameterSetSizeOut: &ppsSize,
        parameterSetCountOut: nil,
        nalUnitHeaderLengthOut: nil)
      
      let spsData: NSData = NSData(bytes: sps, length: Int(spsSize))
      let ppsData: NSData = NSData(bytes: pps, length: Int(ppsSize))
      
      self._writeDataToFile(sps: spsData, pps: ppsData)
      
      guard let dataBuf = CMSampleBufferGetDataBuffer(buf) else {
        return
      }
      
      var bytesLength: UInt = 0
      var dataPointer: UnsafeMutablePointer<Int8>?
      
      CMBlockBufferGetDataPointer(
        dataBuf,
        atOffset: 0,
        lengthAtOffsetOut: nil,
        totalLengthOut: &bytesLength,
        dataPointerOut: &dataPointer)
      
      guard let bytes = dataPointer else {
        return
      }
      
      self._writeFrameToFile(bytes: bytes, len: bytesLength)
      
      self._count += 1
      
      if self._count > 500 {
        H264Encoder.shared.stopRunning()
        ud.set(ud.writingIndex + 1, forKey: "writingIndex")
        debugPrint("STOP WRITING!!!!!!!!!!!!!!!!!!!!!!!")
      }
      
//      let path = FileManager.default.containerURL?.relativePath ?? ""
//
//      let width:  UInt16 = 828
//      let height: UInt16 = 1792
      
//      let pts64 = UInt64(pts.value)
//
//      write_frame_to_file(bytes, bytesLength,
//                          sps, spsSize,
//                          pps, ppsSize,
//                          width, height,
//                          fpath)
      
//      spsVec.withUnsafeBufferPointer { spsP in
//        ppsVec.withUnsafeBufferPointer { ppsP in
//          write_frame_to_file(bytes, bytesLength,
//                              OpaquePointer(spsP.baseAddress),
//                              OpaquePointer(ppsP.baseAddress),
//                              width, height,
//                              fpath)
//        }
//      }
    }
    
    H264Encoder.shared.startRunning()
  }
  
  private func _writeDataToFile(sps: NSData, pps: NSData) {
    guard let fh = _fileHandler else {
      return
    }
    
    let headerData: NSData = NSData(bytes: NALUHeader, length: NALUHeader.count)
    fh.write(headerData as Data)
    fh.write(sps as Data)
    fh.write(headerData as Data)
    fh.write(pps as Data)
  }
  
  private func _writeFrameToFile(bytes: UnsafeMutablePointer<Int8>?, len: UInt) {
    var bufferOffset: Int = 0
    let AVCCHeaderLength = 4
    
    while bufferOffset < (Int(len) - AVCCHeaderLength) {
      var NALUnitLength: UInt32 = 0
      memcpy(&NALUnitLength, bytes?.advanced(by: bufferOffset), AVCCHeaderLength)
      
      NALUnitLength = CFSwapInt32BigToHost(NALUnitLength)
      
      let data: NSData = NSData(
        bytes: bytes?.advanced(by: bufferOffset + AVCCHeaderLength),
        length: Int(NALUnitLength)
      )
      
      guard let fh = _fileHandler else {
        return
      }
      
      let headerData: NSData = NSData(bytes: NALUHeader, length: NALUHeader.count)
      fh.write(headerData as Data)
      fh.write(data as Data)
      
      // move forward to the next NAL Unit
      bufferOffset += Int(AVCCHeaderLength)
      bufferOffset += Int(NALUnitLength)
    }
  }
  
  override func processSampleBuffer(
    _ sampleBuffer: CMSampleBuffer,
    with sampleBufferType: RPSampleBufferType
  ) {
    _counter += 1
    
    if let buf = sampleBuffer.imageBuffer {
      
      let w = CVPixelBufferGetWidth(buf)
      let h = CVPixelBufferGetHeight(buf)
      
      H264Encoder.shared.width  = Int32(w)
      H264Encoder.shared.height = Int32(h)
      
      if case .video = sampleBufferType {
        let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let d = CMSampleBufferGetDuration(sampleBuffer)
        H264Encoder.shared.encodeImageBuffer(buf, pts: pts, duration: d)
      }
      
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
