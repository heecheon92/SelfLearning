//
//  ContentView.swift
//  ChildFunctionAsView
//
//  Created by Heecheon Park on 2023/02/22.
//

import SwiftUI

//MARK: - Note
/// Expected parent view to use child view's viewbuilder function
/// along with state changes.
/// Child view's viewbuilder successfully renders but unable to
/// change state from parent view.

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            SubContentView()
                .IncrementButton()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SubContentView: View {
    @State var count = 0
    
    var body: some View {
        VStack {
            Text("SubContentView")
            IncrementButton()
        }
    }
    
    @ViewBuilder func IncrementButton() -> some View {
        Button {
            count += 1
        } label: {
            Text("Increment: \(count)")
        }
    }
}
