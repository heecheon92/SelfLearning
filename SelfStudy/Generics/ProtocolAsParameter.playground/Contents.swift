import Foundation
import SwiftUI

protocol MainProtocol {
    associatedtype SubProtocol
    
    func setSubProtocol(s: SubProtocol)
}

protocol SubProtocol {
    associatedtype SomeType
    
    func getWrappedValue() -> SomeType
}

struct MainStruct: MainProtocol {
    
    func setSubProtocol(s: any SubProtocol) {}
}

struct SubStruct: SubProtocol {
    
    func getWrappedValue() -> some View {
        EmptyView()
    }
}

