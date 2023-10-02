//
//  ContentView.swift
//  RowAnimation
//
//  Created by Heecheon Park on 9/10/23.
//

import SwiftUI

struct RowItem: Identifiable {
    let id = UUID()
    var isAppeared = false
    let description: String
}


struct ContentView: View {
    
    @State var rowItems: [RowItem] = [
        .init(description: "Item One"),
        .init(description: "Item Two"),
        .init(description: "Item Three"),
        .init(description: "Item Four"),
        .init(description: "Item Five"),
        .init(description: "Item Six"),
        .init(description: "Item Seven")
    ]
    
    @State var showItems = false
    
    @Namespace var buttonSpace
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if showItems {
                Button(action: {
                    rowItems = rowItems.map { .init(description: $0.description) }
                    withAnimation {
                        showItems.toggle()
                    }
                }, label: { Text("Show / Hide") })
                .matchedGeometryEffect(id: "showHide", in: buttonSpace)
                .padding()
                .animation(.spring(), value: showItems)
                
                ForEach(Array(zip(rowItems.indices, rowItems)), id: \.0) { idx, item in
                    Text(item.description)
                        .padding()
                        .opacity(item.isAppeared ? 1 : 0)
                        .offset(x: item.isAppeared ? 0 : 50)
                        .animation(.spring().delay(0.15 * Double(idx)), value: item.isAppeared)
                        .onAppear {
                            withAnimation {
                                rowItems[idx].isAppeared = true
                            }
                        }
                }
            } else {
                Button(action: {
                    withAnimation {
                        showItems.toggle()
                    }
                }, label: { Text("Show / Hide") })
                .matchedGeometryEffect(id: "showHide", in: buttonSpace)
                .padding()
                .animation(.spring(), value: showItems)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
