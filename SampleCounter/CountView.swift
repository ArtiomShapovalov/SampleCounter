//
//  CountView.swift
//  SampleCounter
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import SwiftUI

struct CountView: View {
  let title: String
  let value: Int
  
  var body: some View {
    VStack {
      Text(title)
      Text("\(value)")
        .font(.system(size: 48))
        .frame(width: 350)
    }
    .padding()
  }
}
