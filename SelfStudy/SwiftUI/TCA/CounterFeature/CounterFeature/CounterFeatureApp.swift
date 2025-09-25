//
//  CounterFeatureApp.swift
//  CounterFeature
//
//  Created by Heecheon Park on 9/25/25.
//

import ComposableArchitecture
import SwiftUI

@main
struct CounterFeatureApp: App {
    
    static let store = Store(initialState: CounterFeature.State(), reducer: { CounterFeature() })
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: Self.store)
        }
    }
}
