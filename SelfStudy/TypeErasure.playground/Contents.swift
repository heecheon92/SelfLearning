import Combine
import Foundation

protocol SesameProtocol {
    associatedtype someType
    func _print() -> Void
    func returnSomeType() -> someType
}
class A: SesameProtocol {
    typealias someType = Int
    func returnSomeType() -> Int {
        return 0
    }
    func _print() {
        print("A")
    }
}
class B: SesameProtocol {
    typealias someType = Int
    func returnSomeType() -> Int {
        return 1
    }
    func _print() {
        print("B")
    }
}
class C: SesameProtocol {
    typealias someType = String
    func returnSomeType() -> String {
        return "C"
    }
    func _print() {
        print("C")
    }
}

class AnySesameProtocol<T>: SesameProtocol {
    func _print() {
        __print()
    }
    
    func returnSomeType() -> T {
        return _returnSomeType()
    }
    
    typealias someType = T
    
    private var _returnSomeType: () -> T
    private var __print: () -> Void
    
    init<U: SesameProtocol>(_ protoc: U) where U.someType == T {
        self.__print = protoc._print
        self._returnSomeType = protoc.returnSomeType
    }
}

let a = A()
let aa = A()
let b = B()
let bb = B()
let c = C()
let cc = C()

var arr: [AnySesameProtocol] = [
    AnySesameProtocol(a),
    AnySesameProtocol(aa),
    AnySesameProtocol(b),
    AnySesameProtocol(bb),
    AnySesameProtocol(bb),
]


arr.forEach {
    $0._print()
    print("type: ", type(of: $0))
}

