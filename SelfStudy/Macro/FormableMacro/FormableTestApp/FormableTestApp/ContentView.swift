//
//  ContentView.swift
//  FormableTestApp
//
//  Created by Heecheon Park on 10/21/23.
//

import SwiftUI
import Formable

struct ContentView: View {
    
    @State var person = Person(name: "Me", age: 30, isAlive: true)
    
    var body: some View {
        VStack {
            
            // Form.derive($peron)
            /// We want the line above generate the code below during the compile time.
            
            // Ideal Staert: Form.derive($person)
            
            // input -> output
            
            // Normalized / Cleaned Up Target:
            //            Form {
            //                String.makeFormValue("Name", $person.name)
            //                Int.makeFormValue("Age", $person.age)
            //                Bool.makeFormValue("Is Alive", $person.isAlive)
            //            }
            
            // Boilerplate Target:
            //            Form {
            //                TextField("Name", text: $person.name)
            //                TextField("Age", value: $person.age, formatter: NumberFormatter())
            //                Toggle(isOn: $person.isAlive) {
            //                    Text("Is Alive")
            //                }
            //            }
            
            Form.derived($person)
            Text(String(reflecting: person))
        }
        .padding()
    }
}

extension Form {
    static func derived<A: FormBuilder>(_ binding: Binding<A>) -> some View where A.Content == Content {
        Form {
            A.makeFormValue(nil, binding)
        }
    }
}


#Preview {
    ContentView()
}
