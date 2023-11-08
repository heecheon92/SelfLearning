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
    
    /// Implementation for
    /// "@attached(extension, conformances: FormBuilder)"
    public static func expansion(of node: AttributeSyntax,  // <- Syntax of the attribute "@Formable"
                                 attachedTo declaration: some DeclGroupSyntax,  // <- struct Person { var name: String ; ... }
                                 providingExtensionsOf type: some TypeSyntaxProtocol,   // <- extension Person: ...
                                 conformingTo protocols: [TypeSyntax],
                                 in context: some MacroExpansionContext)  // <- Means of reporting diagnostics
    throws -> [ExtensionDeclSyntax] {
        
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
    
    /// Implementation for
    /// "@attached(member, names: named(makeFormValue))"
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
        
        /// Excerpted from "\(raw: declaration.debugDescription)" via "@Formable struct Person { ... }" (refactor -> inline macro)
        ///
        ///     StructDeclSyntax
        ///    ├─attributes: AttributeListSyntax
        ///        │ ╰─[0]: AttributeSyntax
        ///        │   ├─atSign: atSign
        ///        │   ╰─attributeName: IdentifierTypeSyntax
        ///        │     ╰─name: identifier("Formable")
        ///    ├─modifiers: DeclModifierListSyntax
        ///    ├─structKeyword: keyword(SwiftSyntax.Keyword.struct)
        ///    ├─name: identifier("Person")
        ///    ╰─memberBlock: MemberBlockSyntax
        ///    ├─leftBrace: leftBrace
        ///    ├─members: MemberBlockItemListSyntax
        ///        │ ├─[0]: MemberBlockItemSyntax
        ///        │ │ ╰─decl: VariableDeclSyntax
        ///        │ │   ├─attributes: AttributeListSyntax
        ///        │ │   ├─modifiers: DeclModifierListSyntax
        ///        │ │   ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.var)
        ///        │ │   ╰─bindings: PatternBindingListSyntax
        ///        │ │     ╰─[0]: PatternBindingSyntax
        ///        │ │       ├─pattern: IdentifierPatternSyntax
        ///        │ │       │ ╰─identifier: identifier("name")
        ///        │ │       ╰─typeAnnotation: TypeAnnotationSyntax
        ///        │ │         ├─colon: colon
        ///        │ │         ╰─type: IdentifierTypeSyntax
        ///        │ │           ╰─name: identifier("String")
        ///        │ ├─[1]: MemberBlockItemSyntax
        ///        │ │ ╰─decl: VariableDeclSyntax
        ///        │ │   ├─attributes: AttributeListSyntax
        ///        │ │   ├─modifiers: DeclModifierListSyntax
        ///        │ │   ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.var)
        ///        │ │   ╰─bindings: PatternBindingListSyntax
        ///        │ │     ╰─[0]: PatternBindingSyntax
        ///        │ │       ├─pattern: IdentifierPatternSyntax
        ///        │ │       │ ╰─identifier: identifier("age")
        ///        │ │       ╰─typeAnnotation: TypeAnnotationSyntax
        ///        │ │         ├─colon: colon
        ///        │ │         ╰─type: IdentifierTypeSyntax
        ///        │ │           ╰─name: identifier("Int")
        ///        │ ╰─[2]: MemberBlockItemSyntax
        ///        │   ╰─decl: VariableDeclSyntax
        ///        │     ├─attributes: AttributeListSyntax
        ///        │     ├─modifiers: DeclModifierListSyntax
        ///        │     ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.var)
        ///        │     ╰─bindings: PatternBindingListSyntax
        ///        │       ╰─[0]: PatternBindingSyntax
        ///        │         ├─pattern: IdentifierPatternSyntax
        ///        │         │ ╰─identifier: identifier("isAlive")
        ///        │         ╰─typeAnnotation: TypeAnnotationSyntax
        ///        │           ├─colon: colon
        ///        │           ╰─type: IdentifierTypeSyntax
        ///        │             ╰─name: identifier("Bool")
        ///    ╰─rightBrace: rightBrace
        ///
        ///
        ///
        
        return ["""
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
