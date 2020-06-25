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
    let win = UIWindow(frame: UIScreen.main.bounds)
    window = win
    let contentView = ContentView()
    let rootViewController = UIHostingController(rootView: contentView)

    win.rootViewController = rootViewController
    win.makeKeyAndVisible()
    return true
  }
}

