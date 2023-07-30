import Foundation

protocol P {
    associatedtype T
    var generic: G<T> { get }   // <- This guy is the problem when opening or closing existential
    var value: T { get }
}

struct G<T> { var wrappedValue: T }

struct S1: P {
    typealias T = Int
    var generic = G(wrappedValue: 1)
    var value = 1
}

struct S2: P {
    typealias T = String
    var generic = G(wrappedValue: "hi")
    var value = "hi"
}

struct S3: P {
    typealias T = Double
    var generic = G(wrappedValue: 1.9)
    var value = 1.9
}

func resolve(_ arg: some P) -> some P {
    switch arg {
    case is S1: print("S1")
    case is S2: print("S2")
    case is S3: print("S3")
    default: print("any P")
    }
    return arg
}

func resolveExistential<U:P>(_ arg: U) -> G<U.T> {
    return arg.generic
}

func resolveExistentialToString<U:P>(_ arg: U) -> String {
    return "\(type(of: arg.generic))"
}

let list: [any P] = [S1(), S2(), S3()]

list.forEach {
    print($0.value)                         // OK
    print($0.generic.wrappedValue)          // Not OK, Member 'generic' cannot be used on value of type 'any P'; consider using a generic constraint instead
    print(resolve($0))                      // OK
    print(resolveExistential($0))           // Not OK, Type 'any P' cannot conform to 'P'
    print(resolveExistentialToString($0))   // OK, prints the runtime-type in String
    
    // Need to find a way to directly access $0.generic.
}
