//
//  Person.swift
//  FormableTestApp
//
//  Created by Heecheon Park on 10/22/23.
//

import SwiftUI
import Formable

// @Formable <- attached macro
@Formable
struct Person {
    var name: String
    var age: Int
    var isAlive: Bool
}

// we want "@Formable Person" to generate code below
//extension Person: FormBuilder {
//    static func makeFormValue(_ label: String?, _ value: Binding<Person>) -> some View {
//        Group {
//            String.makeFormValue("Name", value.name)
//            Int.makeFormValue("Age", value.age)
//            Bool.makeFormValue("Is Alive", value.isAlive)
//        }
//    }
//}
