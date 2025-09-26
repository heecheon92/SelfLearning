//
//  AppFeatureTests.swift
//  CounterFeature
//
//  Created by Heecheon Park on 9/26/25.
//

import ComposableArchitecture
import Testing

@testable import CounterFeature

@MainActor struct AppFeatureTests {
    @Test
    func incrementInFirstTab() async throws {
        let store = TestStore(
            initialState: AppFeature.State(),
            reducer: {
                AppFeature()
            })
        await store.send(\.tab1.incrementButtonTapped) {
            $0.tab1.count = 1
        }
    }
}
