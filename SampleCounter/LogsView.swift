//
//  LogsView.swift
//  SampleCounter
//
//  Created by Artem Shapovalov on 20.04.2022.
//  Copyright © 2022 Anjlab. All rights reserved.
//

import SwiftUI

struct LogsView: View {
  
  @ObservedObject private var _model = SmplCountModel.shared
  var hide: () -> () = {}
  
  private var _logs: String {
    if _model.logs.isEmpty {
      return "No logs"
    }
    
    return _model.logs
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading) {
          HStack { Spacer() }
          Text(_logs)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal)
      }
      .navigationTitle("Resolution Logs")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItemGroup(placement: .navigation) {
          Button("Done") { hide() }
          
        }
      }
      .toolbar {
        Button("Clear") { ud.set("", forKey: "logs") }
      }
    }
  }
}
