import Foundation

/// "associatedtype" is a placeholder for a protocol.
/// consider a generic class that can take any parameter.

class KRGenericClass<T> {
    
    var a: T
    
    init(_ value: T) {
        self.a = value
    }
}

/// KRClass can take any parameter as it has T as a placeholder.
let a = KRGenericClass(4)
let b = KRGenericClass("Hello")

/// However, we cannot put <T> for protocol definition
///
/// Following protocol definition won't compile.
///
/// protocol KRGenericProtocol<T> {
///     var a: T { get set }
/// }
///
/// Instead, we have to introduce associated type.
///
protocol KRGenericProtocol {
    associatedtype T
    var a: T { get set }
}
///
/// Protocol with associatedtype enables a lot of flexibility
/// but also generates massive headaches.
///
/// Consider following case, we have a generic protocol and
/// a compare function that compares two protocol object

protocol Identifiable {
    associatedtype ID
    var id: ID { get set }
}

func compareIdentifiable(_ a: Identifiable, _ b: Identifiable) -> Bool {
    return true
    
    // or return a.id == b.id
}

/// Prior to Swift 5.7, defining a function above was tricky.....
/// func compareIdentifiable(_ a: any Identifiable, _ b: any Identifiable) -> Bool {} would fix the problem in 5.7
/// However, Imagine we are using Swift version less than 5.7.
/// Why do we have a problem to define the compare function?

/// Swift compiler complains about the function above due to the following reason.
class IdentifiableClass: Identifiable {
    typealias ID = Int
    var id = 0
}

class IdentifiableClassEx: Identifiable {
    typealias ID = String
    var id = "Hello, world"
}

/// Although "IdentifiableClass" and "IdentifiableClassEx" both conform to
/// "Identifiable" protocol, because each class can define "var id" with different type,
/// Swift compiler does not allow polymorphic behavior.
/// Protocol without Self or associatetype constraint allow below implementation.
protocol SimpleIdentifiable {
    var id: Int { get set }
}

func compareSimpleIdentifiable(_ a: SimpleIdentifiable, _ b: SimpleIdentifiable) -> Bool {
    return a.id == b.id
}

/// Now, how do we fix "compareIdentifiable" function?
/// Check this out..... it is a pain in the ......
func compareIdentifiable<T, U>(_ a: T, _ b: U) -> Bool where T: Identifiable,
                                                             U: Identifiable,
                                                             T.ID: Equatable,
                                                             U.ID: Equatable,
                                                             T.ID == U.ID {
                                                                 
    return a.id == b.id
}

/// Understanding concepts above introduces a bit more advanced concepts.
/// Opaqure result type, type-erasure, "some" keyword, "any" keyword.
/// Let's analyze and dive into these concepts later.
