//
//  ContentView.swift
//  VariantView
//
//  Created by Heecheon Park on 10/19/22.
//

import SwiftUI


protocol VariantView: View {
    associatedtype Variance
    func setVariance(variance: @escaping (() -> Variance)) -> Self
}
protocol PolymorphicVariantView: VariantView
where Variance == any PolymorphicVariance {}

protocol VarianceView: View {}
protocol PolymorphicVariance: VarianceView {}

struct ContentView: View {
    
    @State private var toggleVariance = false
    
    var body: some View {
        Group {
            Button(action: { toggleVariance.toggle() }, label: { Text("Toggle Variance") })
            PolymorphicView()
                .setVariance(variance: toggleVariance ? PolymorphicVarianceOne() : PolymorphicVarianceTwo())
        }
    }
}

struct PolymorphicView: PolymorphicVariantView {

    var dynamicContent: AnyView?
    
    var body: some View {
        if let _dynamicContent = dynamicContent {
            _dynamicContent
        } else {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
            }
            .padding()
        }
    }
    
    func setVariance(variance: @autoclosure @escaping (() -> any PolymorphicVariance)) -> PolymorphicView {
        var res = self
        res.dynamicContent = AnyView(variance())
        return res
    }
}

struct PolymorphicVarianceOne: PolymorphicVariance {
    var body: some View {
        HStack {
            Text("PolymorphicVariance")
            Text("One")
        }
    }
}

struct PolymorphicVarianceTwo: PolymorphicVariance {
    var body: some View {
        VStack {
            Text("PolymorphicVariance")
            Text("Two")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
