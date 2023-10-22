//
//  FormBuilder.swift
//
//  Created by Heecheon Park on 10/22/23.
//

import SwiftUI

// IdealInput ->
public protocol FormBuilder {
    //    String.makeFormValue("Name", $person.name)
    associatedtype Content: View
    static func makeFormValue(_ label: String?, _ value: Binding<Self>) -> Content
}

extension String: FormBuilder {
    public static func makeFormValue(_ label: String?, _ value: Binding<String>) -> some View {
        TextField(label ?? "", text: value)
    }
}

extension Int: FormBuilder {
    public static func makeFormValue(_ label: String?, _ value: Binding<Int>) -> some View {
        TextField(label ?? "", value: value, formatter: NumberFormatter())
    }
}

extension Bool: FormBuilder {
    public static func makeFormValue(_ label: String?, _ value: Binding<Bool>) -> some View {
        Toggle(isOn: value) { Text(label ?? "") }
    }
}

