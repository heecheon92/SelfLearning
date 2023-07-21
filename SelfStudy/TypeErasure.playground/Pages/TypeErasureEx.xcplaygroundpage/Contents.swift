import Foundation

protocol TypeErased {
    var value: Any { get }
}

struct TypeEraser<T>: TypeErased {
    var value: Any

    init(_ value: T) {
        self.value = value
    }
}

struct AnyTypeContainer {
    private let storage: TypeErased
    var wrappedValue: Any { storage.value }

    init<T>(_ value: T) {
        self.storage = TypeEraser(value)
    }
}

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

let a = A()
let aa = A()
let b = B()
let bb = B()
let c = C()
let cc = C()

var arr: [AnyTypeContainer] = [
    AnyTypeContainer(a),
    AnyTypeContainer(aa),
    AnyTypeContainer(b),
    AnyTypeContainer(bb),
    AnyTypeContainer(c)
]

arr.forEach {
    print("type: ", type(of: $0.wrappedValue))
}
