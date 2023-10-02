import Foundation

// MARK: - Functor Declaration
protocol Functor {
    associatedtype T
    associatedtype U: Functor = Self
    
    func map<V>(_ transform: ((T) -> V)) -> U where U.T == V
}


struct MayBe<T>: Functor {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    func map<V>(_ transform: ((T) -> V)) -> MayBe<V> {
        return MayBe<V>(transform(value))
    }
}

extension MayBe: CustomStringConvertible {
    var description: String { "\(value)" }
}


// MARK: - Execution

let maybeInt = MayBe(1)
let maybeString = maybeInt.map { "\($0)" }
let maybeMaybeString = maybeString.map { MayBe($0) }
let maybeOptionalString = maybeString.map { Optional<String>($0) }
let maybeMaybeOptionalString = maybeMaybeString.map { $0.map({ v in Optional(v) }) }
let maybeOptionalMaybeString = maybeOptionalString.map { $0.map({ v in MayBe(v) }) }

print("maybeInt: \(maybeInt) (\(type(of: maybeInt)))")
print("maybeString: \(maybeString) (\(type(of: maybeString)))")
print("maybeMaybeString: \(maybeMaybeString) (\(type(of: maybeMaybeString)))")
print("maybeOptionalString: \(maybeOptionalString) (\(type(of: maybeOptionalString)))")
print("maybeMaybeOptionalString: \(maybeMaybeOptionalString) (\(type(of: maybeMaybeOptionalString)))")
print("maybeOptionalMaybeString: \(maybeOptionalMaybeString) (\(type(of: maybeOptionalMaybeString)))")
