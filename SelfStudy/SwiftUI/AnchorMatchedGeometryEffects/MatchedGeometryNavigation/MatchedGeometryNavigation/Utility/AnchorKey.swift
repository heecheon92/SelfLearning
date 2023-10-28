//
//  AnchorKey.swift
//  MatchedGeometryNavigation
//
//  Created by Heecheon Park on 10/25/23.
//

import SwiftUI

struct AnchorKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}
