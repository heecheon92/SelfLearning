//
//  ContentView.swift
//  NavigationStack
//
//  Created by Heecheon Park on 9/16/22.
//

import SwiftUI

struct CustomNavigationPath {
    var elements: [AnyHashable]
    
    public var count: Int { elements.count }
    public var isEmpty: Bool { elements.isEmpty }
    
    public init(_ elements: [AnyHashable] = []) {
        self.elements = elements
    }
    
    public init<S: Sequence>(_ elements: S) where S.Element: Hashable {
        self.init(elements.map(AnyHashable.init))
    }
    
    public mutating func append<V: Hashable>(_ value: V) {
        elements.append(value)
    }
    
    public mutating func removeLast(_ k: Int = 1) {
        elements.removeLast(k)
    }
    
    public mutating func removeAll() {
        elements.removeAll()
    }
}

@MainActor final class Navigator: ObservableObject {
    
//    @Published var navigationPath: [UUID] = []
    @Published var navigationPath = CustomNavigationPath()
    
    private init() {}
    
    static let shared = Navigator()
}

struct ContentView: View {
    
    @StateObject var nav = Navigator.shared
    
    var body: some View {
        NavigationStack(path: $nav.navigationPath.elements) {
            
            CustomNavigationLink(label: {
                
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
                
            }, destination: {
                CustomNavigatedView()
            })
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomNavigationLink<T, U> : View where T: View, U: View {
    
    let label: () -> T
    let destination: () -> U
    
    init(@ViewBuilder label: @escaping () -> T,
         @ViewBuilder destination: @escaping () -> U) {
        self.label = label
        self.destination = destination
    }
    
    @ViewBuilder var body: some View {
        NavigationLink(value: UUID(), label: label)
            .navigationDestination(for: UUID.self, destination: { _ in
                destination()
            })
    }
}

struct CustomNavigatedView: View {
    
    @ObservedObject var nav = Navigator.shared
    
    var body: some View {
        
        Group {
            if (nav.navigationPath.count > 5) {
                Button(action: {
                    withAnimation {
                        nav.navigationPath.removeAll()
                    }
                }, label: {
                    Text("Pop to root")
                })
                .padding(.bottom, 50)
            } else {
                Button(action: {
                    nav.navigationPath.removeLast()
                }, label: {
                    Text("Pop to previous")
                })
                .padding(.bottom, 50)
                
                CustomNavigationLink(label: {
                    Text("Total Navigation Nest: \(nav.navigationPath.count)")
                }, destination: { self })
            }
        }
    }
}
