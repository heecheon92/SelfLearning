//
//  FigmaUnitConverter.swift
//  FigmaUnitConversion
//
//  Created by Heecheon Park on 2023/02/23.
//

import Foundation
import SwiftUI

struct FigmaUnitConverter {
    
    static let figmaScreen           : CGSize = CGSize(width: 375, height: 740)
    static var figmaScreenWidth      : CGFloat   { figmaScreen.width }
    static var figmaScreenHeight     : CGFloat   { figmaScreen.height }
    static var uiScreen              : CGSize    { UIScreen.main.bounds.size }
    static var uiScreenWidth         : CGFloat   { uiScreen.width }
    static var uiScreenHeight        : CGFloat   { uiScreen.height }
    static var uiScreenScale         : CGFloat   { UIScreen.main.scale }
    
    static var widthRate             : CGFloat { uiScreenWidth / figmaScreenWidth }
    static var heightRate            : CGFloat { uiScreenHeight / figmaScreenHeight }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool,
                                          @ViewBuilder transform: (Self) -> Content) -> some View {
        if (condition) {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func figmaPadding(_ edges: Edge.Set = .all,
                                   _ length: CGFloat? = nil) -> some View {
        if let length {
            self
                .modifier(FigmaPaddingModifier(edges: edges, length: length))
        } else {
            self.padding(edges, length)
        }
    }
    
    @ViewBuilder func figmaFrame(minWidth: CGFloat? = nil,
                                 idealWidth: CGFloat? = nil,
                                 maxWidth: CGFloat? = nil,
                                 minHeight: CGFloat? = nil,
                                 idealHeight: CGFloat? = nil,
                                 maxHeight: CGFloat? = nil,
                                 alignment: Alignment = .center) -> some View {
        self
            .frame(minWidth:     minWidth    == nil ? nil : minWidth!    * FigmaUnitConverter.widthRate,
                   idealWidth:   idealWidth  == nil ? nil : idealWidth!  * FigmaUnitConverter.widthRate,
                   maxWidth:     maxWidth    == nil ? nil : maxWidth!    * FigmaUnitConverter.widthRate,
                   minHeight:    minHeight   == nil ? nil : minHeight!   * FigmaUnitConverter.heightRate,
                   idealHeight:  idealHeight == nil ? nil : idealHeight! * FigmaUnitConverter.heightRate,
                   maxHeight:    maxHeight   == nil ? nil : maxHeight!   * FigmaUnitConverter.heightRate,
                   alignment: alignment)
    }
    
    @ViewBuilder func figmaFrame(width: CGFloat? = nil,
                                 height: CGFloat? = nil,
                                 alignment: Alignment = .center) -> some View {
        self
            .frame(width:   width   == nil ? nil : width! * FigmaUnitConverter.widthRate,
                   height:  height  == nil ? nil : height! * FigmaUnitConverter.heightRate,
                   alignment: alignment)
    }
}

extension View {
    @ViewBuilder func getSize(onSizeSet: @escaping (CGSize) -> Void) -> some View {
        self.modifier(SizeReader(onSizeSet: onSizeSet))
    }
}

struct FigmaPaddingModifier: ViewModifier {
    let edges: Edge.Set
    let length: CGFloat
    
    func body(content: Content) -> some View {
        
        if edges == .all {
            content
                .padding(.vertical,        length * FigmaUnitConverter.heightRate)
                .padding(.horizontal,      length * FigmaUnitConverter.widthRate)
        }
        else if edges == .top          { content.padding(.top,        length * FigmaUnitConverter.heightRate) }
        else if edges == .bottom       { content.padding(.bottom,     length * FigmaUnitConverter.heightRate) }
        else if edges == .vertical     { content.padding(.vertical,   length * FigmaUnitConverter.heightRate) }
        else if edges == .leading      { content.padding(.leading,    length * FigmaUnitConverter.widthRate) }
        else if edges == .trailing     { content.padding(.trailing,   length * FigmaUnitConverter.widthRate) }
        else if edges == .horizontal   { content.padding(.horizontal, length * FigmaUnitConverter.widthRate) }
        else if edges.contains(.vertical)   { verticalPaddingContentBuilder(content: content) }
        else if edges.contains(.horizontal)  { horizontalPaddingContentBuilder(content: content) }
        else if edges.contains(.top)        { topPaddingContentBuilder(content: content) }
        else if edges.contains(.bottom)     { bottomPaddingContentBuilder(content: content)}
        
    }
    
    @ViewBuilder func topPaddingContentBuilder(content: Content) -> some View {
        if edges.rawValue == Edge.Set.top.rawValue + Edge.Set.leading.rawValue {
            content
                .padding(.top,             length * FigmaUnitConverter.heightRate)
                .padding(.leading,         length * FigmaUnitConverter.widthRate)
        } else if edges.rawValue == Edge.Set.top.rawValue + Edge.Set.trailing.rawValue {
            content
                .padding(.top,             length * FigmaUnitConverter.heightRate)
                .padding(.trailing,        length * FigmaUnitConverter.widthRate)
        } else if edges.rawValue == Edge.Set.top.rawValue + Edge.Set.horizontal.rawValue {
            content
                .padding(.top,             length * FigmaUnitConverter.heightRate)
                .padding(.horizontal,        length * FigmaUnitConverter.widthRate)
        }
    }
    
    @ViewBuilder func bottomPaddingContentBuilder(content: Content) -> some View {
        if edges.rawValue == Edge.Set.bottom.rawValue + Edge.Set.leading.rawValue {
            content
                .padding(.bottom,          length * FigmaUnitConverter.heightRate)
                .padding(.leading,         length * FigmaUnitConverter.widthRate)
        } else if edges.rawValue == Edge.Set.bottom.rawValue + Edge.Set.trailing.rawValue {
            content
                .padding(.bottom,          length * FigmaUnitConverter.heightRate)
                .padding(.trailing,        length * FigmaUnitConverter.widthRate)
        } else if edges.rawValue == Edge.Set.bottom.rawValue + Edge.Set.horizontal.rawValue {
            content
                .padding(.bottom,             length * FigmaUnitConverter.heightRate)
                .padding(.horizontal,        length * FigmaUnitConverter.widthRate)
        }
    }
    
    @ViewBuilder func leadingPaddingContentBuilder(content: Content) -> some View {
        if edges.rawValue == Edge.Set.leading.rawValue + Edge.Set.top.rawValue {
            content
                .padding(.leading,         length * FigmaUnitConverter.widthRate)
                .padding(.top,             length * FigmaUnitConverter.heightRate)
        } else if edges.rawValue == Edge.Set.leading.rawValue + Edge.Set.bottom.rawValue {
            content
                .padding(.leading,         length * FigmaUnitConverter.widthRate)
                .padding(.bottom,          length * FigmaUnitConverter.heightRate)
        } else if edges.rawValue == Edge.Set.leading.rawValue + Edge.Set.vertical.rawValue {
            content
                .padding(.leading,         length * FigmaUnitConverter.widthRate)
                .padding(.vertical,        length * FigmaUnitConverter.heightRate)
        }
    }
    
    @ViewBuilder func trailingPaddingContentBuilder(content: Content) -> some View {
        if edges.rawValue == Edge.Set.trailing.rawValue + Edge.Set.top.rawValue {
            content
                .padding(.trailing,        length * FigmaUnitConverter.widthRate)
                .padding(.top,             length * FigmaUnitConverter.heightRate)
        } else if edges.rawValue == Edge.Set.trailing.rawValue + Edge.Set.bottom.rawValue {
            content
                .padding(.trailing,        length * FigmaUnitConverter.widthRate)
                .padding(.bottom,          length * FigmaUnitConverter.heightRate)
        } else if edges.rawValue == Edge.Set.trailing.rawValue + Edge.Set.vertical.rawValue {
            content
                .padding(.trailing,        length * FigmaUnitConverter.widthRate)
                .padding(.vertical,        length * FigmaUnitConverter.heightRate)
        }
    }
    
    @ViewBuilder func verticalPaddingContentBuilder(content: Content) -> some View {
        if edges.rawValue == Edge.Set.vertical.rawValue + Edge.Set.leading.rawValue {
            content
                .padding(.vertical,        length * FigmaUnitConverter.heightRate)
                .padding(.leading,         length * FigmaUnitConverter.widthRate)
        } else if edges.rawValue == Edge.Set.vertical.rawValue + Edge.Set.trailing.rawValue {
            content
                .padding(.vertical,        length * FigmaUnitConverter.heightRate)
                .padding(.trailing,        length * FigmaUnitConverter.widthRate)
        }
    }
    
    @ViewBuilder func horizontalPaddingContentBuilder(content: Content) -> some View {
        if edges.rawValue == Edge.Set.horizontal.rawValue + Edge.Set.top.rawValue {
            content
                .padding(.horizontal,      length * FigmaUnitConverter.widthRate)
                .padding(.top,             length * FigmaUnitConverter.heightRate)
            
        } else if edges.rawValue == Edge.Set.horizontal.rawValue + Edge.Set.bottom.rawValue {
            content
                .padding(.horizontal,      length * FigmaUnitConverter.widthRate)
                .padding(.bottom,          length * FigmaUnitConverter.widthRate)
        }
    }
}


struct SizeReader: ViewModifier {
    
    let onSizeSet: (CGSize) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geo.size)
                        .onPreferenceChange(SizePreferenceKey.self) { pref in
                            DispatchQueue.main.async {
                                onSizeSet(pref)
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.async {
                                onSizeSet(geo.size)
                            }
                        }
                })
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    }
}
