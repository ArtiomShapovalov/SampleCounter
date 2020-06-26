//
//  AppDelegate.swift
//  SampleCounter
//
//  Created by Artiom Shapovalov on 25.06.2020.
//  Copyright © 2020 Anjlab. All rights reserved.
//

import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    
    guard let window = window else {
      return false
    }
    window.rootViewController = UIHostingController(rootView: ContentView())
    window.makeKeyAndVisible()
    
    return true
  }
}

