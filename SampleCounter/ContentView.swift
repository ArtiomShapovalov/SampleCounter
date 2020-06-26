//
//  ContentView.swift
//  SampleCounter
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import SwiftUI
import Combine

final class SmplCountModel: ObservableObject {
  @Published var videoSmplCount: Int = 0
  @Published var audioAppSmplCount: Int = 0
  @Published var audioMicSmplCount: Int = 0
  
  private let _ud = UserDefaults(suiteName: "group.anjlab.SampleCounter")!
  private var _bag = Array<AnyCancellable>()
  
  init() {
    
    _bag = [
      (\UserDefaults.videoSmplCount,    \SmplCountModel.videoSmplCount),
      (\UserDefaults.audioAppSmplCount, \SmplCountModel.audioAppSmplCount),
      (\UserDefaults.audioMicSmplCount, \SmplCountModel.audioMicSmplCount)
    ]
    .map { from, to in
      _ud
        .publisher(for: from, options: .new)
        .assign(to: to, on: self)
    }
  }
}

struct ContentView: View {
  @ObservedObject private var _model = SmplCountModel()
  
  var body: some View {
    VStack {
      Text("Sample Types").font(.title).padding()
      
      Spacer()
      
      CountView(title: "Video",     value: _model.videoSmplCount)
      CountView(title: "App Audio", value: _model.audioAppSmplCount)
      CountView(title: "Mic Audio", value: _model.audioMicSmplCount)
    
      Spacer()
      
      BroadcastButton().frame(width: 50, height: 50).padding()
    }
  }
}
