/// SE-0289
/// Result builders
/// https://github.com/swiftlang/swift-evolution/blob/main/proposals/0289-result-builders.md

// MARK: - makeSentence1
func makeSentence1() -> String {
  /// Single-expression functions can omit the return keyword.
  /// https://github.com/swiftlang/swift-evolution/blob/main/proposals/0255-omit-return.md
  "Why settle for a Duke when you can have a Prince?"
}

print(makeSentence1())
// prints:
// Why settle for a Duke when you can have a Prince?

// MARK: - makeSentence2
/// The following function is invalid because
/// the function is not a single-expression function and
/// it does not have a return statement.
// func makeSentence2() -> String {
//   "Why settle for a Duke"
//   "when you can have a Prince?"
// }

struct StringBuilder {
  static func buildBlock(_ parts: String...) -> String {
    parts.joined(separator: "\n")
  }
}

let str = StringBuilder.buildBlock("hi", "hello", "bye")
print(str)
// prints:
// hi
// hello
// bye

@resultBuilder
struct StringResultBuilder {
  static func buildBlock(_ parts: String...) -> String {
    parts.joined(separator: "\n")
  }
}

// MARK: - makeSentence3
@StringResultBuilder
func makeSentence3() -> String {
  /// Unlike makeSentence2, this function is valid
  /// even though it is not a single-expression and does not have a return statement.
  /// The function is valid because it uses the @resultBuilder attribute.
  /// The series of strings below are fed into the buildBlock function of StringResultBuilder.
  "Why settle for a Duke"
  "when you can have a Prince?"
}

print(makeSentence3())
// prints:
// Why settle for a Duke
// when you can have a Prince?

@resultBuilder
struct ConditionalStringBuilder {
  static func buildBlock(_ parts: String...) -> String {
    parts.joined(separator: "\n")
  }

  static func buildEither(first component: String) -> String {
    component
  }

  static func buildEither(second component: String) -> String {
    component
  }
}

// MARK: - makeSentence4
@ConditionalStringBuilder
func makeSentence4() -> String {
  "Why settle for a Duke"
  "when you can have"

  if Bool.random() {
    "a Prince?"
  } else {
    "a King?"
  }
}

print(makeSentence4())
// prints:
// (either of) "a Prince?" or "a King?"

@resultBuilder
struct ComplexStringBuilder {
  static func buildBlock(_ parts: String...) -> String {
    parts.joined(separator: "\n")
  }

  static func buildEither(first component: String) -> String {
    return component
  }

  static func buildEither(second component: String) -> String {
    return component
  }

  static func buildArray(_ components: [String]) -> String {
    components.joined(separator: "\n")
  }
}

// MARK: - makeSentence5
@ComplexStringBuilder
func makeSentence5() -> String {

  // each of element, in this case "i", is fed into buildArray.
  for i in 0..<10 {
    "\(i)"
  }

  "Lift off!"
}

print(makeSentence5())
// prints:
// 0
// 1
// 2
// 3
// 4
// 5
// 6
// 7
// 8
// 9
// Lift off!

@resultBuilder
struct SentenceBuilder {
  static func buildBlock(_ parts: String...) -> String {
    parts.joined(separator: " ")
  }

  static func buildExpression(_ expression: String) -> String {
    expression
  }
}

// MARK: - makeSentence6
func makeSentence6(@SentenceBuilder _ content: () -> String) -> String {
  content()
}

let sentence6 = makeSentence6 {
  "Hi"
  "My name is"
  "John Doe"
}
print(sentence6)
// prints:
// Hi My name is John Doe

/// building methods
/// - buildBlock(_ components: Component...) -> Component is used to build combined results for statement blocks. It is required to be a static method in every result builder.
/// - buildOptional(_ component: Component?) -> Component is used to handle a partial result that may or may not be available in a given execution. When a result builder provides buildOptional(_:), the transformed function can include if statements without an else.
/// - buildEither(first: Component) -> Component and buildEither(second: Component) -> Component are used to build partial results when a selection statement produces a different result from different paths. When a result builder provides these methods, the transformed function can include if statements with an else statement as well as switch statements.

/// - buildArray(_ components: [Component]) -> Component is used to build a partial result given the partial results collected from all of the iterations of a loop. When a result builder provides buildArray(_:), the transformed function can include for..in statements.
/// - buildExpression(_ expression: Expression) -> Component is used to lift the results of expression-statements into the Component internal currency type. It is optional, but when provided it allows a result builder to distinguish Expression types from Component types or to provide contextual type information for statement-expressions.
/// - buildFinalResult(_ component: Component) -> FinalResult is used to finalize the result produced by the outermost buildBlock call for top-level function bodies. It is optional, and allows a result builder to distinguish Component types from FinalResult types, e.g. if it wants builders to internally traffic in some type that it doesn't really want to expose to clients.
/// - buildLimitedAvailability(_ component: Component) -> Component is used to transform the partial result produced by buildBlock in a limited-availability context (such as if #available) into one suitable for any context. It is optional, and is only needed by result builders that might carry type information from inside an if #available outside it.

/// The following is the general structure of a result builder:
///   @resultBuilder
///   struct ExampleResultBuilder {
///     /// The type of individual statement expressions in the transformed function,
///     /// which defaults to Component if buildExpression() is not provided.
///     typealias Expression = ...
///
///     /// The type of a partial result, which will be carried through all of the
///     /// build methods.
///     typealias Component = ...
///
///     /// The type of the final returned result, which defaults to Component if
///     /// buildFinalResult() is not provided.
///     typealias FinalResult = ...
///
///     /// Required by every result builder to build combined results from
///     /// statement blocks.
///     static func buildBlock(_ components: Component...) -> Component { ... }
///
///     /// If declared, provides contextual type information for statement
///     /// expressions to translate them into partial results.
///     static func buildExpression(_ expression: Expression) -> Component { ... }
///
///     /// Enables support for `if` statements that do not have an `else`.
///     static func buildOptional(_ component: Component?) -> Component { ... }
///
///     /// With buildEither(second:), enables support for 'if-else' and 'switch'
///     /// statements by folding conditional results into a single result.
///     static func buildEither(first component: Component) -> Component { ... }
///
///     /// With buildEither(first:), enables support for 'if-else' and 'switch'
///     /// statements by folding conditional results into a single result.
///     static func buildEither(second component: Component) -> Component { ... }
///
///     /// Enables support for 'for..in' loops by combining the
///     /// results of all iterations into a single result.
///     static func buildArray(_ components: [Component]) -> Component { ... }
///
///     /// If declared, this will be called on the partial result of an 'if
///     /// #available' block to allow the result builder to erase type
///     /// information.
///     static func buildLimitedAvailability(_ component: Component) -> Component { ... }
///
///     /// If declared, this will be called on the partial result from the outermost
///     /// block statement to produce the final returned result.
///     static func buildFinalResult(_ component: Component) -> FinalResult { ... }
///   }
