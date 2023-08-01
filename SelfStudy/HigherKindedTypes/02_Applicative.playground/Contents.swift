import Foundation

// MARK: - Functor Declaration
protocol Functor {
    associatedtype T
    associatedtype U: Functor = Self
    
    func map<V>(_ transform: ((T) -> V)) -> U where U.T == V
}

// MARK: - Applicative Class Implementation
// I really wanted to make the Applicative as a protocol
// but Swift compiler seems to complain due to complexity.
class Applicative<T>: Functor {

    let content: T

    init(_ content: T) { self.content = content }

    func map<V>(_ transform: ((T) -> V)) -> Applicative<V> {
        return Applicative<V>(transform(content))
    }

    func apply<V>(_ boxedThunk: Applicative<(T) -> V>) -> Applicative<V> {
        return Applicative<V>(boxedThunk.content(content))
    }
}

// MARK: - Applicative protocol declaration
/// My attempt to create an applicative protocol
/// Protocol declaration itself has not problem to compile but
/// implementation has a problem.
///
///     protocol Applicative: Functor {
///         associatedtype A: Functor = Self
///         func apply<V>(_ boxedThunk: A) -> U where A.T == ((T) -> V), U.T == V
///     }
///
// MARK: - Applicative protocol conformance
/// It does not spit any syntax error so linquistically speaking,
/// following Box implementation is flawed but takes too long for compiling
/// and then eventually fails to build.
///
///     struct Box<T>: Applicative {
///         let content: T
///         init(_ content: T) { self.content = content }
///         func apply<V>(_ boxedThunk: Box<(T) -> V>) -> Box<V> {
///             return Box<V>(boxedThunk.content(content))
///         }
///     }

class MayBe<T>: Applicative<T> {
    let value: T
    
    override init(_ value: T) {
        self.value = value
        super.init(value)
    }
    
    override func map<V>(_ transform: ((T) -> V)) -> MayBe<V> {
        return MayBe<V>(transform(value))
    }
    
    func apply<V>(_ boxedThunk: MayBe<(T) -> V>) -> MayBe<V> {
        return MayBe<V>(boxedThunk.content(content))
    }
}

extension MayBe: CustomStringConvertible {
    var description: String {
        
        var former = "value: \(value)"
        var latter = "\(type(of: value))"
        
        while former.count < 20 {
            former += " "
        }
        return former + "type:" + latter
    }
}


// MARK: - Execution
let mayBeOne                    = MayBe(1)
let mayBeDoubling               = MayBe<(Int) -> Int>({ $0 * 2 })
let mayBeDoubledOne             = mayBeOne.apply(mayBeDoubling)
let mayBeDoubledDoubledOne      = mayBeDoubledOne.apply(mayBeDoubling)
let mayBeStringifier            = MayBe<(Int) -> String>({ "\($0)" })
let mayBeDoubledOneStringified  = mayBeDoubledOne.apply(mayBeStringifier)

print(mayBeOne)
print(mayBeDoubling)
print(mayBeDoubledOne)
print(mayBeDoubledDoubledOne)
print(mayBeDoubledOneStringified)

