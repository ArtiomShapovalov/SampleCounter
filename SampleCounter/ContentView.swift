//
//  ContentView.swift
//  SampleCounter
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import SwiftUI
import Combine

let ud = UserDefaults(suiteName: "group.anjlab.SampleCounter")!

final class SmplCountModel: ObservableObject {
  static var shared = SmplCountModel()
  @Published var videoSmplCount:    Int = 0
  @Published var audioAppSmplCount: Int = 0
  @Published var audioMicSmplCount: Int = 0
  @Published var logs: String
  
  private var _bag = Array<AnyCancellable>()
  
  init() {
    logs = ud.logs
    
    _bag = [
      (\UserDefaults.videoSmplCount,    \SmplCountModel.videoSmplCount),
      (\UserDefaults.audioAppSmplCount, \SmplCountModel.audioAppSmplCount),
      (\UserDefaults.audioMicSmplCount, \SmplCountModel.audioMicSmplCount)
    ]
    .map { from, to in
      ud
        .publisher(for: from, options: .new)
        .assign(to: to, on: self)
    }
    
    let ac = ud
      .publisher(for: \UserDefaults.logs, options: .new)
      .assign(to: \SmplCountModel.logs, on: self)
    
    _bag.append(ac)
  }
}

struct ContentView: View {
  @ObservedObject private var _model = SmplCountModel.shared
  @State private var _sheetType: SheetType? = nil
  
  enum SheetType: Int, Identifiable {
    var id: Int { rawValue }
    
    case logs
  }
  
  var body: some View {
    NavigationView {
      VStack {
        Spacer()
        
        CountView(title: "Video",     value: "\(_model.videoSmplCount)")
        CountView(title: "App Audio", value: "\(_model.audioAppSmplCount)")
        CountView(title: "Mic Audio", value: "\(_model.audioMicSmplCount)")
      
        Spacer()
        
        BroadcastButton().frame(width: 50, height: 50).padding()
      }
      .sheet(item: $_sheetType) {
        switch $0 {
        case .logs: LogsView() { _sheetType = nil }
        }
      }
      .navigationTitle("Sample Types")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Logs") {
            _sheetType = .logs
          }
        }
      }
    }
    .navigationViewStyle(.stack)
  }
}
