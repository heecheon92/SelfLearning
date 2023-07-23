//
//  ContentView.swift
//  AnchorPreference
//
//  Created by Heecheon Park on 7/23/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var prepItems: [RectItem] = [
        RectItem(color: .red),
        RectItem(color: .blue),
        RectItem(color: .yellow),
        RectItem(color: .green)
    ]
    @State private var selectedItem: RectItem? = nil
    
    var body: some View {
        VStack {
            ForEach(Array(zip(prepItems.indices, prepItems)), id: \.0) { idx, item in
                Button(action: {
                    selectedItem = item
                }, label: {
                    item.color
                        .frame(width: CGFloat(idx + 1) * 40,
                               height: CGFloat(idx + 1) * 40)
                        .anchorPreference(key: BoundPreferenceKey.self,
                                          value: .bounds) { anchor in
                            return (item.id, anchor)
                        }
                })
            }
        }
        .padding()
        .border(.blue)
        .background(
            GeometryReader { gp in
                Color.clear.onAppear { printGP(gp) }
            }
        )
        .overlayPreferenceValue(BoundPreferenceKey.self) { pref in
            GeometryReader { geometry in
                if let pref,
                   let selectedItem,
                   let anchor = BoundPreferenceKey.storage[selectedItem.id]{
                    Rectangle()
                        .stroke(lineWidth: 5)
                        .animation(.spring(), value: anchor)
                        .frame(
                            width: geometry[anchor].width,
                            height: geometry[anchor].height
                        )
                        .offset(
                            x: geometry[anchor].minX,
                            y: geometry[anchor].minY
                        )
                        .onChange(of: selectedItem) { [anchor] _ in
                            print("geometry w: \(geometry[anchor].width) h: \(geometry[anchor].height)")
                        }
                } else {
                    EmptyView()
                }
            }
        }
        .onAppear(perform: printScreenFrame)
    }
    
    func printScreenFrame() {
        print("w: \(UIScreen.main.bounds.width) h: \(UIScreen.main.bounds.height)")
    }
    
    func printGP(_ gp: GeometryProxy) {
        print("outer gp local w: \(gp.frame(in: .local).width) h: \(gp.frame(in: .local).height) minX: \(gp.frame(in: .local).minX) minY: \(gp.frame(in: .local).minY)")
        
        print("outer gp global w: \(gp.frame(in: .global).width) h: \(gp.frame(in: .global).height) minX: \(gp.frame(in: .global).minX) minY: \(gp.frame(in: .global).minY)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BoundPreferenceKey: PreferenceKey {
    static var storage: [UUID:Anchor<CGRect>] = [:]
    static var defaultValue: (UUID, Anchor<CGRect>)? = nil
    static func reduce(value: inout (UUID, Anchor<CGRect>)?, nextValue: () -> (UUID, Anchor<CGRect>)?) {
        if let nextValue = nextValue() {
            storage.updateValue(nextValue.1, forKey: nextValue.0)
            value = nextValue
        }
    }
}

struct RectItem: Identifiable, Equatable {
    let id = UUID()
    let color: Color
}
