//
//  ContentView.swift
//  FigmaUnitConversion
//
//  Created by Heecheon Park on 2023/02/23.
//

import SwiftUI

enum NavigationStackElement {
    case first,
    second,
    third
}

struct ContentView: View {
    
    @State private var layoutSize: CGSize = .zero
    @State private var nativeLayoutSize: CGSize = .zero
    @State private var dynamicLayoutSize: CGSize = .zero
    @State private var dynamicNativeLayoutSize: CGSize = .zero
    @State private var nvStack: [NavigationStackElement] = []
    
    var body: some View {
        NavigationStack(path: $nvStack) {
            FixedLayoutView()
                .navigationDestination(for: NavigationStackElement.self) { element in
                    if element == .first {
                        DynamicLayoutView()
                    } else {
                        EmptyView()
                    }
                }
            
            Button(action: { nvStack.append(.first) }, label: { Text("Next") })
        }
    }
}

extension ContentView {
    
    @ViewBuilder func FixedLayoutView() -> some View {
        ZStack {
            VStack {
                Text("screen layout width: \(FigmaUnitConverter.uiScreenWidth)")
                Text("screen layout height: \(FigmaUnitConverter.uiScreenHeight)")
                
                Text("figma layout width: \(FigmaUnitConverter.figmaScreenWidth)")
                    .padding(.top)
                Text("figma layout height: \(FigmaUnitConverter.figmaScreenHeight)")
                Text("figma width rate: \(FigmaUnitConverter.widthRate)")
                    .padding(.top)
                Text("figma height rate: \(FigmaUnitConverter.heightRate)")
                Spacer()
            }
            
            VStack {
                Color.yellow
                    .figmaFrame(width: 333, height: 102)
                    .getSize { layoutSize = $0 }
                
                Text("layout width: \(layoutSize.width)")
                Text("layout height: \(layoutSize.height)")
                
                Color.green
                    .frame(width: 333, height: 102)
                    .getSize { nativeLayoutSize = $0 }
                
                Text("native layout width: \(nativeLayoutSize.width)")
                Text("native layout height: \(nativeLayoutSize.height)")
            }
        }
    }
    
    @ViewBuilder func DynamicLayoutView() -> some View {
        ZStack {
            VStack {
                Text("screen layout width: \(FigmaUnitConverter.uiScreenWidth)")
                Text("screen layout height: \(FigmaUnitConverter.uiScreenHeight)")
                
                Text("figma layout width: \(FigmaUnitConverter.figmaScreenWidth)")
                    .padding(.top)
                Text("figma layout height: \(FigmaUnitConverter.figmaScreenHeight)")
                
                Text("figma width rate: \(FigmaUnitConverter.widthRate)")
                    .padding(.top)
                Text("figma height rate: \(FigmaUnitConverter.heightRate)")
                Spacer()
            }
            
            VStack {
                Color.yellow
                    .figmaFrame(height: 102)
                    .getSize { dynamicLayoutSize = $0 }
                    .figmaPadding(.horizontal, 21)
                
                Color.yellow
                    .figmaFrame(height: 102)
                    .getSize { dynamicLayoutSize = $0 }
                    .figmaPadding([.leading, .trailing, .top], 21)
                
                Text("dynamicLayout width: \(dynamicLayoutSize.width)")
                Text("dynamicLayout height: \(dynamicLayoutSize.height)")
                
                Color.green
                    .frame(height: 102)
                    .getSize { dynamicNativeLayoutSize = $0 }
                    .padding(.horizontal, 21)
                
                Text("dynamicNativeLayout width: \(dynamicNativeLayoutSize.width)")
                Text("dynamicNativeLayout height: \(dynamicNativeLayoutSize.height)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
