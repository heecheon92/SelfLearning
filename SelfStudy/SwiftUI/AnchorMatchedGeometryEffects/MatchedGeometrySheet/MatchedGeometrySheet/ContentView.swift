//
//  ContentView.swift
//  MatchedGeometrySheet
//
//  Created by Heecheon Park on 10/29/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("Some Chat App")
        }
    }
}

#Preview {
    ContentView()
}
