//
//  ContentView.swift
//  GlobalAlert
//
//  Created by Heecheon Park on 10/8/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var alert: GlobalAlertConfiguration = .init()
    @State private var alert2: GlobalAlertConfiguration = .init(slideEdge: .leading)
    @State private var alert3: GlobalAlertConfiguration = .init(slideEdge: .top)
    @State private var alert4: GlobalAlertConfiguration = .init(slideEdge: .trailing)
    
    var body: some View {
        Button("Show Alert") {
            alert.present()
            alert2.present()
            alert3.present()
            alert4.present()
        }
        .alert(config: $alert) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.red.gradient)
                .frame(width: 150, height: 150)
                .onTapGesture {
                    alert.dismiss()
                }
        }
        .alert(config: $alert2) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.blue.gradient)
                .frame(width: 150, height: 150)
                .onTapGesture {
                    alert2.dismiss()
                }
        }
        .alert(config: $alert3) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.yellow.gradient)
                .frame(width: 150, height: 150)
                .onTapGesture {
                    alert3.dismiss()
                }
        }
        .alert(config: $alert4) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.purple.gradient)
                .frame(width: 150, height: 150)
                .onTapGesture {
                    alert4.dismiss()
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(SceneDelegate())
}
