//
//  ContentView.swift
//  SampleCounter
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import SwiftUI
import Combine
import AVKit

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
  @State private var _videoURL: URL? = nil
  
  enum SheetType: Int, Identifiable {
    var id: Int { rawValue }
    
    case logs
  }
  
  var body: some View {
    NavigationView {
      VStack {
        Spacer()
        
        if let url = _videoURL {
          VideoPlayer(player: AVPlayer(url: url)).frame(height: 160)
        }
        
        CountView(title: "Video",     value: "\(_model.videoSmplCount)")
        CountView(title: "App Audio", value: "\(_model.audioAppSmplCount)")
        CountView(title: "Mic Audio", value: "\(_model.audioMicSmplCount)")
      
        Spacer()
        
        BroadcastButton().frame(width: 50, height: 50).padding()
      }
      .onReceive(UserDefaults.suite.publisher(for: \.writingIndex)) { _ in
        debugPrint("TRY COPY FILE TO SANDBOX")
        let fname = FileManager.default.testFileCopyName
        let u = FileManager.default.containerURL?.appending(path: fname)

        let sandbox = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appending(path: fname)
 
        if let s = sandbox {
          try? FileManager.default.removeItem(at: s)
          _copyFile(u, to: s)
        }

        _videoURL = u
      }
      .onAppear {
        debugPrint(FileManager.default.loadAll())
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
  
  private func _copyFile(_ u: URL?, to s: URL, tries: Int = 0) {
//    if tries > 1 {
//      debugPrint("NO LUCK COPYING")
//      return
//    }
    
    do {
      try FileManager.default.copyItem(at: u!, to: s)
    } catch {
      debugPrint(error)
//      FileManager.default.createFile(atPath: s.path, contents: nil)
//      _copyFile(u, to: s, tries: tries + 1)
    }
  }
}
