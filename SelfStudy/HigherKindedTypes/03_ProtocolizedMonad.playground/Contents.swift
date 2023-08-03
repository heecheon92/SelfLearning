import Foundation

// MARK: - Functor Declaration
protocol Functor {
    associatedtype T
    associatedtype U: Functor = Self
    
    func map<V>(_ transform: ((T) -> V)) -> U where U.T == V
}

protocol Monad: Functor {
    associatedtype M: Functor = Self
    
    func flatMap<V>(_ transform: ((T) -> M)) -> U where U.T == V
    func flatMap<V>(_ transform: ((T) -> V)) -> U where U.T == V
}

struct MayBe<T>: Monad {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    func map<V>(_ transform: ((T) -> V)) -> MayBe<V> {
        return MayBe<V>(transform(value))
    }
    
    func apply<V>(_ boxedThunk: MayBe<(T) -> V>) -> MayBe<V> {
        return MayBe<V>(boxedThunk.value(value))
    }
    
    func flatMap<V>(_ transform: ((T) -> MayBe<V>)) -> MayBe<V> {
        return transform(value)
    }
    
    func flatMap<V>(_ transform: ((T) -> V)) -> MayBe<V> {
        return MayBe<V>(transform(value))
    }
}

extension MayBe: CustomStringConvertible {
    var description: String { "\(type(of: value))" }
}

let fmaybeInt                  = MayBe(1)
let fmaybeString               = fmaybeInt.map { "\($0)" }
let fmaybeMaybeString          = fmaybeString.map { MayBe($0) }
let fmaybeOptionalString       = fmaybeString.map { Optional<String>($0) }
let fmaybeMaybeOptionalString  = fmaybeMaybeString.map { $0.map({ v in Optional(v) }) }
let fmaybeOptionalMaybeString  = fmaybeOptionalString.map { $0.map({ v in MayBe(v) }) }

let mmaybeInt                  = MayBe(1)
let mmaybeString               = mmaybeInt.flatMap { MayBe("\($0)") }
let mmaybeMaybeString          : MayBe<String> = mmaybeString.flatMap { MayBe($0) } // flatMap doesn't produce "MayBe<MayBe<String>>"
let mmaybeOptionalString       : MayBe<Optional<String>> = mmaybeString.flatMap { Optional<String>($0) }
let mmaybeMaybeOptionalString  = mmaybeMaybeString.flatMap { $0.flatMap({ v in Optional(v) }) }
let mmaybeOptionalMaybeString  = mmaybeOptionalString.flatMap { $0 }

print(fmaybeInt)
print(fmaybeString)
print(fmaybeMaybeString)
print(fmaybeOptionalString)
print(fmaybeMaybeOptionalString)
print(fmaybeOptionalMaybeString)
print("===================================")
print(mmaybeInt)
print(mmaybeString)
print(mmaybeMaybeString)
print(mmaybeOptionalString)
print(mmaybeMaybeOptionalString)
print(mmaybeOptionalMaybeString)
