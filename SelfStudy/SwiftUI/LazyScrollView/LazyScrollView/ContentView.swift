//
//  ContentView.swift
//  LazyScrollView
//
//  Created by Heecheon Park on 8/27/22.
//

import SwiftUI
import Combine

struct OffsetPrefKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        
    }
}

struct SizePrefKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        
    }
}

struct ContentView: View {
    
    let item = Array(0...100)
    
    @State private var currentOffset: CGFloat = .zero
    @State private var rowSize: CGSize = .zero
    @State private var scrollContainerSize: CGSize = .zero
    @State private var scrollContentSize: CGSize = .zero
    
    @State private var visibleRowCount = 0
    @State private var leastVisibleIdx = 0
    @State private var largestVisibleIdx = 0
    
    var body: some View {
        
        VStack(spacing: 0) {
            Rectangle().stroke(Color.green)
                .frame(width: 500, height: 200)

            LazyVerticalScrollView(data: item, initialFetchSize: 20) { elem, idx in

                HStack {
                    AsyncImage(url: URL(string: "https://www.appcoda.com/learnswiftui/images/basic/swiftui-basic-1.jpg")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Color.red
                    }

                    Spacer()

                    Text("\(idx ?? 0)")
                        .font(.largeTitle)
                        .padding(.trailing)
                }
                .frame(height: 100)
            }
        }
    }
}

struct LazyVerticalScrollView<Element, RowContent: View>: View {
    
    @State private var currentOffset: CGFloat = .zero
    @State private var rowSize: CGSize = .zero
    @State private var scrollContainerSize: CGSize = .zero
    @State private var scrollContentSize: CGSize = .zero
    
    @State private var visibleRowCount = 0
    @State private var minVisibleIdx = 0
    @State private var maxVisibleIdx = 0
    
    let data: [Element]
    let initialFetchSize: Int
    var rowContent: (Element, Int?) -> RowContent
    
    init(data: [Element],
         initialFetchSize: Int = 10,
         @ViewBuilder rowContent: @escaping (Element, Int?) -> RowContent) {
        self.data = data
        self.initialFetchSize = initialFetchSize
        self.rowContent = rowContent
    }
    
    var body: some View {
        ScrollView {
            GeometryReader { gp in
                Color.clear
                    .preference(key: OffsetPrefKey.self, value: gp.frame(in: .named("scroll")).minY)
            }
            .frame(width: 0, height: 0)
            .padding(0)
            
            VStack(spacing: 0) {
                ForEach(Array(zip(data.indices, data)), id:\.0) { idx, elem in
                    if (idx >= minVisibleIdx && idx <= maxVisibleIdx) {
                        rowContent(elem, idx)
                            .background(
                                GeometryReader { gp in
                                    Color.clear
                                        .preference(key: SizePrefKey.self, value: gp.size)
                                }
                            )
                            .onPreferenceChange(SizePrefKey.self, perform: { rowSize in
                                print("Row Size: \(rowSize)")
                                self.rowSize = rowSize
                                self.visibleRowCount = Int(scrollContainerSize.height / self.rowSize.height)
                                print("Visible Row: \(self.visibleRowCount)")
                            })
                            .onAppear {
                                print("\(elem) has been appeared")
                            }
                            .onDisappear {
                                print("\(elem) has been disappeared")
                            }
                            .border(.blue)
                    } else {
                        Color.clear
                            .frame(width: rowSize.width, height: rowSize.height)
                            .padding(0)
                    }
                }
            }
            .background(
                GeometryReader { gp in
                    Color.clear
                        .preference(key: SizePrefKey.self, value: gp.size)
                }
            )
            .onPreferenceChange(SizePrefKey.self, perform: { contentSize in
                print("Scroll Content Size: \(contentSize)")
                scrollContentSize = contentSize
                
            })
        }
        .coordinateSpace(name: "scroll")
        .background(
            GeometryReader { gp in
                Color.clear
                    .preference(key: SizePrefKey.self, value: gp.size)
            }
        )
        .onPreferenceChange(SizePrefKey.self, perform: { containerSize in
            print("Scroll Container Size: \(containerSize)")
            scrollContainerSize = containerSize
            
        })
        .onPreferenceChange(OffsetPrefKey.self, perform: { offset in
            currentOffset = -offset
            print("Scroll Offset: \(-offset)")
            
            if (rowSize.height > 0 && currentOffset > rowSize.height) {
                minVisibleIdx = Int((currentOffset - rowSize.height) / rowSize.height)
                maxVisibleIdx = Int(visibleRowCount + minVisibleIdx + 2)
                
                print("minIdx: \(minVisibleIdx)")
                print("maxIdx: \(maxVisibleIdx)")
            } else {
                minVisibleIdx = 0
                maxVisibleIdx = initialFetchSize
            }
        })
        .onAppear {
            minVisibleIdx = 0
            maxVisibleIdx = initialFetchSize
        }
    }
}
