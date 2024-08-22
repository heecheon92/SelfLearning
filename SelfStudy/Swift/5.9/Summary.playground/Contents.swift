import Foundation

// MARK: SE-0380 - if and switch expressions (as opposed to statement)
/// {description}
/// This proposal introduces the ability to use if and switch statements as expressions,
/// for the purpose of returning values from functions, properties, and closures;
/// assigning values to variables; and declasring variables.

let number = 2
let result = if (number & 1 == 1) { "Odd" } else { "Even" }
let switchResult = switch number {
case 0...10: "From 0 to 10"
case 11...20: "From 11 to 20"
case 21...30: "From 21 to 30"
default: "Out of range"
}

// MARK: - SE-0393, SE-0398, and SE-0399 - Value and Type Parameter Pack
/// {description}
/// This proposals allow us ot use varadic generics in Swift.
/// They solve a significant problem in Swift, which is that generic functions required a specific
/// number of type parameters. There functions could still accept variadic parameters but they
/// still had to use the same type ultimately.

// Following illustrates variadic parameters.
struct Grade1 { var name: String }
struct Grade2 { var name: String }
func pairUpStudents<T, U>(list1: T..., list2: U...) -> ([(T, U)]) {
    assert(list1.count == list2.count, "You must provide equal numbers of students to pair.")
    var pairs: [(T, U)] = []
    for i in 0..<list1.count {
        pairs.append((list1[i], list2[i]))
    }
    return pairs
}
pairUpStudents(list1: Grade1(name: "Tom"), Grade1(name: "Alice"), list2: Grade2(name: "Bob"), Grade2(name: "Alex"))

// maybe I should add an example of parameter pack....

// MARK: - SE0382, SE-0389, and SE-0397 - Macros
/// {description}
/// Swift macros allow you to generate that repetitive code at compile time,
/// making your app's codebases more expressive and easier to read.

//@freestanding(expression)
//public macro URL(_ stringLiteral: String) -> URL = #externalMacro(module: "MyMacrosPlugin", type: "URLMacro")
//let url = #URL("https://google.com")

// MARK: - SE-0390 - Noncopyable structs and enums
/// {description}
/// All currently existing types in Swift are copyable, meaning it is possible to create
/// multiple identical, interchangeable representations of any value of the type.
/// However, copyable structs and enums are not a great model for unique resources.
/// Classes by contrast can represent a unique resource, sine an object has a unique
/// identity once initialized, and only references to that unique object get copied.
/// This imposes overhead in the form of heap allocation and reference counting.
///
/// {New keywords}
/// Noncopyable also introduces few new keywords to remember:
/// ~Copyable, consuming, consume, discard

struct User { var name: String }
struct NonCopyableUser: ~Copyable { var name: String }
let u1 = User(name: "me")
let u2 = u1 // <-- this is ok.

let nu1 = NonCopyableUser(name: "not me")
//let nu2 = nu1 // <-- this errors

// MARK: - SE-0388 - Convenience Async[Throwing]Stream.makeStream methods
/// {description}
/// This proposal adds a new makeStream() method to both AsyncStream and AsyncThrowingStream that
/// sends back both the stream itself alongside its continutation.

// continuation and stream had to be declared and assigned as below
// prior to SE-0388
var continuation: AsyncStream<String>.Continuation!
let stream = AsyncStream<String> { continuation = $0 }

// new makeStream method shortens above process
let (newStream, newContinuation) = AsyncStream.makeStream(of: String.self)



