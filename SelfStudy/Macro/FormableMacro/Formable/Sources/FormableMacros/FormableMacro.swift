import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
        return "(\(argument), \(literal: argument.description))"
    }
}

public struct FormableMacro: ExtensionMacro, MemberMacro {
    
    // extension Person: FormBuilder { }
    public static func expansion(of node: AttributeSyntax,  // <- Syntax of the attribute "@Formable"
                                 attachedTo declaration: some DeclGroupSyntax,  // <- struct Person { var name: String ; ... }
                                 providingExtensionsOf type: some TypeSyntaxProtocol,   // <- extension Person: ...
                                 conformingTo protocols: [TypeSyntax],
                                 in context: some MacroExpansionContext)  // <- Means of reporting diagnostics
    throws -> [ExtensionDeclSyntax] {
        
//        let decl: DeclSyntax = """
//        extension Foo: FormBuilder {
//            var foo: String { "foo" }
//            func printFoo() { print(foo) }
//        }
//        """
//        
//        guard let extensionDecl = decl.as(ExtensionDeclSyntax.self) else {
//          return []
//        }
//
//        return [extensionDecl]
        
        /// ExtensionDeclSyntax
        ///
        /// ExtensionDeclSyntax allows "extension" declaration to be attached.
        /// i.e.
        ///
        /// @FormBuilder struct Person {
        ///   let name: String = ""
        /// }
        ///
        /// Above struct declaration gets translated into
        ///
        /// struct Person {
        ///   let name: String = ""
        /// }
        ///
        /// extension Person: FormBuilder {}
        let formableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): FormBuilder {}")
        return [formableExtension]
    }
    
    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        // func makeFormValue...
        // func coolFunc...
        
//        static func makeFormValue(_ label: String?, _ value: Binding<Person>) -> some View {
//            Group {
//                String.makeFormValue("Name", value.name)
//                Int.makeFormValue("Age", value.age)
//                Bool.makeFormValue("Is Alive", value.isAlive)
//            }
//        }
        
        ["""
        static func makeFormValue(_ label: String?, _ value: Binding<Person>) -> some View {
            Group {
                Text("Hello from macro world")
                String.makeFormValue("Name", value.name)
                Int.makeFormValue("Age", value.age)
                Bool.makeFormValue("Is Alive", value.isAlive)
            }
        }
        """]
    }
}

@main
struct FormablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        FormableMacro.self
    ]
}
