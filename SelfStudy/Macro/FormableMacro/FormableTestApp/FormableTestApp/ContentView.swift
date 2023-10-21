//
//  ContentView.swift
//  FormableTestApp
//
//  Created by Heecheon Park on 10/21/23.
//

import SwiftUI
import Formable

struct ContentView: View {
    
    let (result, code) = #stringify(1000 + 10 + 10)
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
