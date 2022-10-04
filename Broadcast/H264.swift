//
//  H264Encoder.swift
//  YTBRH
//
//  Created by Yury Korolev on 21.09.2020.
//

import CoreFoundation
import VideoToolbox
import CoreImage

//protocol VideoEncoderDelegate: class {
//  func didSetFormatDescription(video formatDescription: CMFormatDescription?, dts: CMTime)
//  func sampleOutput(video sampleBuffer: CMSampleBuffer)
//}

// MARK: -
final class H264Encoder: NSObject {
  
  static let shared = H264Encoder()
  
  static let defaultWidth: Int32 = 480
  static let defaultHeight: Int32 = 272
  static let defaultScalingMode: String = "Trim"
  static let defaultDataRateLimits: [NSNumber] = [0, 0]
  
  @objc var scalingMode: String = H264Encoder.defaultScalingMode {
    didSet {
      guard scalingMode != oldValue else {
        return
      }
      invalidateSession = true
    }
  }
  
  @objc var width: Int32 = H264Encoder.defaultWidth {
    didSet {
      guard width != oldValue else {
        return
      }
      invalidateSession = true
    }
  }
  @objc var height: Int32 = H264Encoder.defaultHeight {
    didSet {
      guard height != oldValue else {
        return
      }
      invalidateSession = true
    }
  }
  
  final var locked: UInt32 = 0
  final var lockQueue = DispatchQueue(label: "app.streamchamp.H264Encoder.lock")
  
  static var sampleOutput: (CMSampleBuffer, CMTime, CMTime) -> () = { _, _, _ in}
  
  private(set) var isRunning: Bool = false
  private(set) var status: OSStatus = noErr
  final private var invalidateSession: Bool = true
  
  // @see: https://developer.apple.com/library/mac/releasenotes/General/APIDiffsMacOSX10_8/VideoToolbox.html
  final private var properties: [NSString: Any] {
    let properties: [NSString: Any] = [
      kVTCompressionPropertyKey_RealTime: kCFBooleanTrue!,
      kVTCompressionPropertyKey_ProfileLevel: kVTProfileLevel_H264_Main_AutoLevel,
      kVTCompressionPropertyKey_AverageBitRate: (3000 * 1024) as CFTypeRef,
      kVTCompressionPropertyKey_ExpectedFrameRate: NSNumber(value: 60),
      kVTCompressionPropertyKey_MaxKeyFrameInterval: 10 as CFTypeRef
    ]
    
    return properties
  }
  
  private let _callback: VTCompressionOutputCallback = {
    ( outputCallbackRefCon: UnsafeMutableRawPointer?,
      sourceFrameRefCon: UnsafeMutableRawPointer?,
      status: OSStatus,
      infoFlags: VTEncodeInfoFlags,
      sampleBuffer: CMSampleBuffer?
    ) in
    guard
      status == noErr,
      !infoFlags.contains(.frameDropped),
      let sampleBuffer = sampleBuffer
    else {
      return
    }
    
    H264Encoder.sampleOutput(sampleBuffer,
                 sampleBuffer.presentationTimeStamp,
                 sampleBuffer.decodeTimeStamp)
  }
  
  private var _session: VTCompressionSession?
  
  private var session: VTCompressionSession? {
    get {
      if _session != nil {
        return _session
      }
      
      let res = VTCompressionSessionCreate(
        allocator: kCFAllocatorDefault,
        width: width,
        height: height,
        codecType: kCMVideoCodecType_H264,
        encoderSpecification: nil,
        imageBufferAttributes: nil,
        compressedDataAllocator: nil,
        outputCallback: _callback,
        refcon: Unmanaged.passUnretained(self).toOpaque(),
        compressionSessionOut: &_session
      )
      
      guard res == noErr else {
        return nil
      }

      invalidateSession = false
      status = VTSessionSetProperties(_session!, propertyDictionary: properties as CFDictionary)
      status = VTCompressionSessionPrepareToEncodeFrames(_session!)

      var dict: CFDictionary? = nil
      VTSessionCopySerializableProperties(_session!, allocator: nil, dictionaryOut: &dict)

      return _session
    }
    
    set {
      if let session: VTCompressionSession = _session {
        VTCompressionSessionInvalidate(session)
      }
      _session = newValue
    }
  }
  
  override init() {
    
  }
  
  deinit {
    if let session: VTCompressionSession = _session {
      VTCompressionSessionInvalidate(session)
      _session = nil
    }
  }
  
  func encodeImageBuffer(_ imageBuffer: CVImageBuffer,
                         pts: CMTime,
                         duration: CMTime) {
    if invalidateSession {
      session = nil
    }
    
    guard
      isRunning && locked == 0,
      let session = session
    else {
      return
    }
    
    VTCompressionSessionEncodeFrame(
      session,
      imageBuffer: imageBuffer,
      presentationTimeStamp: pts,
      duration: duration,
      frameProperties: nil,
      sourceFrameRefcon: nil,
      infoFlagsOut: nil
    )
  }
  
  private func setProperty(_ key: CFString, _ value: CFTypeRef?) {
    lockQueue.async {
      guard
        let session = self._session
      else {
        return
      }
      self.status = VTSessionSetProperty(session, key: key, value: value)
    }
  }
  
  func startRunning() {
    lockQueue.async {
      self.isRunning = true
    }
  }
  
  func stopRunning() {
    lockQueue.async {
      self.session = nil
//      self.formatDescription = nil
      self.isRunning = false
    }
  }
}
