//
//  ContentView.swift
//  SampleCounter
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import SwiftUI
import Combine

var __videoC: AnyCancellable? = nil
var __audioAppC: AnyCancellable? = nil
var __audioMicC: AnyCancellable? = nil

final class SmplCountModel: ObservableObject {
  @Published var videoSmplCount: Int
  @Published var audioAppSmplCount: Int
  @Published var audioMicSmplCount: Int
  
  init() {
    videoSmplCount = 0
    audioAppSmplCount = 0
    audioMicSmplCount = 0
  }
}

struct ContentView: View {
  let ud = UserDefaults(suiteName: "group.anjlab.SampleCounter")!
  @ObservedObject var model = SmplCountModel()
  
  var body: some View {
    VStack {
      Text("Sample Types").font(.title).padding()
      
      Spacer()
      
      VStack {
        CountView(title: "Video", value: model.videoSmplCount)
        
        CountView(title: "App Audio", value: model.audioAppSmplCount)
        
        CountView(title: "Mic Audio", value: model.audioMicSmplCount)
      }
      
      Spacer()
      
      BroadcastButton().frame(width: 50, height: 50).padding()
    }
    .onAppear(perform: _setCancellables)
  }
}

extension ContentView {
  private func _setCancellables() {
    __videoC = ud
      .publisher(for: \.videoSmplCount, options: [.new])
      .receive(on: RunLoop.main)
      .sink {
        self.model.videoSmplCount = $0
        print("Video: ", $0)
      }
    
    __audioAppC = ud
      .publisher(for: \.audioAppSmplCount, options: [.new])
      .receive(on: RunLoop.main)
      .sink {
        self.model.audioAppSmplCount = $0
        print("App audio: ", $0)
      }
    
    __audioMicC = ud
      .publisher(for: \.audioMicSmplCount, options: [.new])
      .receive(on: RunLoop.main)
      .sink {
        self.model.audioMicSmplCount = $0
        print("Mic audio: ", $0)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
