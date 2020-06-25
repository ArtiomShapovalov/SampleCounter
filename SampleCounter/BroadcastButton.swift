//
//  BroadcastButton.swift
//  SampleCounter
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import SwiftUI
import ReplayKit

struct BroadcastButton: UIViewRepresentable {
  func updateUIView(
    _ uiView: RPSystemBroadcastPickerView,
    context: UIViewRepresentableContext<BroadcastButton>) {
  }
  
  func makeUIView(context: Context) -> RPSystemBroadcastPickerView  {
    let size = CGSize(width: 45, height: 45)
    let button = RPSystemBroadcastPickerView(
      frame: CGRect(origin: .zero, size: size)
    )
    
    button.preferredExtension = "com.anjlab.SampleCounter.Broadcast"
    button.backgroundColor = .clear
    (button.subviews[0] as! UIButton).imageView?.tintColor = .label
    
    return button
  }
}
