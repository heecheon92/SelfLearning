//
//  WindowSharedModel.swift
//  MatchedGeometrySheet
//
//  Created by Heecheon Park on 10/29/23.
//

import Foundation
import SwiftUI

@Observable final class WindowSharedModel {
    
    var sourceRect: CGRect = .zero
    var previousSourceRect: CGRect = .zero
    var hideNativeView: Bool = false
    var selectedProfile: Profile?
    var cornerRadius: CGFloat = 0
    
    func reset() {
        sourceRect = .zero
        previousSourceRect = .zero
        hideNativeView = false
        selectedProfile = nil
        cornerRadius = 0
    }
}
