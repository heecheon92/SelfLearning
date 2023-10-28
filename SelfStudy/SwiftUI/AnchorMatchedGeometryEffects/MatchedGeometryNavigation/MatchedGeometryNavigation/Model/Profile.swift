//
//  Profile.swift
//  MatchedGeometryNavigation
//
//  Created by Heecheon Park on 10/25/23.
//

import Foundation
import SwiftUI

struct Profile: Identifiable {
    let id = UUID().uuidString
    var userName: String
    var placeholderColor: Color
    var lastMsg: String
    var lastActive: String
}

var profiles = [
    Profile(userName: "One", placeholderColor: .red, lastMsg: "Hi, from One", lastActive: "10:25 PM"),
    Profile(userName: "Two", placeholderColor: .blue, lastMsg: "Hi, from Two", lastActive: "10:25 PM"),
    Profile(userName: "Three", placeholderColor: .yellow, lastMsg: "Hi, from Three", lastActive: "10:25 PM"),
    Profile(userName: "Four", placeholderColor: .green, lastMsg: "Hi, from Four", lastActive: "10:25 PM"),
    Profile(userName: "Five", placeholderColor: .teal, lastMsg: "Hi, from Five", lastActive: "10:25 PM")
]
