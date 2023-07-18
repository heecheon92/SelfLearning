import UIKit

protocol Visitable {
    func accept(visitor: some Visitor)
}

protocol Visitor {
    func visit(_ node: Apartment)
    func visit(_ node: GroceryStore)
    func visit(_ node: Office)
}

class GroceryStore: Visitable {
    func accept(visitor: some Visitor) {
        visitor.visit(self)
    }
}

class Apartment: Visitable {
    func accept(visitor: some Visitor) {
        visitor.visit(self)
    }
}

class Office: Visitable {
    func accept(visitor: some Visitor) {
        visitor.visit(self)
    }
}

class Person: Visitor {
    func visit(_ node: Office) {
        print("visiting office")
    }
    
    func visit(_ node: Apartment) {
        print("visiting apartment")
    }
    
    func visit(_ node: GroceryStore) {
        print("visiting grocery store")
    }
}

class Developer: Person {
    override func visit(_ node: Office) {
        print("developer visiting office")
    }
    
    override func visit(_ node: Apartment) {
        print("developer visiting apartment")
    }
    
    override func visit(_ node: GroceryStore) {
        print("developer visiting grocery store")
    }
}

let places: [any Visitable] = [GroceryStore(), Apartment(), Office()]
let me = Developer()
let someone = Person()

places.forEach { [weak me] p in
    if let me { p.accept(visitor: me); p.accept(visitor: someone) }
}
