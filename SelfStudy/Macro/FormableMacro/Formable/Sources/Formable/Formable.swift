// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)   // <- @freestanding macro replaces the usage with macro definition
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "FormableMacros", type: "StringifyMacro")

// @Formable
// struct Person

// extension Person: FormBuilder {}
//@attached(conformance) has been replaced with @attached(extension)
@attached(extension, conformances: FormBuilder)
@attached(member, names: named(makeFormValue))

// below can also be achieved
//@attached(member, names: named(makeFormValue), names: named(fnName), names: named(fnName) ....)
//@attached(member, arbitrary)
public macro Formable() = #externalMacro(module: "FormableMacros", type: "FormableMacro")

