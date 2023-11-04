//
//  GlobalAlertApp.swift
//  GlobalAlert
//
//  Created by Heecheon Park on 10/8/23.
//

import SwiftUI

@main
struct GlobalAlertApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
