//
//  ContentView.swift
//  PreferenceKey
//
//  Created by Heecheon Park on 1/20/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var rootViewText = "rootViewText"
    @State private var anyView: AnyView? = nil
    
    var body: some View {
        VStack {
            if let anyView {
                anyView
                Spacer()
            }
            
            Text(rootViewText)
            SomeNestedView {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
            }
        }
        .padding()
        .onPreferenceChange(SomePreferenceKey.self) { pref in
            rootViewText = rootViewText + " \(pref)"
        }
        .onPreferenceChange(ViewPreferenceKey.self) { pref in
            if rootViewText.count > 20 {
                anyView = pref
            }
        }
    }
}

struct SomeNestedView<Content: View>: View {
    
    let nestedContent: () -> Content
    
    @State private var nestedViewText = ""
    @State private var val = 1
    
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.nestedContent = content
    }
    
    var body: some View {
        VStack {
            
            nestedContent()
            
            Button(action: {
                val += 1
            }, label: {
                Text("Increment")
            })
            
            Text("\(val)")
                .preference(key: SomePreferenceKey.self, value: "\(val)")
                .preference(key: ViewPreferenceKey.self, value: AnyView(
                    Text("Some random Text")
                ))
        }
    }
}

struct SomePreferenceKey: PreferenceKey {
    typealias Value = String
    
    static var defaultValue: Value = ""
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

struct ViewPreferenceKey: PreferenceKey {
    static var defaultValue: AnyView = AnyView(EmptyView())
    static func reduce(value: inout AnyView, nextValue: () -> AnyView) {
        value = nextValue()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension AnyView: Equatable {
    var id: UUID { UUID() }
    public static func ==(lhs: AnyView, rhs: AnyView) -> Bool {
        return lhs.id == rhs.id
    }
}
