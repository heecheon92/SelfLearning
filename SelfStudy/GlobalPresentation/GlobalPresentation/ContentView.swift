//
//  ContentView.swift
//  GlobalPresentation
//
//  Created by Heecheon Park on 11/9/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    NestedView()
                } label: {
                    Text("Next")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct NestedView: View {
    
    @EnvironmentObject var context: PresentationContext
    @State var showLocalSheet = false
    
    var body: some View {
        VStack {
            Text("NestedView")
            
            Button(action: { showLocalSheet = true}, label: {
                Text("showSheet")
            })
        }
        .sheet(isPresented: $showLocalSheet) {
            LocalSheetView()
        }
    }
}

struct LocalSheetView: View {
    
    @EnvironmentObject var context: PresentationContext
    @State var showLocalSheet = false
    
    var body: some View {
        VStack {
            Text("LocalSheetView")
            
            Button(action: { context.showGlobalView = true}, label: {
                Text("show Global Sheet")
            })
        }
    }
}

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
    
    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }
    
    var visibleViewController: UIViewController? {
        while let presentVC = rootViewController?.presentedViewController {
            return presentVC
        }
        return rootViewController
    }
}
