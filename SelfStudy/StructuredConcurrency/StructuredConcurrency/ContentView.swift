//
//  ContentView.swift
//  StructuredConcurrency
//
//  Created by Heecheon Park on 2023/03/07.
//

import SwiftUI

struct ContentView: View {
    
    @State private var count = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("count: \(count)")
            
            ScrollView {
                LazyVStack(spacing: 20, pinnedViews: .sectionHeaders) {
                    SyncTaskSection()
                    
                    PlainTaskSection()
                    
                    MainActorClosureTaskSection()
                }
            }
        }
        .padding()
        .animation(.spring(), value: count)
    }
    
    @ViewBuilder func SyncTaskSection() -> some View {
        Button(action: {
            increment()
            decrement()
        }, label: {
            Text("Run Sync Task")
        })
    }
    
    @ViewBuilder func PlainTaskSection() -> some View {
        
        Section {
            Button(action: {
                Task {
                    await asyncIncrement()
                    await asyncDecrement()
                }
            }, label: {
                Text("Run Async Task")
            })
            
            Button(action: {
                Task {
                    increment()
                    await asyncDecrement()
                    increment()
                    await asyncIncrement()
                    await asyncDecrement()  // <- Put a breakpoint here to check which thread is running the function.
                    decrement()
                    increment()
                    await asyncDecrement()
                    increment()
                    await asyncIncrement()
                    await asyncDecrement()
                    decrement()
                }
            }, label: {
                Text("Run Any Task")
            })
        } header: {
            Text("Plain Task Block")
                .frame(maxWidth:. infinity)
                .frame(height: 50)
                .background(Color.yellow)
        }
    }
    
    @ViewBuilder func MainActorClosureTaskSection() -> some View {
        
        Section {
            Button(action: {
                Task { @MainActor in
                    await asyncIncrement()
                    await asyncDecrement()
                }
            }, label: {
                Text("Run Async MainActor Closure Task")
            })
            
            Button(action: {
                Task { @MainActor in
                    increment()
                    await asyncDecrement()
                    increment()
                    await asyncIncrement()
                    await asyncDecrement()  // <- Put a breakpoint here to check which thread is running the function.
                    decrement()
                    increment()
                    await asyncDecrement()
                    increment()
                    await asyncIncrement()
                    await asyncDecrement()
                    decrement()
                }
            }, label: {
                Text("Run Any MainActor Closure Task")
            })
        } header: {
            Text("MainActor Task Block")
                .frame(maxWidth:. infinity)
                .frame(height: 50)
                .background(Color.yellow)
        }
    }
    
    func printCount() { print("\(count)") }
    func increment() {
        print(format("increment") + "\(Thread.current.description)")
        count += 1
    }
    func decrement() {
        print(format("decrement") + "\(Thread.current.description)")
        count -= 1
    }
    func asyncIncrement() async {
        print(format("asyncIncrement") + "\(Thread.current.description)")
        count += 1
    }
    func asyncDecrement() async {
        print(format("asyncDecrement") + "\(Thread.current.description)")
        count -= 1
    }
    
    func format(_ arg: String) -> String {
        var res = arg
        while res.count < 15 { res = res + " " }
        return res
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
